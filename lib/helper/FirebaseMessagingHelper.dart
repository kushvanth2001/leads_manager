import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:leads_manager/Controller/chat_controller.dart';
import 'package:leads_manager/Controller/leads_controller.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/main.dart';
import 'package:leads_manager/models/model_chat.dart';
import 'package:leads_manager/models/model_chatlist.dart';
import 'package:leads_manager/services/localNotificationService.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/views/chat/Indetailchatscreen.dart';
import 'package:leads_manager/views/chat/chatDetailsScreen.dart';

class FirebaseMessageHandler {
  final LeadController leadController = Get.find<LeadController>();
  FirebaseMessageHandler._privateConstructor();

  static final FirebaseMessageHandler _instance =
      FirebaseMessageHandler._privateConstructor();

  factory FirebaseMessageHandler() {
    return _instance;
  }

  void initialize() {



    Firebase.initializeApp().whenComplete(() {
      print("Firebase initialized");
      _setupFirebaseMessagingHandlers();
    });
  }
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("in bagroound message handler");
    final player = AudioPlayer();
  // Play a sound
  print("playing sund");
  await player.play(AssetSource('assets/sounds/notification.mp3'));
}
  void _setupFirebaseMessagingHandlers() {
 
    FirebaseMessaging.instance.getInitialMessage().then((message) {
           print('-t2');
      _handleMessage(message, "Terminated");

    });

    FirebaseMessaging.onMessage.listen((message) {
           print('-t4');
      _handleMessage(message, "Foreground");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('-t1');
      _handleMessage(message, "Background");
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print("FCM Registration Token Refreshed: $newToken");
      await SnapPeNetworks().updateFcmInServer(newToken);
    });

    FirebaseMessaging.instance.getToken().then((token) {
      if (token != null) {
        print("FCM Registration Token: $token");
        SnapPeNetworks().updateFcmInServer(token);
      }
    });
  }

  void _handleMessage(RemoteMessage? message, String state) async {
    if (state == "Terminated") {
      print("completed");

      //1. This method call when your app in terminated state and you get a notification.

      print("FirebaseMessaging.instance.getInitialMessage,$message");
      var clientgrpnmae = await SharedPrefsHelper().getClientGroupName() ?? "";
      var firstAppName = await SharedPrefsHelper().getFristappName();
      var userselectedapplication =
          await SharedPrefsHelper().getUserSelectedChatbot(clientgrpnmae) ??
              firstAppName;
      if (message != null) {
        if (message.data['action'] == "trigger_call") {
          var dilarnumber = message.data['dialernumber'];
          var dilarname = message.data['dialername'];
          if (dilarnumber != null) {
            Future.delayed(Duration(seconds: 1), () {
              showDialerAlertDialog(dilarnumber, dilarname);
            });
        var calllistid =message.data[ 'callRequestId'];
        calllistid!=null?SharedPrefsHelper().setCallListId(calllistid):null;
          }
        } 
          
        else {
          var mobile = message.data['title'];
          if (mobile != null) {
     print('-t5');
  //Get.to(() => Indetailchatscreen(chatinfo:ChatList(customerNo: customerNo, businessNo: businessNo, customerName: customerName, lastTs: lastTs, multiTenantContext: multiTenantContext, previewMessage: previewMessage, status: status, messageCount: messageCount)) );

            // Get.to(() => ChatDetailsScreen(
            //     firstAppName: userselectedapplication ?? firstAppName,
            //     isOther: false,
            //     isFromLeadsScreen: false,
            //     chatModel: ChatModel(customerNo: message.notification?.title),
            //     leadController: leadController,
            //     isFromNotification: true));
          }
        }
      }
    } else if (state == "Foreground") {
      var clientgrpnmae = await SharedPrefsHelper().getClientGroupName() ?? "";
      var firstAppName = await SharedPrefsHelper().getFristappName();
      var userselectedapplication =
          await SharedPrefsHelper().getUserSelectedChatbot(clientgrpnmae) ??
              firstAppName;

      if (message != null) {
        print(message.data);
        if (message.data['action'] == "trigger_call") {

          var dilarnumber = message!.data['dialernumber'];
          var dilarname = message.data['dialername'];
          print(dilarname);
          print(dilarnumber);
          if (dilarnumber != null) {
            showDialerAlertDialog(dilarnumber, dilarname);
          }
 var calllistid =message.data[   'callRequestId'];
        calllistid!=null?SharedPrefsHelper().setCallListId(calllistid):null;
        } else {
     print('-t6');
          print(
              "Notification - 2. Foreground Method Called. ${message.data}${message.notification?.body},${message.notification?.title},jdsbh");
          // if (message.data['destination_id'] != null) {
          if (message.notification?.title != null) {
            print("Notification - Message Details - ${message.data['title']}");
            LocalNotificationService.createAndDisplayNotification(message);
            if (message.data['context'] == "user_accepted_request") {
              ChatController().loadData(forcedReload: true);
            }
          }

        }
      }

    } else {
      var clientgrpnmae = await SharedPrefsHelper().getClientGroupName() ?? "";
      var firstAppName = await SharedPrefsHelper().getFristappName();
      var userselectedapplication =
          await SharedPrefsHelper().getUserSelectedChatbot(clientgrpnmae) ??
              firstAppName;
      if (message != null) {
        if (message.data['action'] == "trigger_call") {
          var dilarnumber = message!.data['dialernumber'];
          var dilarname = message.data['dialername'];
          if (dilarnumber != null) {
            showDialerAlertDialog(dilarnumber, dilarname);
          }
           var calllistid =message.data[   'callRequestId'];
        calllistid!=null?SharedPrefsHelper().setCallListId(calllistid):null;
        } else {
          print("Notification - 3. Background Method Called.");
          // if (message.data['destination_id'] != null) {
          if (message.notification?.title != null) {
            print("Notification - Message Details - ${message.data['title']}");
            // LocalNotificationService.createAndDisplayNotification(message);
     print('-t7');
            Get.to(() => ChatDetailsScreen(
                firstAppName: userselectedapplication ?? firstAppName,
                isOther: false,
                isFromLeadsScreen: false,
                chatModel: ChatModel(customerNo: message.notification?.title),
                leadController: leadController,
                isFromNotification: true));
          }
        }
      }
    }
  }
}
