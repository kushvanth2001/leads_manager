import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leads_manager/models/model_application.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/views/leads/quickResponse/template.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';

class MessagesTabContent extends StatefulWidget {
  List<Application> applications;
  final List<int?> applicationIds;
  String? selectedApplicationName;
  int? selectedApplicationId;
  List? elements;
  final String? mobileNumber;
  final String? customerName;
  MessagesTabContent(
      this.applications,
      this.applicationIds,
      this.selectedApplicationName,
      this.selectedApplicationId,
      this.elements,
      this.mobileNumber,
      this.customerName);

  @override
  __MessagesTabContentState createState() => __MessagesTabContentState();
}

class __MessagesTabContentState extends State<MessagesTabContent> {
  String? selectedApplicationNameSharedPreferneces;
  String searchText = '';
  List? filteredElements;
  List<String> pinnedList = [];
  final prefsHelper = SharedPrefsHelper();
  String? pinnedTemplate;
  SnapPeNetworks snapPeNetworks = SnapPeNetworks();
  Future<void> savePinnedItems() async {
    String pinnedListString = pinnedList.join(',');
    print("$pinnedListString");
    List<Map<String, dynamic>> properties = [
      {
        "status": "OK",
        "messages": [],
        "propertyName": "pinned_templates",
        "propertyType": "client_user_attributes",
        "name": "Pinned templates",
        "id": 7,
        "propertyValue": pinnedListString,
        "propertyAllowedValues": "",
        "propertyDefaultValues": "",
        "isEditable": true,
        "remarks": null,
        "category": "Application",
        "isVisibleToClient": true,
        "interfaceType": "character_text",
        "pricelistCode": null
      }
    ];
    snapPeNetworks.changeProperty(properties);
    prefsHelper.setPinnedTemplates(pinnedListString);
  }

  void unpinItem(String elementName) {
    setState(() {
      pinnedList.remove(elementName);
      savePinnedItems();
    });
  }

  @override
  void initState() {
    super.initState();
    String propertyValue = prefsHelper.getPinnedTemplates();
    pinnedList = propertyValue.split(',');
    print("$pinnedList");
    filteredElements = widget.elements;
    // Set initial value of _selectedApplication to first element in applicationNames list
  }

  @override
  void didUpdateWidget(covariant MessagesTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.elements != oldWidget.elements) {
      filteredElements = widget.elements;
    }
  }

  @override
  Widget build(BuildContext context) {
    List pinnedFilteredElements = filteredElements
            ?.where((element) => pinnedList.contains(element['elementName']))
            ?.toList() ??
        [];
    List unpinnedFilteredElements = filteredElements
            ?.where((element) => !pinnedList.contains(element['elementName']))
            ?.toList() ??
        [];
    if (widget.applicationIds.isNotEmpty) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 8.0),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 231, 231, 231),
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: PopupMenuButton<int>(
                onSelected: (int newValue) async {
                  if (mounted) {
                    setState(() {
                      widget.selectedApplicationId = newValue;
                      final selectedApplication = widget.applications
                          .firstWhere((app) => app.id == newValue);
                      widget.selectedApplicationName =
                          selectedApplication.applicationName;
                      selectedApplicationNameSharedPreferneces =
                          selectedApplication.applicationName;
                    });
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setInt('selectedApplicationId', newValue);
                    await prefs.setString('selectedApplicationName',
                        selectedApplicationNameSharedPreferneces!);
                    //                    pinnedList.clear();
                    // String propertyValue = prefsHelper.getPinnedTemplates();
                    // pinnedList = propertyValue.split(',');
                  }
                  // Call API to fetch elements for selected application

                  var templates =
                      await getTemplates(widget.selectedApplicationName);
                  if (mounted) {
                    setState(() {
                      widget.elements = templates;
                      filteredElements = widget.elements;
                    });
                  }
                },
                itemBuilder: (BuildContext context) {
                  return widget.applicationIds
                      .map<PopupMenuItem<int>>((int? value) {
                    final application = widget.applications.firstWhere(
                      (app) => app.id == value,
                      orElse: () =>
                          Application(id: null, applicationName: 'Unknown'),
                    );
                    final applicationName =
                        application.applicationName ?? 'Unknown';
                    return PopupMenuItem<int>(
                      value: value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: value == widget.selectedApplicationId
                              ? Colors.green.withOpacity(0.9)
                              : Color.fromARGB(255, 231, 231, 231),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: Text(applicationName)),
                      ),
                    );
                  }).toList();
                },
                offset: Offset(
                  MediaQuery.of(context).size.width / 2 - 100,
                  MediaQuery.of(context).size.height / 2 - 100,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                        child: Text(
                      "                 ${widget.selectedApplicationName}",
                      style: TextStyle(fontSize: 20),
                    )),
                    Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Image.asset(
                          "assets/icon/change.jpg",
                          width: 30,
                        )),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoSearchTextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                  filteredElements = widget.elements?.where((element) {
                    return element['elementName']
                            .toLowerCase()
                            .contains(searchText.toLowerCase()) ||
                        element['data']
                            .toLowerCase()
                            .contains(searchText.toLowerCase());
                  }).toList();
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: pinnedFilteredElements.length +
                  unpinnedFilteredElements.length,
              itemBuilder: (BuildContext context, int index) {
                var template;
                if (index < pinnedFilteredElements.length) {
                  template = pinnedFilteredElements[index];
                } else {
                  template = unpinnedFilteredElements[
                      index - pinnedFilteredElements.length];
                }

                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 0.15, color: Colors.grey),
                      bottom: BorderSide(width: 0.15, color: Colors.grey),
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      template?['elementName'] ?? "",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      template?['data'] ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: Icon(
                          pinnedList.contains(template?['elementName'] ?? "")
                              ? Icons.push_pin
                              : Icons.push_pin_outlined),
                      onPressed: () async {
                        setState(() {
                          var itemName = template?['elementName'];
                          if (pinnedList.contains(itemName)) {
                            pinnedList.remove(itemName);
                          } else {
                            pinnedList.add(itemName);
                          }
                        });
                        await savePinnedItems();
                      },
                    ),
                    onTap: () {
                      // Open a new page with a TextBox containing the template data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TemplatePage(
                            template?['data'] ?? "",
                            widget.mobileNumber,
                            widget.applications,
                            widget.applicationIds,
                            widget.selectedApplicationName,
                            widget.selectedApplicationId,
                            fromMessageTab: true,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else {
      return Center(child: Text('-'));
    }
  }
}
