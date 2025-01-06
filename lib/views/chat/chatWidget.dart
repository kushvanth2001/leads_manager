import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leads_manager/Controller/chat_controller.dart';
import 'package:leads_manager/Controller/leads_controller.dart';
import 'package:leads_manager/constants/colorsConstants.dart';
import 'package:leads_manager/constants/networkConstants.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/socketHelper.dart';
import 'package:leads_manager/models/model_chat.dart';
import 'package:leads_manager/views/chat/chatControllerr.dart';
import 'package:leads_manager/views/chat/chatDetailsScreen.dart';

class ChatWidget extends StatefulWidget {
  final ChatModel chatModel;

  final isOther;
  final String? firstAppName;
  final List<dynamic>? templates;
  final VoidCallback? onBack;
  final LeadController leadController;
  bool? fromActive;

  ChatWidget({
    Key? key,
    required this.chatModel,
    this.isOther = false,
    this.firstAppName,
    this.templates,
    this.onBack,
    required this.leadController,
    this.fromActive,
  }) : super(key: key);

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  ChatControllerr chatControllerr=ChatControllerr();
  String lastTsText=".";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
      // Use Get.put() with a unique tag
    // final ChatControllerr chatControllerr =
    //     Get.put(ChatControllerr(), tag: chatModel.customerNo);
    print("start chat widget");
    String? clientGroupName = SharedPrefsHelper().getClientGroupNameTest();
    var userselectedApplicationName =null;
       SharedPrefsHelper().getUserSelectedChatbot(clientGroupName).then((value){
        userselectedApplicationName=value;
       });
    print('$userselectedApplicationName, ${widget.firstAppName}');
    String applicationName = userselectedApplicationName ?? widget.firstAppName;
    final String tag = '${widget.chatModel.customerNo}_$applicationName';
    print('Putting ChatControllerr into Get with tag: $tag');
     chatControllerr =Get.put(ChatControllerr(), tag: tag);

