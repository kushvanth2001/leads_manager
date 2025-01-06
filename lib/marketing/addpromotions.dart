import 'dart:convert';

import 'package:bottom_picker/bottom_picker.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:leads_manager/marketing/addpromotionsfunctions.dart';
import 'package:leads_manager/marketing/customdropdown.dart';
import 'package:leads_manager/marketing/previewdilog.dart';
import 'package:leads_manager/models/model_promotion.dart';
import 'package:logger/logger.dart';

import '../helper/SharedPrefsHelper.dart';
import '../helper/networkHelper.dart';
import '../models/model_contactlist.dart';
import '../models/model_document.dart';
import '../models/model_templates.dart';
import '../widgets/vedioplayerwidget.dart';
import 'communicationdropdown.dart';
import 'communitcationlist.dart';
import 'documentdilog.dart';
import 'mappramsdialog.dart';
import '../../../domainvariables.dart';
class AddPromotions extends StatefulWidget {
  final CustomerList? fromcustomerlist;
  final int? id;
  const AddPromotions({Key? key, this.fromcustomerlist, this.id})
      : super(key: key);

  @override
  State<AddPromotions> createState() => _AddPromotionsState();
}

class _AddPromotionsState extends State<AddPromotions> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    setdata();
  }

  void setdata() async {
    var k = await fetchApplications();
    var u =
        await ContactList(contactsList: [], status: "ok").fetchContactLists();
    var s = await CustomerList.fetchAllCommunicationLists();
    setState(() {
      allcontactlist = u;
      _allApplications = k;
    });
    if (widget.fromcustomerlist != null) {
      setState(() {
        selectedCommunicarionList = widget.fromcustomerlist!.name ?? "";
        selectedCommunicationListid = widget.fromcustomerlist!.id ?? 0;
        _allCommunicationlist = s;
        print(_allCommunicationlist);
        selectedContactList = "";
        _allXlHeaders = [];
        _filePath = "";
      });
    }

    if (widget.id != null) {
      Promotions n = await Promotions.getPromotionById(widget.id!);

      try {
        setState(() {
          _selectedApplicationValues = n.applications;
          _allCommunicationlist = s;

          print("attachmenturls");
        });

        for (int i = 0; i < _selectedApplicationValues.length; i++) {
          var z = await TemplateModel.getTemplatesForMerchant(
              _selectedApplicationValues[i].applicationName);
          _allTemplates.addAll(z);
        }
        var p = _allTemplates
            .where((e) => e.elementName == n.messageTemplate)
            .toList();
        setState(() {
          p.length != 0 ? _selectedTemplate = p.first : _allTemplates.first;
          selectedCommunicarionList = n.communicationList["name"];
          print(
              "name of the communictaion list ${n.communicationList["name"]}");
          selectedCommunicationListid = n.communicationList["id"];
          noOfMessagesPerApplication = n.noOfMessagesPerApplication!;
          _descriptionController.text = n.description!;
          _nameController.text = n.name!;
          _fromListStart = n.from;
          _whereListends = n.to;
          DateFormat format = DateFormat.Hms();
          print("Starttime" + n.startTime);
          promotionstarttime = n.startTime == ""
              ? promotionstarttime
              : format.parse(n.startTime);
          promotionendtime =
              n.endTime == "" ? promotionendtime : format.parse(n.endTime);
          promotiondate =
              n.startDate == "" ? promotiondate : DateTime.parse(n.startDate);
          _messageController.text = n.messageText;
          creatorName = n.createrName;
          createdon = n.createdOn;
          if (_urlAttachments.isNotEmpty) {
            var x = jsonDecode(n.attachmentUrls!);
            for (int i = 0; i < x.length; i++) {
              _selectedDocuments.add(Document(
                  id: i,
                  downloadLink: x[i],
                  fileData: x[i],
                  fileLink: x[i],
                  description: "l"));
            }
          }
        });
      } catch (ex) {
        print("Edit promotion exception$ex");
      }
    }
  }

  int selectedRadio = 1;
  int _currentStep = 0;
  int uploadexternalRadio = 1;
  Template _selectedTemplate = Template(
      appId: "",
      category: "",
      createdOn: 1,
      data: "",
      elementName: "",
      externalId: "",
      id: "",
      languageCode: "",
      languagePolicy: "",
      master: "",
      meta: "",
      modifiedOn: 1,
      namespace: "",
      status: "",
      templateType: "",
      vertical: "",
      reason: "",
      url: "",
      templateId: "");
  List<Application> _selectedApplicationValues = [];
  List<Application> _allApplications = [];
  List<Template> _allTemplates = [];
  List<String> validation = [];
  List<String> _allXlHeaders = [];
  List<bool> _isdropdownType = [];
  List<String> _dynamicParams = [];
  List<Document> _selectedDocuments = [];
  List<String> _urlAttachments = [];
  Map<String, dynamic> _selectesParams = {};
  DateTime promotiondate = DateTime(200);
  DateTime promotionstarttime = DateTime(200);
  DateTime promotionendtime = DateTime(200);
  String selectedCommunicarionList = "";
  int selectedCommunicationListid = 0;
  List<String> pramstype = [];
  int noOfMessagesPerApplication = 0;
  List<CustomerList> _allCommunicationlist = [];
  String _filePath = "";
  int _fromListStart = 0;
  String creatorName = "";
  String createdon = "";
  int _whereListends = 0;
  String selectedContactList = "";
  List<String> _matchedPatterns = [];
  List<String> allcontactlist = [];
  TextEditingController _messageController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  final logger = Logger();
  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  bool getdropdwntype(index) {
    return _isdropdownType[index];
  }

  bool validate() {
    if (_messageController.text != "" &&
        _nameController.text != "" &&
        _selectedApplicationValues.isNotEmpty &&
        !(_filePath != "" &&
            selectedCommunicarionList != "" &&
            selectedContactList != "")) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> postData(Map<String, dynamic> payload) async {
    String? token = await SharedPrefsHelper().getToken();
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";

    print("applicationdata" + payload["applications"].toString());

    try {
      final response = await NetworkHelper().request(
        RequestType.post,
        Uri.parse(
            'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/validate'),
        requestBody: jsonEncode(payload),
      );

      if (response!.statusCode == 200) {
        // Successful post, handle the response if needed
        print('Post request successful');
        print(response.body);
        print(response.statusCode);
        if (json.decode(response.body)["success"] == true) {
          print("success");
          final response1 = await NetworkHelper().request(
            widget.id != null ? RequestType.put : RequestType.post,
            Uri.parse(widget.id != null
                ? 'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/merchant-promotions/${widget.id}'
                : 'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/merchant-promotions'),
            requestBody: jsonEncode(payload),
          );
          if (response1!.statusCode == 200) {
            Fluttertoast.showToast(msg: "Successfully Posted Promotion");

            Navigator.of(context).pop();
          } else {
            print("Error Statucs code ${response1.statusCode}");
              print("Error Statucs code ${jsonDecode(response1.body)}");
               Fluttertoast.showToast(msg: "Promotion posted  it will take some time to appear in the Promotions Page ");
               Navigator.of(context).pop();
            // Fluttertoast.showToast(
            //     msg: "Something is Wrong Please try agian After Sometime ");
          }
        }
      } else {
        // Handle unsuccessful post
        print('Post request failed with status: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      // Handle exceptions
      if (e is PlatformException) {
        print('Exception occurred: ${e.message}');
      } else {
        print('Exception occurred: $e');
      }
    }
  }

// Example usage in your code
  void postPromotionsData(bool issave) async {
    String Status = issave ? "Save" : "New";

    dynamic communicationmap = {};
    if (selectedCommunicarionList != "") {
      print("selectedvalue:" + selectedCommunicarionList);
      print("unselected:" + selectedContactList);
      print("unvalue:" + "dynamic");
      //   communicationmap= _allCommunicationlist.map((e) {if(e.id==selectedCommunicationListid){
      //   return e;
      // }} ).toList()[0]?? _allCommunicationlist[0];
      communicationmap = _allCommunicationlist.isNotEmpty
          ? _allCommunicationlist.firstWhere(
              (e) => e.id == selectedCommunicationListid,
              orElse: () => _allCommunicationlist[0])
          : null;
      communicationmap = communicationmap != null
          ? communicationmap.toJson()
          : _allCommunicationlist[0].toJson();
    } else if (selectedContactList != "") {
      communicationmap =
          AddPromotionsFunctions.fetchContacts(selectedContactList);
      communicationmap.toJson();
      print("selectedvalue:" + selectedContactList);
      print("unselected:" + selectedCommunicarionList);
      print("unvalue:" + "dynamic");
    } else {
      print("selectedvalue:" + _selectesParams.toString());
      print("unselected:" + selectedContactList);
      print("unvalue:" + "dynamic");
    }
    List<String> externalurls = _selectedDocuments.map((e) {
      return e.downloadLink!;
    }).toList();
// var filterselecteddocslist= _selectedDocuments.removeWhere((document) =>
//         _urlAttachments.contains(document.downloadLink));
    List<Map<String, dynamic>> mapprams = [];

    for (int i = 0; i < pramstype.length; i++) {
      mapprams.add({
        "param": _selectesParams.keys.elementAt(i)[2],
        "system_param_key": _selectesParams.values.elementAt(i),
        "param_type": pramstype[i]
      });
    }

    if (widget.id == null) {
      createdon = DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
      creatorName =
          await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";
    } else {
      Status = "Completed";
    }

    List<Map<String, dynamic>> d = [];
    var x = await fetchApplicationstemp();
    for (int i = 0; i < _selectedApplicationValues.length; i++) {
      print(_selectedApplicationValues[i].applicationName);
      var templist = x
          .where((element) =>
              element["applicationName"] ==
              _selectedApplicationValues[i].applicationName)
          .toList();
      templist.length != 0 ? d.add(templist[0]) : null;

      print(d);
    }
    Map<String, dynamic> payload = {
      'communicationList': communicationmap,
      'applicationType': _selectedApplicationValues[0].type,
      'applications': d,
      'documents': {'documents': []},
     // 'attachmentUrls': externalurls.length == 0 ? null : externalurls,
      'description': _descriptionController.text,
      'mappedParams': jsonEncode(mapprams),
      'endTime': DateFormat('HH:mm:ss').format(promotionendtime),
      'from': _fromListStart != 0 ? _fromListStart : null,
      'messageTemplate': _selectedTemplate.elementName,
      'messageText': _selectedTemplate.data,
      'name': _nameController.text,
      'noOfMessagesPerApplication': null,
      // 'replyTo': _selectedApplicationValues[0].phoneNo,
      'senderName': _selectedApplicationValues[0].applicationName,
      'startDate': promotiondate.year == 200
          ? null
          : DateFormat('yyyy-MM-dd').format(promotiondate),
      'startTime': promotionstarttime.year == 200
          ? null
          : DateFormat('HH:mm:ss').format(promotionstarttime),
      'status': Status,
      'to': _whereListends != 0 ? _whereListends : null,
      "createdOn": createdon,
      "creatorName": creatorName,
      "externalDataUrl": null,
      "urlTracking": null,
      "removeDuplicates": null,
      "batchSize": null,
      "timeInterval": null,
      "replyTo": null
    };

    printWrapped("payload" + "${jsonEncode(payload)}");
    //showPayloadDialog(context, payload);
    await Future.delayed(Duration(seconds: 4));
    await postData(payload);
  }

  Future<List<Application>> fetchApplications() async {
    try {
      String clientGroupName =
          await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";

      final response = await NetworkHelper().request(
        RequestType.get,
        Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/linked-numbers',
        ),
        requestBody: "",
      );

      if (response != null && response.statusCode == 200) {
        final parsed = json.decode(response.body);

        if (parsed != null && parsed is Map<String, dynamic>) {
          final List<dynamic> applicationList = parsed['application'];
          final List<Application> applications = applicationList
              .map((json) => Application.fromJson(json))
              .toList();

          return applications;
        } else {
          print('Invalid response format');
          throw Exception('Invalid response format');
        }
      } else {
        print('Failed to load applications');
        throw Exception('Failed to load applications');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw e;
    }
  }

  void _openCustomDropDownDialog(BuildContext context) {
    var savedifcanceldapplications = _selectedApplicationValues;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Application'),
          content: CustomDropDown(
            initiallySelectedItems: _selectedApplicationValues,
            allapplicationlist:
                _allApplications, // Provide your list of applications
            onSelectionChanged: (_selectedItems) {
              setState(() {
                _selectedApplicationValues = _selectedItems;
              });
              // Close the dialog on selection
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedApplicationValues = savedifcanceldapplications;
                });

                Navigator.of(context)
                    .pop(); // Close the dialog without selection
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  _allTemplates = [];
                });

                Navigator.of(context).pop();

                for (int i = 0; i < _selectedApplicationValues.length; i++) {
                  var k = await TemplateModel.getTemplatesForMerchant(
                      _selectedApplicationValues[i].applicationName);

                  setState(() {
                    _allTemplates.addAll(k);
                  });
                }
                print(_allTemplates);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _steps = [
      Card(
        elevation: 4,
        child: Container(
          padding: EdgeInsets.all(8),
          color: Color.fromARGB(12, 12, 12, 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: 25,
                  ),
                  Text(
                    "Basic Details",
                    style: TextStyle(fontSize: 20),
                  )
                ],
              ),
              Divider(
                color: Colors.black,
              ),
              const SizedBox(height: 30),
              const Text("Name *", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _nameController,
                    validator: (value) {
                      var k;
                      setState(() {
                        var k = value;
                      });
                      if (k == null || k == "") {
                        return 'Please enter name';
                      }

                      return null;
                    },
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color.fromARGB(12, 12, 12, 12),
                      border: InputBorder.none,
                      hintText: "Name",
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text("Applications", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _openCustomDropDownDialog(context);
                },
                child: Text('Select Application '),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _selectedApplicationValues.map((selectedItem) {
                    return Container(
                      margin: EdgeInsets.all(8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedItem.applicationName,
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
              _selectedApplicationValues.length == 2
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("No.Of messages per Application",
                            style: TextStyle(fontSize: 17)),
                        const SizedBox(height: 7),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              initialValue:
                                  noOfMessagesPerApplication.toString(),
                              onChanged: (value) {
                                setState(() {
                                  noOfMessagesPerApplication =
                                      int.tryParse(value) ?? 0;
                                });
                              },
                              validator: (value) {
                                var k;
                                setState(() {
                                  var k = value;
                                });
                                if (k == null || k == "") {
                                  return 'Please Enter Number of Messages per Application';
                                }

                                return null;
                              },
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Color.fromARGB(12, 12, 12, 12),
                                border: InputBorder.none,
                                hintText: "no.of messages per Application",
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(),
              const SizedBox(height: 10),
              const Text("Description", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 120,
                child: TextFormField(
                  controller: _descriptionController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Description';
                    }

                    return null;
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(12, 12, 12, 12),
                    border: InputBorder.none,
                    hintText: "Description",
                  ),
                  expands: true,
                  minLines: null,
                  maxLines: null,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      //step2
      Card(
        elevation: 4,
        child: Container(
          color: Color.fromARGB(12, 12, 12, 12),
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.send,
                    size: 25,
                  ),
                  Text(
                    "Send To",
                    style: TextStyle(fontSize: 20),
                  )
                ],
              ),
              Divider(
                color: Colors.black,
              ),
              const SizedBox(height: 30),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Radio(
                        value: 1,
                        groupValue: selectedRadio,
                        onChanged: (val) {
                          setSelectedRadio(val as int);
                        },
                      ),
                      Text('Communication List'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Radio(
                        value: 2,
                        groupValue: selectedRadio,
                        onChanged: (val) {
                          setSelectedRadio(val as int);
                        },
                      ),
                      Text('Upload External File'),
                    ],
                  ),
                ],
              ),
              selectedRadio == 1
                  ? Center(
                      child: Column(
                      children: [
                        MaterialButton(
                            color: Colors.blue,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    // Set the shape of the dialog
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: CommunicationListDropdown(
                                        initialSelectedValue:
                                            selectedCommunicarionList,
                                        onItemSelected: (value, i) {
                                          setState(() {
                                            selectedCommunicarionList = value;
                                            selectedCommunicationListid = i;
                                            selectedContactList = "";
                                            _allXlHeaders = [];
                                            _filePath = "";
                                          });
                                          Navigator.pop(context);
                                        },
                                        allComList: (value) {
                                          setState(() {
                                            _allCommunicationlist = value;
                                          });
                                        }),
                                  );
                                },
                              );
                            },
                            child: Text(selectedCommunicarionList != ""
                                ? "Reselect the communication list"
                                : "Select Communication List")),
                        selectedCommunicarionList != ""
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    "SelectedCommunicarionList: $selectedCommunicarionList"),
                              )
                            : Container()
                      ],
                    ))
                  : Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio(
                              value: 1,
                              groupValue: uploadexternalRadio,
                              onChanged: (val) {
                                setState(() {
                                  uploadexternalRadio = val as int;
                                });
                              },
                            ),
                            Text('select contact List'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio(
                              value: 2,
                              groupValue: uploadexternalRadio,
                              onChanged: (val) {
                                setState(() {
                                  uploadexternalRadio = val as int;
                                });
                              },
                            ),
                            Text('Upload External File'),
                          ],
                        ),
                        uploadexternalRadio == 1
                            ? Padding(
                                padding: EdgeInsets.all(20),
                                child: DropDownTextField(
                                  listTextStyle: TextStyle(
                                      fontSize: 17,
                                      overflow: TextOverflow.fade),
                                  clearOption: true,
                                  textFieldDecoration: const InputDecoration(
                                      label: Text("Select Contact List"),
                                      border: OutlineInputBorder()),
                                  searchDecoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0)),
                                      ),
                                      hintText: "Search Contact List here"),
                                  dropDownItemCount: 6,
                                  dropDownList: allcontactlist.map((contact) {
                                    return DropDownValueModel(
                                        name: contact, value: contact);
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      selectedContactList = val.value;
                                      _filePath = "";

                                      _allXlHeaders = [];
                                      selectedCommunicarionList = "";
                                      selectedCommunicationListid = 0;
                                    });
                                  },
                                ),
                              )
                            : Container(),
                        uploadexternalRadio == 2
                            ? MaterialButton(
                                color: Colors.blue,
                                onPressed: () async {
                                  FilePickerResult? result =
                                      await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: [
                                      'xls',
                                      'xlsx',
                                      'xlsm',
                                      'csv'
                                    ],
                                  );

                                  if (result != null) {
                                    setState(() {
                                      _filePath = result.files.single.path!;
                                      _allXlHeaders = AddPromotionsFunctions
                                          .getColumnNamesFromExcel(_filePath);
                                      selectedCommunicationListid = 0;
                                      selectedCommunicarionList = "";
                                      selectedContactList = "";
                                      _filePath = result.files.single.name;
                                    });

                                    print('File path: $_filePath');
                                    print('Column Names: $_allXlHeaders');
                                  } else {
                                    // Handle case when no file is picked
                                  }
                                },
                                child: Text(_filePath == ""
                                    ? "Upload a Contact List"
                                    : "Reselect upload list"))
                            : Container(),
                        _filePath != ""
                            ? Text("Selected file $_filePath")
                            : Container(),
                      ],
                    )
            ],
          ),
        ),
      ),
      //step3
      Card(
        elevation: 8,
        child: Container(
          color: Color.fromARGB(12, 12, 12, 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.message,
                        size: 25,
                      ),
                      Text(
                        "Message",
                        style: TextStyle(fontSize: 20),
                      )
                    ],
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Column(
                    children: [
                      _selectedApplicationValues.length == 0
                          ? Container()
                          : Padding(
                              padding: EdgeInsets.all(5),
                              child: DropDownTextField(
                                listTextStyle: TextStyle(
                                    fontSize: 17, overflow: TextOverflow.fade),
                                enableSearch: true,
                                clearOption: false,
                                textFieldDecoration: const InputDecoration(
                                    label: Text("Select Template"),
                                    border: OutlineInputBorder()),
                                searchDecoration: InputDecoration(
                                  label: Text("Search Template"),
                                  suffixIcon: Icon(Icons.search_rounded),
                                  border: OutlineInputBorder(),
                                ),
                                dropDownItemCount: 6,
                                dropDownList: _allTemplates.map((contact) {
                                  return DropDownValueModel(
                                      name: contact.elementName,
                                      value: contact.id);
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    for (int i = 0;
                                        i < _allTemplates.length;
                                        i++) {
                                      if (val.value.toString().trim() ==
                                          _allTemplates[i].id.trim()) {
                                        _selectedTemplate = _allTemplates[i];
                                      }
                                    }

                                    _messageController.text =
                                        _selectedTemplate.data;
                                  });
                                },
                              ),
                            ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: 300,
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Message",
                            filled: true,
                            fillColor: Color.fromARGB(12, 12, 12, 12),
                          ),
                          textAlignVertical: TextAlignVertical.top,
                          expands: true,
                          minLines: null,
                          maxLines: null,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              if (_messageController.text.isNotEmpty) {
                                RegExp regExp = RegExp(r'{{\d+}}');
                                if (regExp.hasMatch(_messageController.text)) {
                                  RegExp regExp = RegExp(r'{{\d+}}');
                                  Iterable<RegExpMatch> matches = regExp
                                      .allMatches(_messageController.text);
                                  List<String> matchedPatterns = [];
                                  for (RegExpMatch match in matches) {
                                    matchedPatterns.add(match.group(0)!);
                                  }

                                  setState(() {
                                    _matchedPatterns = matchedPatterns;
                                    _isdropdownType = List.generate(
                                        matchedPatterns.length,
                                        (index) => true);
                                  });

                                  if (_filePath != "") {
                                    setState(() {
                                      _dynamicParams = _allXlHeaders;
                                    });
                                  } else if (selectedCommunicarionList != "") {
                                    List<String> convertedList =
                                        _allCommunicationlist
                                            .where((customer) =>
                                                customer.id ==
                                                selectedCommunicationListid)
                                            .expand<String>((customer) {
                                      if (customer.type == "lead") {
                                        return [
                                          "Customer Name",
                                          "Organization Name",
                                          "Mobile Number",
                                          "Email",
                                          "City",
                                          "State",
                                          "Source",
                                          "Assigned_to",
                                          "Pincode",
                                          "Notes",
                                          "Tags",
                                        ];
                                      } else {
                                        return [
                                          "Customer Name",
                                          "Organization Name",
                                          "Mobile Number",
                                          "Email",
                                          "City",
                                          "State",
                                          "Source",
                                          "Assigned_to",
                                          "Pincode",
                                          "Notes",
                                          "Tags",
                                        ];
                                      }
                                    }).toList();

                                    setState(() {
                                      _dynamicParams = convertedList;
                                    });
                                  } else if (selectedContactList != "") {
                                    var c = await AddPromotionsFunctions
                                        .fetchContacts(selectedContactList);
                                    setState(() {
                                      _dynamicParams = c;
                                    });
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            "Please Select a List get Dynamic Headers",
                                        gravity: ToastGravity.CENTER);
                                  }

                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return MapPramsDialog(
                                          matchedPatterns: matchedPatterns,
                                          setprams: (p0, p1) {
                                            setState(() {
                                              _selectesParams = p0;
                                              pramstype = p1;
                                            });
                                          },
                                          dynamicparams: _dynamicParams,
                                          msgstring: _messageController.text,
                                          setmsgstring: (String value) {
                                            setState(() {
                                              _messageController.text = value;
                                            });
                                          },
                                        );
                                      });
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg:
                                        'Message text is empty, select a template.',
                                    gravity: ToastGravity.CENTER);
                              }
                            },
                            child: Text("Map Message Params")),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Template",
                          style: TextStyle(fontSize: 18),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            "In order to send a message to the community ECOMMERCE with this template message, you must upload excel file template with customer details.Please click on this button to download and upload the template.",
                            style: TextStyle(color: Colors.blue, fontSize: 17),
                          ),
                        ),
                        ElevatedButton(
                            onPressed: () {},
                            child: Text("Show Download and import Box")),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      //step4
      Card(
        elevation: 4,
        child: Container(
            padding: EdgeInsets.all(20),
            color: Color.fromARGB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.more_vert_sharp,
                      size: 25,
                    ),
                    Text(
                      "Advanced Details",
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
                Divider(
                  color: Colors.black,
                ),
                const Text("Select Promotion Start Date",
                    style: TextStyle(fontSize: 17)),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextButton(
                    child: Text(promotiondate.year == 200
                        ? "Select Start date :"
                        : "start date is ${DateFormat('MM-dd-yyyy').format(promotiondate)}"),
                    onPressed: () {
                      // BottomPicker.date(
                      //         title: "Set the promotion exact  date",
                      //         titleStyle: TextStyle(
                      //             fontWeight: FontWeight.bold,
                      //             fontSize: 15,
                      //             color: Colors.black),
                      //         onSubmit: (date) {
                      //           setState(() {
                      //             promotiondate = date;
                      //           });
                      //         },
                      //         buttonContent: Text('Confirm'),
                      //         buttonSingleColor: Colors.pink,
                      //         minDateTime: DateTime(1960, 5, 1),
                      //         maxDateTime: DateTime(2959, 8, 2))
                      //     .show(context);
                    },
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                const Text("Select Promotion Start Time",
                    style: TextStyle(fontSize: 17)),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextButton(
                    child: Text(promotionstarttime.year == 200
                        ? "Select time :"
                        : "start time is ${DateFormat('HH:mm aa').format(promotionstarttime)}"),
                    onPressed: () {
                      // BottomPicker.time(
                      //   title: "Set the promotion exact start time",
                      //   titleStyle: TextStyle(
                      //       fontWeight: FontWeight.bold,
                      //       fontSize: 15,
                      //       color: Colors.black),
                      //   onSubmit: (time) {
                      //     setState(() {
                      //       promotionstarttime = time;
                      //     });
                      //   },
                      //   buttonContent: Text('Confirm'),
                      //   buttonSingleColor: Colors.pink,
                      //   initialTime: Time.now(),
                      // ).show(context);
                    },
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                const Text("Select Promotion End Time",
                    style: TextStyle(fontSize: 17)),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextButton(
                    child: Text(promotionendtime.year == 200
                        ? "Select end time :"
                        : "start end time is ${DateFormat('HH:mm aa').format(promotionendtime)}"),
                    onPressed: () {
                      // BottomPicker.time(
                      //   title: "Set the promotion exact end  time",
                      //   titleStyle: TextStyle(
                      //       fontWeight: FontWeight.bold,
                      //       fontSize: 15,
                      //       color: Colors.black),
                      //   onSubmit: (time) {
                      //     setState(() {
                      //       promotionendtime = time;
                      //     });
                      //   },
                      //   buttonContent: Text('Confirm'),
                      //   buttonSingleColor: Colors.pink,
                      //   initialTime: Time.now(),
                      // ).show(context);
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                selectedCommunicarionList != ""
                    ? Align(
                        alignment: Alignment.bottomLeft,
                        child: Text("Send the List From Start"))
                    : Container(),
                SizedBox(
                  height: 5,
                ),
                selectedCommunicarionList != ""
                    ? TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Start', border: OutlineInputBorder()),
                        onChanged: (value) {
                          setState(() {
                            _fromListStart = int.tryParse(value) ?? 0;
                          });
                        },
                      )
                    : Container(),
                SizedBox(
                  height: 10,
                ),
                selectedCommunicarionList != ""
                    ? Align(
                        alignment: Alignment.bottomLeft,
                        child: Text("Send upto  the List"))
                    : Container(),
                SizedBox(
                  height: 5,
                ),
                selectedCommunicarionList != ""
                    ? TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'End', border: OutlineInputBorder()),
                        onChanged: (value) {
                          setState(() {
                            _whereListends = int.tryParse(value) ?? 0;
                          });
                        },
                      )
                    : Container(),
              ],
            )),
      ),
      //step5
      Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.attach_file,
                  size: 25,
                ),
                Text(
                  "Attachments",
                  style: TextStyle(fontSize: 20),
                )
              ],
            ),
            Divider(
              color: Colors.black,
            ),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  color: Color.fromARGB(12, 12, 12, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MaterialButton(
                        color: Colors.blue,
                        onPressed: () {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return DocumentDialog(
                                initialSelectedDocuments: _selectedDocuments,
                                onSave: (List<Document> value) {
                                  setState(() {
                                    _selectedDocuments = value;
                                  });
                                  print(_selectedDocuments);
                                },
                              );
                            },
                          );
                        },
                        child: Column(children: [
                          Text("Add Document"),
                          Icon(Icons.edit_document)
                        ]),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      MaterialButton(
                        color: Colors.blue,
                        onPressed: () async {
                          // var u =
                          //     await AddPromotionsFunctions.handleFileInput();
                          // if (u.fileLink != null && u.fileLink! != "") {
                          //   setState(() {
                          //     _selectedDocuments.add(u);
                          //     _urlAttachments.add(u.downloadLink!);
                          //  });
                          if(false){

                          
                          } else {
                            Fluttertoast.showToast(
                                msg: "Some thing is Wrong Please try again");
                          }
                        },
                        child: Column(children: [
                          Text("Add Attachment"),
                          Icon(Icons.attach_file)
                        ]),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    constraints: BoxConstraints(minHeight: 100, maxHeight: 350),
                    child: GridView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15.0,
                        mainAxisSpacing: 15.0,
                        mainAxisExtent: 130,
                      ),
                      itemCount: _selectedDocuments.length,
                      itemBuilder: (context, index) {
                        Document document = _selectedDocuments[index];
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Card(
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Column(
                                  children: [
                                    Builder(
                                      builder: (context) {
                                        if (document.fileLink!
                                                .toLowerCase()
                                                .endsWith("jpeg") ||
                                            document.fileLink!
                                                .toLowerCase()
                                                .endsWith("jpg") ||
                                            document.fileLink!
                                                .toLowerCase()
                                                .endsWith("png")) {
                                          return Image.network(
                                            document.downloadLink!,
                                            width: 60,
                                            height: 60,
                                          );
                                        } else if (document.fileLink!
                                            .toLowerCase()
                                            .endsWith("mp4")) {
                                          return VideoPlayerWidget(
                                            videoUrl: document.downloadLink!,
                                          );
                                        } else {
                                          return Icon(getDocumentTypeFromLink(
                                              document.fileLink!));
                                        }
                                      },
                                    ),
                                    SizedBox(height: 8.0),
                                    Padding(
                                        padding: EdgeInsets.only(left: 6),
                                        child: Text(document.description!)),
                                  ],
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedDocuments.removeAt(index);
                                    });
                                  },
                                  icon: Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red),
                                      child: Icon(
                                        Icons.close_rounded,
                                        fill: 1,
                                        color: Colors.white,
                                      ))),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),

      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.visibility,
                size: 25,
              ),
              Text(
                "Preview",
                style: TextStyle(fontSize: 20),
              )
            ],
          ),
          Divider(
            color: Colors.black,
          ),
          PreviewDialog(
            documents: _selectedDocuments,
            message: _messageController.text,
          ),
        ],
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: Text("New Promotion")),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          controlsBuilder: (BuildContext, ControlsDetails) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _currentStep == 0
                    ? Container()
                    : ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentStep = _currentStep - 1;
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_back,
                              size: 15,
                            ),
                            Text("Back"),
                          ],
                        ),
                      ),
                if (widget.id == null)
                  MaterialButton(
                    color: Colors.green,
                    onPressed: () {
                      postPromotionsData(true);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          size: 15,
                        ),
                        Text("Save"),
                      ],
                    ),
                  ),
                _currentStep == 5
                    ? ElevatedButton(
                        onPressed: () async {
                          print("validation" +
                              _formKey.currentState!.validate().toString());
                          setState(() {
                            validation = [];
                          });
                          if ((_filePath == "" &&
                              selectedCommunicarionList == "" &&
                              selectedContactList == "")) {
                            setState(() {
                              validation.add("Select a List");
                            });
                          }
                          if (_nameController.text == "") {
                            setState(() {
                              validation.add("Fill the name");
                            });
                          }
                          if (_selectedApplicationValues.isEmpty) {
                            setState(() {
                              validation.add("No Application Selected");
                            });
                          }
                          if (_messageController.text == "") {
                            setState(() {
                              validation
                                  .add("Add Message by Selecting a Template");
                            });
                          }

//           if(_filePath!=""){
// if(_selectesParams.isEmpty){
//   setState(() {
//     validation.add("Map Parameters");
//   });
// }

//           }
                          if (validation.length == 0) {
                            Fluttertoast.showToast(
                                msg: "Validation Succesfull");

                            postPromotionsData(false);
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                      "Please Fill the Required Details Before Submitting"),
                                  content: BulletPointList(validation),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Close"),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: Text("Submit"),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentStep = _currentStep + 1;
                          });
                        },
                        child: Row(
                          children: [
                            Text("Next"),
                            Icon(Icons.arrow_forward, size: 15)
                          ],
                        ),
                      )
              ],
            );
          },
          onStepTapped: (value) {
            setState(() {
              _currentStep = value;
            });
          },
          onStepContinue: () {
            if (_currentStep >= 2) return;
            setState(() {
              _currentStep += 1;
            });
          },
          onStepCancel: () {
            if (_currentStep <= 0) return;
            setState(() {
              _currentStep -= 1;
            });
          },
          steps: [
            Step(
              label: Icon(Icons.person),
              isActive: _currentStep == 0 ? true : false,
              title: Text(""),
              content: _steps[_currentStep],
            ),
            Step(
              label: Transform.rotate(
  angle: 25 * -3.141592653589793 / 180, // Convert degrees to radians
  child: Icon(Icons.send),
),
              isActive: _currentStep == 1 ? true : false,
              title: Text(''),
              content: _steps[_currentStep],
            ),
            Step(
              label: Icon(Icons.message),
              isActive: _currentStep == 2 ? true : false,
              title: Text(''),
              content: _steps[_currentStep],
            ),
            Step(
              label: Icon(Icons.more_vert_sharp),
              isActive: _currentStep == 3 ? true : false,
              title: Text(''),
              content: _steps[_currentStep],
            ),
            Step(
              label: Icon(Icons.attach_file),
              isActive: _currentStep == 4 ? true : false,
              title: Text(''),
              content: _steps[_currentStep],
            ),
            Step(
              label: Icon(Icons.visibility),
              isActive: _currentStep == 5 ? true : false,
              title: Text(''),
              content: _steps[_currentStep],
            ),
          ],
        ),
      ),
    );
  }

  IconData getDocumentTypeFromLink(String fileLink) {
    // Implement logic to determine document type based on file link
    // For example, check file extension or any other patterns
    if (fileLink.endsWith('.mp4')) {
      return Icons.play_arrow;
    } else if (fileLink.endsWith('.jpeg') ||
        fileLink.endsWith('.jpg') ||
        fileLink.endsWith('.png')) {
      return Icons.image;
    } else if (fileLink.endsWith('.docx')) {
      return Icons.insert_drive_file;
    } else if (fileLink.endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    } else {
      return Icons.file_copy;
    }
  }
}

