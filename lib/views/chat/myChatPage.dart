import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leads_manager/Controller/chat_controller.dart';
import 'package:leads_manager/Controller/leads_controller.dart';
import 'package:leads_manager/Controller/search_controller.dart';
import 'package:leads_manager/constants/networkConstants.dart';
import 'package:leads_manager/helper/socketHelper.dart';
import 'package:leads_manager/models/model_chat.dart';
import 'package:leads_manager/views/chat/chatWidget.dart';
import 'dart:async';
import '../../utils/snapPeUI.dart';
class Debouncer {
  final int milliseconds;
  late VoidCallback action; // Marking action as late since it's initialized in the run method
  late Timer _timer; // Marking _timer as late since it's initialized in the run method

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    this.action = action; // Assigning the action to the class field
    if (_timer.isActive) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), () {
      this.action(); // Invoking the stored action after the delay
    });
  }
}
class MyChatPage extends StatefulWidget {
  final List<ChatModel> chatModel;
  final LeadController leadController;
  final bool fromActive;
  final String? firstAppName;
  const MyChatPage(
      {Key? key,
      required this.chatModel,
      required this.leadController,
      required this.fromActive,
      this.firstAppName})
      : super(key: key);

  @override
  State<MyChatPage> createState() => _MyChatPageState();
}

class _MyChatPageState extends State<MyChatPage> {
  final textController = TextEditingController();
  SearchController searchController = SearchController();
final _debouncer = Debouncer(milliseconds: 500);
bool isloading =false;
Timer? _debounce;
  @override
  void initState() {
    print("loading is startes");
    super.initState();
    Future.delayed(Duration.zero, () async {
      if (mounted) {
         //testforcereload
       // await ChatController().loadData(forcedReload: true);
      }
    });
// EasyLoading.show(status: 'Loading...');
//     Future.delayed(Duration(seconds: 10), () {
//       EasyLoading.dismiss();
//     });
  }
@override
void dispose() {
    _debounce?.cancel();
    super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return material.RefreshIndicator(
      onRefresh: () {

        return 
        
        Future.delayed(
          Duration(seconds: 0),
          () {
            ChatController().loadData(forcedReload: true);
          },
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoSearchTextField(
              controller: textController,
              placeholder: "Search chat with name or number ",
              decoration: SnapPeUI().searchBoxDecorationForChat(),
                          onSubmitted: (keyword) {
                  searchController.filterChat(widget.chatModel, keyword);
    
         
              },
              onChanged: (keyword){
if(keyword==""){
  searchController.filterChat(widget.chatModel, keyword);
}}
          
            ),
          ),
          Expanded(
            child: Container(child: Obx(() {
              return (searchController.filterChatList.value.length == 0 &&
                      textController.text.isEmpty)
                  ? (widget.chatModel.length > 0
                      ?isloading
                ? Center(child:material.CircularProgressIndicator()) // Show loading indicator while items are being built
               : ListView.builder(
                        itemCount: widget.chatModel.length,
                        itemBuilder: ((context, index) {
                          return ChatWidget(
                            firstAppName: widget.firstAppName,
                            chatModel: widget.chatModel[index],
                            leadController: widget.leadController,
                            fromActive: widget.fromActive,
                          );
                        }),
                       ) // : FutureBuilder(
                //     future: Future.delayed(Duration.zero),
                //     builder: (context, snapshot) {
                //       return ListView.builder(
                //         itemCount: widget.chatModel.length,
                //         itemBuilder: ((context, index) {
                //           return ChatWidget(
                //             firstAppName: widget.firstAppName,
                //             chatModel: widget.chatModel[index],
                //             leadController: widget.leadController,
                //             fromActive: widget.fromActive,
                //           );
                //         }),
                //       );
                //     },
                //   )
                      : Center(
                          child: Text(
                          'NO ACTIVE CHATS !',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
                        )))
                  : (searchController.filterChatList.length > 0
                      ? ListView.builder(
                          itemCount: searchController.filterChatList.length,
                          itemBuilder: ((context, index) {
                            return ChatWidget(
                                firstAppName: widget.firstAppName,
                                chatModel:
                                    searchController.filterChatList[index],
                                leadController: widget.leadController,
                                fromActive: widget.fromActive);
                          }))
                      : Center(
                          child: Text(
                          'NO ACTIVE CHATS !',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
                        )));
            })),
          ),
        ],
      ),
    );
  }
}































