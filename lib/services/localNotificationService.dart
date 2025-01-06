import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:leads_manager/models/model_chatlist.dart';
import 'package:leads_manager/views/chat/Indetailchatscreen.dart';
import '../Controller/leads_controller.dart';
import '../helper/SharedPrefsHelper.dart';
import '../models/model_chat.dart';
import '../views/chat/chatDetailsScreen.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static initializeNotifications(
      userselectedApplicationName, String? appName) async {
  
    var initializationSettingsAndroid = AndroidInitializationSettings('logo');
    var initializationSettingsIOS = DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    _notificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        SharedPrefsHelper prefsHelper=SharedPrefsHelper();
      String? k=await prefsHelper.getClientGroupName();


        String? payload = response.payload;
        if (payload != null) {
        print('$payload');
         var data=jsonDecode(payload);
            var sel=prefsHelper.setUserSelectedChatBot(k, data['app_name']);
          Get.to(() =>Indetailchatscreen(chatinfo: ChatList(customerNo:data['destination_id'], businessNo: null, customerName: null, lastTs: DateTime.now().microsecondsSinceEpoch, multiTenantContext: null, previewMessage: null, status: null, messageCount: 0)));
        }
      },
    );
  }

  // static void initialize() {
  //   const InitializationSettings initializationSettings =
  //       InitializationSettings(
  //           android: AndroidInitializationSettings("@mipmap/ic_launcher"));
  //   _notificationsPlugin.initialize(
  //     initializationSettings,
  //     onSelectNotification: (payload) {
  //       print("Notification - onSelectNotification $payload");
  //       if (payload!.isNotEmpty) {
  //         // Get.to(() => ChatDetailsScreen(
  //         //       chatModel: ChatModel(customerNo: payload),
  //         //     ));
  //         print("Router $payload");
  //       }
  //     },
  //   );
  // }

  static void createAndDisplayNotification(RemoteMessage message) async {
    print("Notification - createAndDisplayNotification $message");
    try {
      // final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      int? id = message.notification?.title.hashCode;
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          "newsnappemerchant", "myFirebaseChannel",
          importance: Importance.max,
          priority: Priority.high,
          icon: 'logo',
          sound: RawResourceAndroidNotificationSound('notification'),
          playSound: true);

      var platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await _notificationsPlugin.show(
        id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
        message.notification?.title, //message.data['destination_id']
        message.notification?.body, //message.data['message']
        platformChannelSpecifics,
        payload: message.notification?.title,
        //payload:message.data['destination_id']
      );
    } on Exception catch (e) {
      print(e);
    }
  }
}





//  if (payload != null) {
//         List<ChatModel>? chatModels = ChatController.newRequestList;
//         final chatModel = chatModels.firstWhereOrNull(
//           (chat) => chat.customerNo == payload,
//         );
//         Get.to(() => ChatDetailsScreen(
//             firstAppName: userselectedApplicationName ?? appName,
//             isOther: false,
//             isFromLeadsScreen: false,
//             chatModel: chatModel,
//             leadController: leadController));
//       }