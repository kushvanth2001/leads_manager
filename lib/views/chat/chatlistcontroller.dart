import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/models/model_Chat.dart';
import 'package:leads_manager/models/model_chatlist.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/views/chat/Indetailchatscreen.dart';
import 'package:leads_manager/views/chat/NewChatDetailsController.dart';
import 'package:leads_manager/views/chat/chatwidgets.dart';

class ChatListController extends GetxController {
  // List of ChatList objects
  static RxList<ChatList> chatLists = <ChatList>[].obs;
  static RxInt currentPage = RxInt(0);
  static RxInt previoustime =
      RxInt(DateTime.now().millisecondsSinceEpoch ~/ 1000);
  static RxInt currenttime =
      RxInt(DateTime.now().millisecondsSinceEpoch ~/ 1000);
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static bool ischatdetailsScreen = false;
  ScrollController scrollController = ScrollController();
  static String? selectedApplication;
  static RxDouble disableopquicty=1.0.obs;
  static RxBool isloading = RxBool(false);
    static RxBool issccrollingup = RxBool(false);
  static RxBool iswaba = RxBool(false);
  static MethodChannel _channel = MethodChannel('samples.flutter.dev/mqtt');
  static TextEditingController searchController=TextEditingController();
  ChatListController() {
    initAsync();
    loadData(
      forcedReload: true,
    );
    scrollController.addListener(() async {
if(scrollController.offset<=0){
  disableopquicty.value=1;
}else{
  disableopquicty.value=0;
}
if (scrollController.position.userScrollDirection==ScrollDirection.forward)
 { 
  issccrollingup.value=false;
  } 

 else {issccrollingup.value=true;
  } 
      if (scrollController.position.maxScrollExtent - scrollController.offset ==
          0.0) {
        currentPage.value++;
        String? response = await SnapPeNetworks().getAllChatData(
            page: 0,
            previousTime: previoustime.value,
            currentTime: previoustime.value);
        print("this is from scroll controller $response ");

        if (response != null) {
          List<ChatList> tempChatList = (jsonDecode(response) as List)
              .map((e) => ChatList.fromJson(e))
              .toList();
          chatLists.addAll(tempChatList);
          chatLists.refresh();
          if (tempChatList.isNotEmpty) {
            print("tempChatList.isNotEmpty");
            try {
              print("previous time vlaue ${tempChatList.last.lastTs}");
              previoustime.value = tempChatList.last.lastTs.toInt();

              print(
                  "previous time vlaue from scroll wheel ${previoustime.value}");
            } catch (e) {
              print("chat erorr $e");
            }
            // Now you can use lastTimestamp in further operations
          }
        }
        print("Global page number ${currentPage.value}");
        // Future.microtask(() => loadData(

        //     ));
      }
    });

    _channel.setMethodCallHandler((call) async {
      print("-----------------Method handler called");
      switch (call.method) {
        case 'onDataReceived':
          String receivedData = call.arguments;
          print('Received data from Android: $receivedData');
          try {
            Map<String, dynamic> data = jsonDecode(receivedData);
            print("this is the data received: $data");

            if (data.containsKey('type')) {
              if (data["type"] == "customer-chat") {
                print("chatclistontroller1");
                print(data["app_name"]);
                print(selectedApplication);
                if (data["app_name"] == (selectedApplication ?? '')) {
                  print("chatclistontroller2");
                  NewChatDetailsController.onReceiveMessage(data);
                  updateChatlistonMessage(data);
            }
    // else {
    //                  final state = WidgetsBinding.instance!.lifecycleState;
                     
    // if (state == AppLifecycleState.paused) {
    //   _showNotification(data);
    // }
    //             }
              } else if (data["type"] == "delivery_event") {
                print("Delivery event was called");

                NewChatDetailsController.onDeleveryeventcalled(data);
              } else {
                print("Unknown data type received: ${data['type']}");
              }
            }
          } catch (e) {
            print("Error decoding JSON: $e");
          }
          break;
        // Add more cases as needed
        // ...
      }
    });
  }
  initAsync() async {
    var cliengroupname = await SharedPrefsHelper().getClientGroupName();
    selectedApplication =
        await SharedPrefsHelper().getUserSelectedChatbot(cliengroupname);
    iswaba.value = await selectedApplicationisWaba();
    
    const AndroidNotificationChannel channel = AndroidNotificationChannel(

      'Chat_channel', // This is your channel ID
      'Chat', // This is the name of your channel
   
      importance: Importance.max,
    );
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('drawable/logo');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: _onSelectNotification,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground);
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> loadData(
      {bool forcedReload = false, String keywords = ''}) async {
        print("keyword$keywords");
    isloading.value = true;
    forcedReload == true
        ? previoustime.value =
            DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000
        : null;

    if (forcedReload) {
      chatLists.clear();
      // isloading.value = true;
    }
    List<ChatList> list = [];

    String? response = await SnapPeNetworks().getAllChatData(
        page: currentPage.value,
        previousTime: keywords != ''
            ? (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000)
            : previoustime.value,
        currentTime: keywords != ''
            ? (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000)
            : previoustime.value,
        keyword1: keywords);

    if (response != null) {
      list = (jsonDecode(response) as List)
          .map((e) => ChatList.fromJson(e))
          .toList();
        try{
        

      

      chatLists.value=[];
      chatLists.value=list;
      chatLists.refresh();
          print(chatLists.first.customerNo.value);

      
      }catch(e){
        print('6789$e');
      }
    }

    if (chatLists.isEmpty) {
      Fluttertoast.showToast(msg: "The Message List is Empty Please Refresh ");
    }

    isloading.value = false;
  }

