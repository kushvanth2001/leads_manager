import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/chatsidshelper.dart';
import 'package:leads_manager/models/model_application.dart';
import 'package:leads_manager/views/chat/chatlistcontroller.dart';

class Applicationswitchbutton extends StatefulWidget {
  const Applicationswitchbutton({super.key});

  @override
  State<Applicationswitchbutton> createState() => _ApplicationswitchbuttonState();
}

class _ApplicationswitchbuttonState extends State<Applicationswitchbutton> {
  List<String> _applicationNames = [];
  String clientGroupName = '';
  String _selectedApplicationName = '';
  

  @override
  void initState() {
    super.initState();
    // Fetch applications and update the state
    fetchApplications().then((applications) {
      if (mounted) {
        setState(() {
          _applicationNames =
              applications.map((app) => app.applicationName ?? '').toList();
              print(_applicationNames);
        });
      }
    });

    // Fetch client group name and user-selected application
    SharedPrefsHelper().getClientGroupName().then((value) async {
      clientGroupName = value ?? '';
      _selectedApplicationName = await SharedPrefsHelper()
          .getUserSelectedChatbot(clientGroupName) ??await SharedPrefsHelper().getFristappName()??'';
      setState(() {});
    });
  }



  Future<void> _getTemplates(String selectedApplicationName) async {
    // Implement your logic to fetch templates based on the selected application
    print("Fetching templates for $selectedApplicationName");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: PopupMenuButton<int>(
              onSelected: (int newValue) async {
                if (mounted) {
                  setState(() {
                    _selectedApplicationName = _applicationNames[newValue];

                    // Update the selected application in shared preferences.
                    SharedPrefsHelper().setUserSelectedChatBot(
                      clientGroupName,
                      _selectedApplicationName,
                    );

                    // Update the application controller text field.
                   // applicationController.text = _selectedApplicationName;

                    // Fetch templates based on the selected application.
                    _getTemplates(_selectedApplicationName);

                    print("Selected application name: $_selectedApplicationName");

                    // Clear app name and reload chat data.


    if (!Get.isRegistered<ChatListController>()) {
      Get.put(ChatListController());
    }
ChatListController.searchController.text='';
                  ChatListController().clearTimes();
                    //GlobalChatNumbers.clearAppName();
                   // ChatController().clearTimes();
                    ChatListController().loadData(forcedReload: true);
                  });

                  // Notify thcallback if needed.
                  
ChatIdsHelper. resubscribe();
                  // Delay and reload the chat data again if required.
                  Future.delayed(
                    const Duration(seconds: 1),
                    () {
                    ChatListController().loadData(forcedReload: true);
                    },
                  );

                  // Close the popup after selection.
                 // Navigator.pop(context);
                }
              },
              itemBuilder: (BuildContext context) {
                return _applicationNames
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final applicationName = entry.value;
                  return PopupMenuItem<int>(
                    value: index,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedApplicationName == applicationName
                            ? Colors.green.withOpacity(0.9)
                            : const Color.fromARGB(255, 231, 231, 231),
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
                      _selectedApplicationName.isNotEmpty
                          ? "$_selectedApplicationName"
                          : "Select an application",
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Icon(Icons.arrow_drop_down)
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
