import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:leads_manager/Controller/chatDetails_controller.dart';
import 'package:leads_manager/Controller/chat_controller.dart';
import 'package:leads_manager/Controller/leads_controller.dart';
import 'package:leads_manager/Controller/switch_controller.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:leads_manager/helper/socketHelper.dart';
import 'package:leads_manager/main.dart';
import 'package:leads_manager/models/model_application.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/utils/snapPeUI.dart';
import 'package:leads_manager/views/chat/chatEntered.dart';
import 'package:leads_manager/views/chat/myChatPage.dart';
import 'package:leads_manager/views/chat/newRequestPage.dart';
import 'package:leads_manager/views/chat/otherPage.dart';

class LiveAgentScreen extends StatefulWidget {
  final List<String?>? applicationNames;

  final String? firstAppName;

  const LiveAgentScreen({Key? key, this.applicationNames, this.firstAppName})
      : super(key: key);

  @override
  State<LiveAgentScreen> createState() => _LiveAgentScreenState();
}

class _LiveAgentScreenState extends State<LiveAgentScreen>
    with TickerProviderStateMixin {
  final LeadController leadController =Get.find<LeadController>();
  late TabController _tabController;
  //final switchController = SwitchController();
  //final socketHelper = SocketHelper.getInstance;

  SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
  TextEditingController applicationController = TextEditingController();
  final List<Tab> tabs = <Tab>[
    Tab(text: "Active"),
    Tab(text: "Inactive"),
    Tab(text: "Others")
  ];
  String? _selectedApplicationName;

  final ScrollController _scrollController = ScrollController();
  List<dynamic>? _templates = [];
  String? clientGroupName;
  Future<void> reloadData() async {
    await leadController.loadData(forcedReload: true);
  }

  @override
  void initState() {
    super.initState();
    // homeuserselectedApplicationName = widget.homeuserselectedApplicationName;
    reloadData();
    clientGroupName = sharedPrefsHelper.getClientGroupNameTest();

    final userselectedApplicationName =
        SharedPrefsHelper().getUserSelectedChatbot(clientGroupName);
    _tabController = new TabController(vsync: this, length: 3);
    _tabController.index = 1;
    _selectedApplicationName =
        userselectedApplicationName ?? widget.firstAppName;
         //testforcereload
    ChatController().loadData(forcedReload: true);
    _getTemplates(_selectedApplicationName);
    print("$userselectedApplicationName,${widget.firstAppName}");

    // _getTemplates(userselectedApplicationName ?? firstAppName);
    // _fetchData();

    // _defaultData(userselectedApplicationName);
  }

  // Future<void> _defaultData(String? userselectedApplicationName) async {
  //   try {
  //     print("before defailtapp");
  //     final defaultApp = await defaultData();
  //     print("after defailtapp");
  //     setState(() {
  //       print("in setstate defailtapp");
  //       _selectedApplicationName =
  //           userselectedApplicationName ?? defaultApp!['applicationName'];
  //       print("${defaultApp!['applicationName']}");
  //     });
  //   } catch (e) {
  //     // Handle the error here
  //     print(e);
  //     // _selectedApplicationName = firstAppName;
  //   }
  // }

  Future<void> _getTemplates(String? _selectedApplicationName) async {
    ChatDetailsController _chatDetailsController =
        ChatDetailsController(context);
   // await _chatDetailsController.socketReconnection(); //for reconnecting
    try {
      final templates = await getTemplates(_selectedApplicationName);
      if (mounted) {
        setState(() {
          _templates = templates;
          print("templates added \n\n\n\n\n\n\n\\n\n\n\\n\n $_templates");
        });
      }
    } catch (e) {
      // Handle the error here
      print(e);
      // _selectedApplicationName = firstAppName;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    ChatController().clearTimes();
    GlobalChatNumbers.clearAppName();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appBar: AppBar(
         // flexibleSpace:
          //     Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          //   // Expanded(
          //   //   child: TabBar(
          //   //     controller: _tabController,
          //   //     tabs: tabs,
          //   //   ),
          //   // ),
          // ]),
//),
        body: Obx(() => Container(child:      NewRequestPage(
                    firstAppName: widget.firstAppName,
                    chatModel: ChatController.newRequestList.value,
                    templates: _templates,
                    leadController: leadController,
                    applicationNames: widget.applicationNames,
                    chatModels: ChatController.newRequestList),
              // child: TabBarView(controller: _tabController, children: [
              //   MyChatPage(
              //       firstAppName: widget.firstAppName,
              //       chatModel: ChatController.myChatList.value,
              //       leadController: leadController,
              //       fromActive: true),
              //   NewRequestPage(
              //       firstAppName: widget.firstAppName,
              //       chatModel: ChatController.newRequestList.value,
              //       templates: _templates,
              //       leadController: leadController,
              //       applicationNames: widget.applicationNames,
              //       chatModels: ChatController.newRequestList),
              //   OtherPage(
              //     chatModel: ChatController.otherList.value,
              //     leadController: leadController,
              //     firstAppName: widget.firstAppName,
              //   ),
              // ]),
            )),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Text("this : $xyz"),
            Builder(
                builder: (context) => LayoutBuilder(
                      builder: (context, constraints) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 40),
                            width: constraints.maxWidth * 0.9,
                            child: FloatingActionButton(
                              child: Center(
                                  child: Text(
                                      '${_selectedApplicationName ?? "..."}')),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      backgroundColor: Colors.white,
                                      elevation: 214.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(
                                            color:
                                                Color.fromARGB(255, 92, 92, 92),
                                            width: 2),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Select an Application",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Roboto",
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  maxHeight: 300),
                                              child: Scrollbar(
                                                thumbVisibility: true,
                                                controller: _scrollController,
                                                child: ListView.builder(
                                                  controller: _scrollController,
                                                  shrinkWrap: true,
                                                  itemCount: widget
                                                      .applicationNames?.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final appName = widget
                                                            .applicationNames?[
                                                        index];

                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                          top: BorderSide(
                                                              width: 0.2,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      221,
                                                                      221,
                                                                      221)),
                                                          bottom: BorderSide(
                                                              width: 0.2,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      221,
                                                                      221,
                                                                      221)),
                                                        ),
                                                      ),
                                                      child: ListTile(
                                                        title: Row(
                                                          children: [
                                                            Text(
                                                              appName!,
                                                              style: TextStyle(
                                                                  fontSize: 16),
                                                            ),
                                                            if (appName ==
                                                                _selectedApplicationName)
                                                              Icon(Icons.check,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .secondary),
                                                          ],
                                                        ),
                                                        onTap: () {
                                                          if (mounted) {
                                                            setState(() {
                                                              _selectedApplicationName =
                                                                  appName;

                                                              sharedPrefsHelper
                                                                  .setUserSelectedChatBot(
                                                                      clientGroupName,
                                                                      _selectedApplicationName);
                                                              applicationController
                                                                      .text =
                                                                  _selectedApplicationName ??
                                                                      "";

                                                              _getTemplates(
                                                                  _selectedApplicationName);
                                                              print(
                                                                  "Selected application name: $_selectedApplicationName");
                                                              GlobalChatNumbers
                                                                  .clearAppName();
                                                              ChatController()
                                                                  .clearTimes();
                                                              ChatController().loadData(forcedReload: true);
                                                              

                                                            });
                                                            notifyCb();
                                                          }
                                                          Future.delayed(
                                                            Duration(
                                                                seconds: 1),
                                                            () {
                                                              ChatController().loadData(forcedReload: true);
                                                            },
                                                          );
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )),
            SizedBox(height: 10),
            // FloatingActionButton(
            //   child: Icon(Icons.refresh),
            //   onPressed: () => ChatController()
            //       .loadData(selectedApp: _selectedApplicationName),
            // ),
          ],
        ));
  }
}

// Future<List<dynamic>> fetchData(_selectedApplicationName) async {
//   String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
//   final response = await NetworkHelper().request(
//     RequestType.get,
//     Uri.parse(
//         'https://retail.snap.pe/snappe-services/rest/v1/merchants/$clientGroupName/applications/$_selectedApplicationName/conversations/1679828479/1682420479'),
//     requestBody: "",
//   );

//   if (response != null && response.statusCode == 200) {
//     return jsonDecode(response.body);
//   } else {
//     throw Exception('Failed to load data');
//   }
// }