  void clearTimes() {
    previoustime = RxInt(DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000);
  }

  Future<void> _showNotification(Map<String, dynamic> data) async {



    
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'Chat_channel', // Use the same channel ID
      'Chat',

      importance: Importance.high,
      priority: Priority.high,

          sound:  RawResourceAndroidNotificationSound('cutom_tone'), 
          playSound: true
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '${data["destination_id"]} (${data["app_name"]})',
      data["message"],
      notificationDetails,
      payload: jsonEncode(data)
    );
  }

  void _onSelectNotification(NotificationResponse notificationResponse) async{
    if (notificationResponse.payload != null) {
      print(
          '-------------------------------------------------------------------');
          String? k=await SharedPrefsHelper().getClientGroupName();
          print("payload${notificationResponse.payload}");
         var data=jsonDecode(notificationResponse.payload??'');
            var sel=await SharedPrefsHelper().setUserSelectedChatBot(k, data['app_name']);
          Get.to(() =>Indetailchatscreen(chatinfo: ChatList(customerNo:data['destination_id'], businessNo: null, customerName: null, lastTs: DateTime.now().microsecondsSinceEpoch, multiTenantContext: null, previewMessage: null, status: null, messageCount: 0)));
    }
  }

  updateChatlistonMessage(Map<String, dynamic> data) {
    final state = WidgetsBinding.instance!.lifecycleState;
    if (state == AppLifecycleState.paused) {
      _showNotification(data);
    }
    if (chatLists.value.isNotEmpty) {
      for (int i = 0; i < chatLists.value.length; i++) {
        print(i);
        if (chatLists.value[i].customerNo.value == data["destination_id"]) {
          chatLists.value[i].previewMessage.value = data["message"];
          chatLists.value[i].messageCount.value =
              chatLists.value[i].messageCount.value + 1;
              chatLists.refresh();
        }
      }
    }
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print('-------------------------------------------------------------------');
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}
// class Indetailchatscreen extends StatefulWidget {
//   const Indetailchatscreen({super.key});

//   @override
//   State<Indetailchatscreen> createState() => _IndetailchatscreenState();
// }

// class _IndetailchatscreenState extends State<Indetailchatscreen> {
//   final List<types.Message> _messages = [];
//   final types.User _user = const types.User(id: 'user1');

//   @override
//   void initState() {
//     super.initState();
//     _loadDummyMessages();
//   }

//   void _loadDummyMessages() {
//     final random = Random();
//     for (int i = 0; i < 10; i++) {
//       final message =      types.VideoMessage(
//         size: 150,
//         author: _user,
//         createdAt: DateTime.now().millisecondsSinceEpoch + 2000,
//         id: 'video_message_1$i',
//         name: 'Video',
//         uri: 'https://cdn.pixabay.com/video/2022/04/25/115110-703528052_tiny.mp4', // Replace with your video URL
//       );
      
//          setState(() {

//       _messages.insert(0, message);
//     }); 
//     }

//   }

//   void _handleSendPressed(types.PartialText message) {
//     final textMessage =     types.VideoMessage(
//         size: 150,
//         author: _user,
//         createdAt: DateTime.now().millisecondsSinceEpoch + 2000,
//         id: 'video_message_1',
//         name: 'Video',
//         uri: 'https://cdn.pixabay.com/video/2022/04/25/115110-703528052_tiny.mp4', // Replace with your video URL
//       );

//     setState(() {
//       _messages.insert(0, textMessage);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(

//       appBar: AppBar(
//         backgroundColor: Color(0xFF040D12),
      
//         title: const Text('Chat'),
//       ),
//       body: Container(
//   decoration: BoxDecoration(
//     image: DecorationImage(
//       image: AssetImage('assets/images/bg.png'), // Replace with your image path
//       fit: BoxFit.cover, // This makes the image cover the entire background
//     ),
//   ),
//   child: Chat(
//     theme: CustomChatTheme(),
//     messages: _messages,
//     onSendPressed: _handleSendPressed,
//     user: _user,
//   ),
// ),

//     );
//   }
// }




// class CustomChatTheme extends ChatTheme {
//   const CustomChatTheme()
//       : super(
//           attachmentButtonIcon: const Icon(Icons.attach_file, color: Colors.yellow),
//           attachmentButtonMargin: const EdgeInsets.all(8),
//           backgroundColor: Colors.transparent,
//           bubbleMargin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//           dateDividerMargin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
//           dateDividerTextStyle: const TextStyle(
//             fontSize: 12,
//             color: Colors.grey,
//           ),