class Application {
  String? status;

  int id;
  String uniqueName;
  String applicationName;
  String apiKey;
  String url;

  String phoneNo;

  String type;

  Application({
    this.status,
    required this.id,
    required this.uniqueName,
    required this.applicationName,
    required this.apiKey,
    required this.url,
    required this.phoneNo,
    required this.type,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      status: json['status'] ?? "",
      id: json['id'] as int,
      uniqueName: json['uniqueName'] ?? "",
      applicationName: json['applicationName'] ?? "",
      apiKey: json['apiKey'] ?? "",
      url: json['url'] ?? "",
      phoneNo: json['phoneNo'] ?? "",
      type: json['type'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'uniqueName': uniqueName,
      'applicationName': applicationName,
      'apiKey': apiKey,
      'url': url,
      'status': status,
      'phoneNo': phoneNo,
      'type': type,
    };

    if (status != null) {
      data['status'] = status;
    }

    return data;
  }
}

class BulletPointList extends StatelessWidget {
  final List<String> items;

  BulletPointList(this.items);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => ListTile(
              leading: Icon(Icons.fiber_manual_record, size: 12),
              title: Text(item),
            ),
          )
          .toList(),
    );
  }
}

Future<List<dynamic>> fetchApplicationstemp() async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  try {
    final response = await NetworkHelper().request(
      RequestType.get,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/linked-numbers'),
      requestBody: "",
    );
    if (response != null && response.statusCode == 200) {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      final jsonResponse = json.decode(response.body);
      return jsonResponse["application"];
    } else {
      print('Failed to load applications');
      throw Exception('Failed to load applications');
    }
  } catch (e) {
    print('Exception occurred: $e');
    throw e;
  }
}

void showPayloadDialog(BuildContext context, Map<String, dynamic> payload) {
  // Convert payload map to JSON string
  String payloadJson = jsonEncode(payload);

  // Show dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Payload'),
        content: SelectableText(payloadJson), // Make text selectable
        actions: <Widget>[
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
          ),
        ],
      );
    },
  );
}

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}