// import 'dart:async';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart' as material;
// import 'package:get/get.dart';
// import 'package:leads_manager/Controller/chat_controller.dart';
// import 'package:leads_manager/Controller/leads_controller.dart';
// import 'package:leads_manager/Controller/search_controller.dart';
// import 'package:leads_manager/constants/networkConstants.dart';
// import 'package:leads_manager/helper/socketHelper.dart';
// import 'package:leads_manager/models/model_chat.dart';
// import 'package:leads_manager/views/chat/chatWidget.dart';

// import '../../utils/snapPeUI.dart';

// class MyChatPage extends StatefulWidget {
//   final List<ChatModel> chatModel;
//   final LeadController leadController;
//   final bool fromActive;
//   const MyChatPage(
//       {Key? key,
//       required this.chatModel,
//       required this.leadController,
//       required this.fromActive})
//       : super(key: key);

//   @override
//   State<MyChatPage> createState() => _MyChatPageState();
// }

// class _MyChatPageState extends State<MyChatPage> {
//   List<Stream<String>> newMessageStreams = [];
//   final newMessageCountController =
//       StreamController<Map<String, int>>.broadcast();

//   Map<String, int> newMessageCounts = {};
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(Duration.zero, () async {
//       await ChatController().loadData();
//     });
//     newMessageStreams = widget.chatModel
//         .map((chat) => getNewMessageStream(chat.customerNo))
//         .toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final textController = TextEditingController();
//     SearchController searchController = SearchController();
//     return material.RefreshIndicator(
//       onRefresh: () {
//         return Future.delayed(
//           Duration(seconds: 1),
//           () {
//             ChatController().loadData();
//           },
//         );
//       },
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: CupertinoSearchTextField(
//               controller: textController,
//               placeholder: "Search chat with name or number",
//               decoration: SnapPeUI().searchBoxDecorationForChat(),
//               onChanged: (keyword) {
//                 searchController.filterChat(widget.chatModel, keyword);
//               },
//             ),
//           ),
//           Expanded(
//             child: Container(child: Obx(() {
//               // // Sort the chatModel list based on the lastTs property
//               // chatModel.sort((a, b) {
//               //   if (a.lastTs != null && b.lastTs != null) {
//               //     return a.lastTs.compareTo(b.lastTs);
//               //   } else if (a.lastTs != null) {
//               //     return -1;
//               //   } else if (b.lastTs != null) {
//               //     return 1;
//               //   } else {
//               //     return 0;
//               //   }
//               // });

//               return searchController.filterChatList.value.length == 0 &&
//                       textController.text.isEmpty
//                   ? ListView.builder(
//                       // reverse: true,
//                       itemCount: widget.chatModel.length,
//                       itemBuilder: ((context, index) {
//                         return ChatWidget(
//                             chatModel: widget.chatModel[index],
//                             newMessageStream: newMessageStreams[index],
//                             newMessageCountController:
//                                 newMessageCountController,
//                             newMessageCounts: newMessageCounts,
//                             leadController: widget.leadController,
//                             fromActive: widget.fromActive);
//                       }))
//                   : ListView.builder(
//                       // reverse: true,
//                       itemCount: searchController.filterChatList.length,
//                       itemBuilder: ((context, index) {
//                         return ChatWidget(
//                             chatModel: searchController.filterChatList[index],
//                             newMessageStream: newMessageStreams[index],
//                             newMessageCountController:
//                                 newMessageCountController,
//                             newMessageCounts: newMessageCounts,
//                             leadController: widget.leadController,
//                             fromActive: widget.fromActive);
//                       }));
//             })),
//           ),
//         ],
//       ),
//     );
//   }

//   // Method to create a stream of new messages for a given customer number
//   Stream<String> getNewMessageStream(String customerNo) {
//     // Create a StreamController to manage the stream
//     final StreamController<String> _controller =
//         StreamController<String>.broadcast();

//     // Add a listener for new messages
//     SocketHelper.getInstance.getSocket
//         ?.on(NetworkConstants.EVENT_MESSAGE_RECEIVED, (data) async {
//       // Check if the new message is for this chat
//       if (data['destination_id'] == customerNo) {
//         // Increment the count of new messages for this chat
//         newMessageCounts[customerNo] = (newMessageCounts[customerNo] ?? 0) + 1;

//         // Add the updated count of new messages to the stream
//         newMessageCountController.add(newMessageCounts);
//         // Add the new message to the stream
//         _controller.add(data['message']);
//       }
//     });

//     // Return the stream
//     return _controller.stream;
//   }
// }