//           deliveredIcon: const Icon(Icons.done, size: 20, color: Colors.cyan),
//           documentIcon: const Icon(Icons.insert_drive_file, size: 20, color: Colors.brown),
//           emptyChatPlaceholderTextStyle: const TextStyle(
//             color: Colors.grey,
//             fontSize: 16,
//             fontStyle: FontStyle.italic,
//           ),
//           errorColor: Colors.red,
//           errorIcon: const Icon(Icons.error, size: 20, color: Colors.red),
//           inputBackgroundColor:const Color(0xFF040D12),
//           inputSurfaceTintColor: Colors.white,
//           inputElevation: 2.0,
//           inputBorderRadius: const BorderRadius.all(Radius.circular(20)),
        
//           inputMargin: const EdgeInsets.all(8),
//           inputPadding: const EdgeInsets.all(0),
//           inputTextColor: Colors.black,
//           inputTextCursorColor: Colors.green,
//           inputTextDecoration: const InputDecoration(
//             hintText: 'Type a message',
//             border: InputBorder.none,
//           ),
//           inputTextStyle: const TextStyle(
//             color: Colors.black,
//             fontSize: 16,
//           ),
//           messageBorderRadius: 14.0,
//           messageInsetsHorizontal: 8.0,
//           messageInsetsVertical: 8.0,
//           messageMaxWidth: 250.0,
//           primaryColor:  const Color(0xFF204F46),
//           receivedEmojiMessageTextStyle: const TextStyle(
//             fontSize: 24,
//           ),
//           receivedMessageBodyTextStyle: const TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//           ),
//           receivedMessageCaptionTextStyle: const TextStyle(
//             color: Colors.grey,
//             fontSize: 12,
//           ),
//           receivedMessageDocumentIconColor: Colors.yellowAccent,
//           receivedMessageLinkDescriptionTextStyle: const TextStyle(
//             color: Colors.lightBlue,
//             fontSize: 14,
//           ),
//           receivedMessageLinkTitleTextStyle: const TextStyle(
//             color: Colors.black12,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//           secondaryColor: Colors.grey,
//           seenIcon: const Icon(Icons.done_all, size: 20, color: Colors.green),
//           sendButtonIcon: const Icon(Icons.send, color: Colors.blue),
//           sendButtonMargin: const EdgeInsets.all(8),
//           sendingIcon: const Icon(Icons.hourglass_top, size: 20, color: Colors.grey),
//           sentEmojiMessageTextStyle: const TextStyle(
//             fontSize: 24,
//           ),
//           sentMessageBodyTextStyle: const TextStyle(
//             color: Colors.black,
//             fontSize: 16,
//           ),
//           sentMessageCaptionTextStyle: const TextStyle(
//             color: Colors.grey,
//             fontSize: 12,
//           ),
//           sentMessageDocumentIconColor: Colors.blueGrey,
//           sentMessageLinkDescriptionTextStyle: const TextStyle(
//             color: Colors.blue,
//             fontSize: 14,
//           ),
//          // WhatsApp green or any desired color.

//           sentMessageLinkTitleTextStyle: const TextStyle(
//             color: Colors.amberAccent,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//           statusIconPadding: const EdgeInsets.all(4),
//           systemMessageTheme: const SystemMessageTheme(
//           margin: EdgeInsets.all(8),
//             textStyle: TextStyle(
//               color: Colors.white,
//               fontSize: 12,
//             ),
//           ),
//           typingIndicatorTheme: const TypingIndicatorTheme(
//             animatedCirclesColor: Color(2),
//             animatedCircleSize:5,
//      bubbleBorder:BorderRadius.all(Radius.zero),
//  bubbleColor:Color(2),
//  countAvatarColor :Color(2),
//  countTextColor:Color(2),
//    multipleUserTextStyle:TextStyle(),
           
//           ),
//           unreadHeaderTheme: const UnreadHeaderTheme(
//             color: Colors.blue,
//             textStyle: TextStyle(
//               color: Colors.white,
//               fontSize: 12,
//             ),
//           ),
//           userAvatarImageBackgroundColor: Colors.blueGrey,
//           userAvatarNameColors: colors,
//           userAvatarTextStyle: const TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//           ),
//           userNameTextStyle: const TextStyle(
//             color: Colors.blue,
//             fontWeight: FontWeight.bold,
//             fontSize: 14,
//           ),
//           highlightMessageColor: Colors.blue, // Optional: Highlighted message color.
//         );
// }

// const colors = [
//   Color(0xffff6767),
//   Color(0xff66e0da),
//   Color(0xfff5a2d9),
//   Color(0xfff0c722),
//   Color(0xff6a85e5),
//   Color(0xfffd9a6f),
//   Color(0xff92db6e),
//   Color(0xff73b8e5),
//   Color(0xfffd7590),
//   Color(0xffc78ae5),
// ];