 lastTsText = widget.chatModel.lastTs != null
        ? convertDateTimeStr(widget.chatModel.lastTs ~/ 1)
        : '';
  }
  @override
  Widget build(BuildContext context) {
  
    return Container(
      //color: Colors.white,
      child: Column(
        children: [
          Stack(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueGrey,
                  backgroundImage: AssetImage("assets/images/profile.png"),
                ),
                title: Text(
                  "${widget.chatModel.customerName == null || widget.chatModel.customerName == "" ? widget.chatModel.customerNo : widget.chatModel.customerName}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                     // color: Color.fromARGB(255, 49, 49, 49)),
                  )
                ),
                subtitle: Obx(() => chatControllerr.lastMessage.value.isNotEmpty
                    ? Text(chatControllerr.lastMessage.value, maxLines: 1)
                    : messages()),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(lastTsText,
                        style: TextStyle(
                            color: kSecondayTextcolor,
                            fontStyle: FontStyle.italic)),
                    Obx(() => chatControllerr.messageCount.value > 0
                        ? CircleAvatar(
                            radius: 15,
                            child: Text(
                                chatControllerr.messageCount.value.toString()),
                          )
                        : SizedBox.shrink()),
                  ],
                ),
                onTap: () async {
                  await resetMessageCount(widget.chatModel.customerNo, widget.firstAppName);
                  // Navigate to the ChatDetailsScreen
                  Get.to(() => ChatDetailsScreen(
                      firstAppName: widget.firstAppName,
                      chatModel: widget.chatModel,
                      isOther: widget.isOther,
                      onBack: widget.onBack,
                      leadController: widget.leadController,
                      fromActive: widget.fromActive));
                },
              ),
            ],
          ),
          Divider(
            height: 1,
          )
        ],
      ),
    );
  }

  // Future<String> getLastMessage(String customerNo) async {
  Future<void> resetMessageCount(
      String customerNo, String? firstAppName) async {
    String? appName = await SharedPrefsHelper().getSelectedChatBot();
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    String? userselectedApplicationName =
        await SharedPrefsHelper().getUserSelectedChatbot(clientGroupName);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? applicationName =
        userselectedApplicationName ?? firstAppName ?? appName;
    await prefs.setInt('newMessageCount_$customerNo$applicationName', 0);
    final String tag = '${customerNo}_$applicationName';
    final ChatControllerr chatControllerr = Get.find<ChatControllerr>(tag: tag);

    // Update the ChatController
    chatControllerr.updateChat(
        customerNo, userselectedApplicationName ?? firstAppName ?? appName!);
  }

  String convertDateTimeStr(int timestamp) {
    var format = new DateFormat('dd-MM-yy hh:mm a');
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var str = format.format(date);
    return str;
  }

  String messagesAsString() {
    String decodedText = "";
    try {
      final text = widget.chatModel.preview_message ?? "";
      decodedText = utf8.decode(latin1.encode(text));
    } catch (e) {
      print('Error decoding message: $e');
      decodedText = widget.chatModel.preview_message ?? "Default message";
    }

    // Split the decoded text into lines and take the first line
    String firstLine = decodedText.split('\n').first;

    // Return only the first 24 characters of the first line
    return firstLine.length <= 24 ? firstLine : firstLine.substring(0, 24);
  }

  Text messages() {
    String decodedText = "";
    try {
      final text = widget.chatModel.preview_message ?? "";
      decodedText = utf8.decode(latin1.encode(text));
    } catch (e) {
      print('Error decoding message: $e');
      decodedText = widget.chatModel.preview_message ?? "";
    }

    if (widget.chatModel.messages == null || widget.chatModel.messages?.length == 0) {
      print("$decodedText");
      return Text(
        decodedText,
        style:
            TextStyle(color: kSecondayTextcolor, fontStyle: FontStyle.normal),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Text(
      decodedText,
      style: TextStyle(color: kSecondayTextcolor, fontStyle: FontStyle.normal),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

















































































































// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:leads_manager/Controller/chat_controller.dart';
// import 'package:leads_manager/Controller/leads_controller.dart';
// import 'package:leads_manager/constants/colorsConstants.dart';
// import 'package:leads_manager/constants/networkConstants.dart';
// import 'package:leads_manager/helper/socketHelper.dart';
// import 'package:leads_manager/models/model_chat.dart';
// import 'package:leads_manager/views/chat/chatDetailsScreen.dart';

// class ChatWidget extends StatelessWidget {
//   final ChatModel chatModel;
//   final Stream<String>? newMessageStream;
//   final StreamController<Map<String, int>>? newMessageCountController;
//   final Map<String, int>? newMessageCounts;
//   final isOther;
//   final String? firstAppName;
//   final List<dynamic>? templates;
//   final VoidCallback? onBack;
//   final LeadController leadController;
//   bool? fromActive;
//   // Create an instance of ChatController
//   final ChatController chatController = Get.find<ChatController>();
//   // Create a Map to store the count of new messages for each chat
//   // final newMessageCountController = StreamController<Map<String, int>>();
//   // Map<String, int> newMessageCounts = {};

//   ChatWidget({
//     Key? key,
//     required this.chatModel,
//     this.newMessageStream,
//     this.newMessageCountController,
//     this.newMessageCounts,
//     this.isOther = false,
//     this.firstAppName,
//     this.templates,
//     this.onBack,
//     required this.leadController,
//     this.fromActive,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     String lastTsText = chatModel.lastTs != null
//         ? convertDateTimeStr(chatModel.lastTs ~/ 1)
//         : '';
//     return Container(
//       color: Colors.white,
//       child: Column(
//         children: [
//           Stack(
//             children: [
//               ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: Colors.blueGrey,
//                   backgroundImage: AssetImage("assets/images/profile.png"),
//                 ),
//                 title: Text(
//                   "${chatModel.customerName == null || chatModel.customerName == "" ? chatModel.customerNo : chatModel.customerName}",
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Color.fromARGB(255, 49, 49, 49)),
//                 ),
//                 subtitle: StreamBuilder<String>(
//                   stream: newMessageStream,
//                   builder: (context, snapshot) {
//                     // If a new message is received, display it as the subtitle
//                     if (snapshot.hasData) {
//                       return Text(snapshot.data!);
//                     }
//                     // Otherwise, display the preview_message as the subtitle
//                     else {
//                       return messages();
//                     }
//                   },
//                 ),
//                 trailing: StreamBuilder<Map<String, int>>(
//                   stream: newMessageCountController?.stream,
//                   builder: (context, snapshot) {
//                     final newMessageCounts = snapshot.data ?? {};
//                     return Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Text(lastTsText,
//                             style: TextStyle(
//                                 color: kSecondayTextcolor,
//                                 fontStyle: FontStyle.italic)),
//                         if (newMessageCounts[chatModel.customerNo] != null &&
//                             newMessageCounts[chatModel.customerNo]! > 0)
//                           CircleAvatar(
//                             radius: 10,
//                             child: Text(
//                                 newMessageCounts[chatModel.customerNo]!
//                                     .toString(),
//                                 style: TextStyle(fontSize: 12)),
//                           ),
//                       ],
//                     );
//                   },
//                 ),
//                 onTap: () async {
//                   // Navigate to the ChatDetailsScreen
//                   Get.to(() => ChatDetailsScreen(
//                       firstAppName: firstAppName,
//                       chatModel: chatModel,
//                       isOther: isOther,
//                       onBack: onBack,
//                       leadController: leadController,
//                       fromActive: fromActive));
//                   // Clear the unread message count for this customer number
//                   newMessageCounts?[chatModel.customerNo] = 0;
//                   if (newMessageCounts != null) {
//                     Map<String, int> nonNullNewMessageCounts =
//                         newMessageCounts!;
//                     newMessageCountController?.add(nonNullNewMessageCounts);
//                   }
//                 },
//               ),
//             ],
//           ),
//           Divider(
//             height: 1,
//           )
//         ],
//       ),
//     );
//   }

//   String convertDateTimeStr(int timestamp) {
//     var format = new DateFormat('dd-MM-yy hh:mm a');
//     var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
//     var str = format.format(date);
//     return str;
//   }

//   Text messages() {
//     String decodedText = "";
//     try {
//       final text = chatModel.preview_message ?? "";
//       decodedText = utf8.decode(latin1.encode(text));
//     } catch (e) {
//       print('Error decoding message: $e');
//       decodedText = chatModel.preview_message ?? "";
//     }

//     if (chatModel.messages == null || chatModel.messages?.length == 0) {
//       print("$decodedText");
//       return Text(
//         decodedText,
//         style:
//             TextStyle(color: kSecondayTextcolor, fontStyle: FontStyle.normal),
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//       );
//     }
//     return Text(
//       decodedText,
//       style: TextStyle(color: kSecondayTextcolor, fontStyle: FontStyle.normal),
//       maxLines: 1,
//       overflow: TextOverflow.ellipsis,
//     );
//   }

//   // // Method to create a stream of new messages for a given customer number
//   // Stream<String> getNewMessageStream(String customerNo) {
//   //   // Create a StreamController to manage the stream
//   //   final StreamController<String> _controller = StreamController<String>();

//   //   // Add a listener for new messages
//   //   SocketHelper.getInstance.getSocket
//   //       ?.on(NetworkConstants.EVENT_MESSAGE_RECEIVED, (data) async {
//   //     // Check if the new message is for this chat
//   //     if (data['destination_id'] == customerNo) {
//   //       // Increment the count of new messages for this chat
//   //       newMessageCounts[customerNo] = (newMessageCounts[customerNo] ?? 0) + 1;

//   //       // Add the updated count of new messages to the stream
//   //       newMessageCountController.add(newMessageCounts);
//   //       // Add the new message to the stream
//   //       _controller.add(data['message']);
//   //     }
//   //   });

//   //   // Return the stream
//   //   return _controller.stream;
//   // }
// }







































































































































































// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:leads_manager/Controller/chat_controller.dart';
// import 'package:leads_manager/Controller/leads_controller.dart';
// import 'package:leads_manager/constants/colorsConstants.dart';
// import 'package:leads_manager/constants/networkConstants.dart';
// import 'package:leads_manager/helper/socketHelper.dart';
// import 'package:leads_manager/models/model_chat.dart';
// import 'package:leads_manager/views/chat/chatDetailsScreen.dart';

// class ChatWidget extends StatefulWidget {
//   final ChatModel chatModel;
//   final Stream<String>? newMessageStream;
//   final StreamController<Map<String, int>>? newMessageCountController;
//   final Map<String, int>? newMessageCounts;
//   final isOther;
//   final String? firstAppName;
//   final List<dynamic>? templates;
//   final VoidCallback? onBack;
//   final LeadController leadController;
//   bool? fromActive;

//   ChatWidget({
//     Key? key,
//     required this.chatModel,
//     this.newMessageStream,
//     this.newMessageCountController,
//     this.newMessageCounts,
//     this.isOther = false,
//     this.firstAppName,
//     this.templates,
//     this.onBack,
//     required this.leadController,
//     this.fromActive,
//   }) : super(key: key);

//   @override
//   State<ChatWidget> createState() => _ChatWidgetState();
// }

// class _ChatWidgetState extends State<ChatWidget> {
//   final ChatController chatController = Get.find<ChatController>();

//   @override
//   void initState() {
//     super.initState();
//     loadData();
//   }

//   Future<void> loadData() async {
//     await Future.delayed(Duration.zero);
//     await ChatController().loadData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     String lastTsText = widget.chatModel.lastTs != null
//         ? convertDateTimeStr(widget.chatModel.lastTs ~/ 1)
//         : '';
//     return FutureBuilder(
//       future: loadData(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return CircularProgressIndicator(); // Show loading indicator
//         } else {
//           return Container(
//             color: Colors.white,
//             child: Column(
//               children: [
//                 Stack(
//                   children: [
//                     ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor: Colors.blueGrey,
//                         backgroundImage:
//                             AssetImage("assets/images/profile.png"),
//                       ),
//                       title: Text(
//                         "${widget.chatModel.customerName == null || widget.chatModel.customerName == '' ? widget.chatModel.customerNo : widget.chatModel.customerName}",
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Color.fromARGB(255, 49, 49, 49),
//                         ),
//                       ),
//                       subtitle: StreamBuilder<String>(
//                         stream: widget.newMessageStream,
//                         builder: (context, snapshot) {
//                           if (snapshot.hasData) {
//                             return Text(snapshot.data!);
//                           } else {
//                             return messages();
//                           }
//                         },
//                       ),
//                       trailing: StreamBuilder<Map<String, int>>(
//                         stream: widget.newMessageCountController?.stream,
//                         builder: (context, snapshot) {
//                           final newMessageCounts = snapshot.data ?? {};
//                           return Column(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               Text(lastTsText,
//                                   style: TextStyle(
//                                       color: kSecondayTextcolor,
//                                       fontStyle: FontStyle.italic)),
//                               if (newMessageCounts[
//                                           widget.chatModel.customerNo] !=
//                                       null &&
//                                   newMessageCounts[
//                                           widget.chatModel.customerNo]! >
//                                       0)
//                                 CircleAvatar(
//                                   radius: 10,
//                                   child: Text(
//                                     newMessageCounts[
//                                             widget.chatModel.customerNo]!
//                                         .toString(),
//                                     style: TextStyle(fontSize: 12),
//                                   ),
//                                 ),
//                             ],
//                           );
//                         },
//                       ),
//                       onTap: () async {
//                         Get.to(() => ChatDetailsScreen(
//                               firstAppName: widget.firstAppName,
//                               chatModel: widget.chatModel,
//                               isOther: widget.isOther,
//                               onBack: widget.onBack,
//                               leadController: widget.leadController,
//                               fromActive: widget.fromActive,
//                             ));
//                         widget.newMessageCounts?[widget.chatModel.customerNo] =
//                             0;
//                         if (widget.newMessageCounts != null) {
//                           Map<String, int> nonNullNewMessageCounts =
//                               widget.newMessageCounts!;
//                           widget.newMessageCountController
//                               ?.add(nonNullNewMessageCounts);
//                         }
//                       },
//                     ),
//                   ],
//                 ),
//                 Divider(
//                   height: 1,
//                 )
//               ],
//             ),
//           );
//         }
//       },
//     );
//   }

//   String convertDateTimeStr(int timestamp) {
//     var format = new DateFormat('dd-MM-yy hh:mm a');
//     var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
//     var str = format.format(date);
//     return str;
//   }

//   Text messages() {
//     String decodedText = "";
//     try {
//       final text = widget.chatModel.preview_message ?? "";
//       decodedText = utf8.decode(latin1.encode(text));
//     } catch (e) {
//       print('Error decoding message: $e');
//       decodedText = widget.chatModel.preview_message ?? "";
//     }

//     if (widget.chatModel.messages == null ||
//         widget.chatModel.messages?.length == 0) {
//       print("$decodedText");
//       return Text(
//         decodedText,
//         style:
//             TextStyle(color: kSecondayTextcolor, fontStyle: FontStyle.normal),
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//       );
//     }
//     return Text(
//       decodedText,
//       style: TextStyle(color: kSecondayTextcolor, fontStyle: FontStyle.normal),
//       maxLines: 1,
//       overflow: TextOverflow.ellipsis,
//     );
//   }
// }
