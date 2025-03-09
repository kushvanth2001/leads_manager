import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_foreground_task/models/service_request_result.dart';
import 'package:flutter_in_store_app_version_checker/flutter_in_store_app_version_checker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:leads_manager/helper/FirebaseMessagingHelper.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:leads_manager/helper/Logshelper.dart';
import 'package:leads_manager/helper/autodailhelpr.dart';
import 'package:leads_manager/helper/callloghelper.dart';
import 'package:leads_manager/helper/chatsidshelper.dart';
import 'package:leads_manager/helper/mqttHelper.dart';
import 'package:leads_manager/themedata.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/views/chat/NewChatDetailsController.dart';
import 'package:leads_manager/views/chat/chatlistcontroller.dart';
import 'package:leads_manager/views/chat/chatscreen.dart';
import 'package:leads_manager/views/chat/chatwidgets.dart';
import 'package:leads_manager/views/dashboard/dashboard.dart';
import 'package:leads_manager/views/leads/leadfilter.dart';
import 'package:leads_manager/widgets/applicationswitchbutton.dart';

import 'package:leads_manager/widgets/phoneNumberPopup.dart';
import 'package:leads_manager/widgets/valuenotifiers.dart';
import 'package:leads_manager/widgets/vedioplayerurl.dart';
import 'package:mime/mime.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';

import 'package:leads_manager/Controller/chatDetails_controller.dart';
import 'package:app_minimizer/app_minimizer.dart';
import 'package:leads_manager/main.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leads_manager/Controller/leads_controller.dart';
import 'dart:convert';
import 'package:leads_manager/Controller/chat_controller.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/models/model_chat.dart';
import 'package:leads_manager/services/localNotificationService.dart';
import 'package:leads_manager/views/CustomDrawer.dart';
import 'package:leads_manager/views/chat/chatDetailsScreen.dart';
import 'package:leads_manager/views/chat/liveAgentScreen.dart';
import 'package:leads_manager/views/customers/customersScreen.dart';
import 'package:leads_manager/views/leads/leadsScreen.dart';
import 'package:leads_manager/views/profile/profileScreen.dart';
import 'package:leads_manager/utils/snapPeUI.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../Controller/theme_contoller.dart';
import '../ForegroundService.dart';
import '../constants/networkConstants.dart';

import 'catalogue/catalogueScreen.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'order/orderScreen.dart';
import 'package:leads_manager/models/model_application.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  FirebaseMessageHandler firebaseMessageHandler = FirebaseMessageHandler();
AppUpdateInfo? _updateInfo;

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  
  bool _flexibleUpdateAvailable = false;
  int _screenIndex = 0;

  Map<String, List<Map<String, dynamic>>> totalData = {};
  SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
  String? SaveLeadFromCalls;
  String? clientGroupName;
  String? clientPhoneNo;
  String? clientName;
  int currenttabindex=0;
  bool _isdiologeopen = false;
  String? response;
  String removenumber = "";
  MethodChannel _channel = MethodChannel('samples.flutter.dev/mqtt');
  final channel = WebSocketChannel.connect(
    Uri.parse('wss://mqtt-dev.snap.pe'),
  );
  // String? _selectedApplicationName;
  List<String?> _applicationNames = [];
  String? firstAppName;
  String? userId;
  String token='';
  WebViewController? _controller;
 // static const platform = const MethodChannel('com.example.myapp/callLog');
  final LeadController leadController = Get.find<LeadController>();
  int pausedtime = 0;
  late PersistentTabController _persistantcontroller;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
     
//     if (state == AppLifecycleState.resumed) {
//       print("stateresumed''''''''''''''''''''''''''");
//  //  await   getcalldatabytimestamp();
//      var k= SharedPrefsHelper().getProperties();

//     if(k=='Yes'){
//          // Immediately show the dialog asynchronously
//     Future.microtask(() {
//       if (!_isdiologeopen) {
//         setState(() {
//           _isdiologeopen = true;
//         });

//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return  Phonenumberpopup();
            
//           },
//         ).then((value) {
//           setState(() {
//             _isdiologeopen = false;
//           });
//         });
//       }
//     });
  
 }
    


  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  setdata() async {

    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    final SharedPreferences prefs = await _prefs;
    prefs.reload();

    String? clientGroup =
        await prefs.getString(NetworkConstants.CLIENT_GROUP_NAME);
         FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Get the token each time the application loads
    String? token = await messaging.getToken();
    print("FCM Registration Token: $token");
   var k= await sharedPrefsHelper.getFCMToken();
     await SnapPeNetworks().updateFcmInServer(token??k);

// Fluttertoast .showToast(msg: "The token is $token ",timeInSecForIosWeb: 6);
  

  }
  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
      });
    }).catchError((e) {
      showSnack(e.toString());
    });
  }

  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  void initState() {
      
    super.initState();
    initializeWebView();
    _persistantcontroller = PersistentTabController(initialIndex: 0);
    setdata();
    WidgetsBinding.instance?.addObserver(this);
    Get.put(LeadController());
    print("from home");

    checkForNewVersion();
    final LeadController leadController = LeadController();
  
    response = sharedPrefsHelper.getResponse();
    clientGroupName = sharedPrefsHelper.getClientGroupNameTest();
    final userselectedApplicationName =
        sharedPrefsHelper.getUserSelectedChatbot(clientGroupName);
       sharedPrefsHelper.getFristappName().then((value){
setState(() {
  firstAppName=value;
});
       });
    userId = sharedPrefsHelper.getMerchantUserId();
    clientPhoneNo = sharedPrefsHelper.getClientPhoneNoTest();
    clientName = sharedPrefsHelper.getClientNameTest();
     SnapPeNetworks(). leadSaveProperties();
  
 sharedPrefsHelper.getToken().then((value){
token=value??'';
 });

    // Firebase.initializeApp().whenComplete(() {
    //   print("completed");
    //   setState(() {
    //     //1. This method call when your app in terminated state and you get a notification.
    //     FirebaseMessaging.instance.getInitialMessage().then(
    //       (message) {
    //         print("FirebaseMessaging.instance.getInitialMessage,$message");
           
    //         if (message != null) {
    //              var dilarnumber=message.data['dialernumber'];
    //                      var dilarname=message.data['dialername'];
    //           print("New Notification");
    //           var mobile = message.data['title'];
    //           //var mobile = message.data['destination_id'];
    //           if (mobile != null &&dilarnumber==null) {
    //             Get.to(() => ChatDetailsScreen(
    //                 firstAppName: userselectedApplicationName ?? firstAppName,
    //                 isOther: false,
    //                 isFromLeadsScreen: false,
    //                 chatModel:
    //                     ChatModel(customerNo: message.notification?.title),
    //                 leadController: leadController,
    //                 isFromNotification: true));
    //           }

            
    //           if(dilarnumber!=null){
    //           Future.delayed(Duration(seconds: 1), () {
    //    showDialerAlertDialog(dilarnumber);});
  
    //           }
    //         }
    //       },
    //     );
    //     //2. This method only calls when app in foreground Open State
    //     FirebaseMessaging.onMessage.listen((message) {
    //            var dilarnumber=message.data['dialernumber'];
    //            var dilarname=message.data['dialername'];
    //       print(
    //           "Notification - 2. Foreground Method Called. ${message.data}${message.notification?.body},${message.notification?.title},jdsbh");
    //       // if (message.data['destination_id'] != null) {
    //       if (message.notification?.title != null && dilarnumber==null ) {
    //         print("Notification - Message Details - ${message.data['title']}");
    //         LocalNotificationService.createAndDisplayNotification(message);
    //         if (message.data['context'] == "user_accepted_request") {
    //           ChatController().loadData(forcedReload: true);
    //         }
    //       }
               
    //           if(dilarnumber!=null){
    //      showDialerAlertDialog(dilarnumber);
  
    //           }
    //     });

    //     //3.  This method only calls when app in Background or Recent Stack
    //     FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //         var dilarnumber=message.data['dialernumber'];
    //                 var dilarname=message.data['dialername'];
    //       print("Notification - 3. Background Method Called.");
    //       // if (message.data['destination_id'] != null) {
    //       if (message.notification?.title != null && dilarnumber==null) {
    //         print("Notification - Message Details - ${message.data['title']}");
    //         // LocalNotificationService.createAndDisplayNotification(message);

    //         Get.to(() => ChatDetailsScreen(
    //             firstAppName: userselectedApplicationName ?? firstAppName,
    //             isOther: false,
    //             isFromLeadsScreen: false,
    //             chatModel: ChatModel(customerNo: message.notification?.title),
    //             leadController: leadController,
    //             isFromNotification: true));
    //       }
                  
    //           if(dilarnumber!=null){
    //    showDialerAlertDialog(dilarnumber);
  
    //           }
    //     });
    //   });
    // });
    
      firebaseMessageHandler.initialize();
   // Get.put(ChatDetailsController(context));
    leadController.loadData(forcedReload: true);
    notifyCb();
    try{
     _checkPermissions(context);
     
    }catch(e){
      throw("error in checking permissionz $e");
    }
    fetchContacts().then((value) {
  // Handle the value here
  print(value);
   if(value!=null){
      sharedPrefsHelper.setContacts(value);
     }
}).catchError((error) {
  // Handle any errors here
  print(error);
});

getImeiNumber();

 ChatIdsHelper();  

Get.put(ChatListController());
Get.put(NewChatDetailsController());
_persistantcontroller.addListener(() {
      final int currentPage = _persistantcontroller.index!.round(); // Get the current page index
    if (currentPage != currenttabindex) {
      setState(() {
        currenttabindex = currentPage; // Update the index
      });
    }
});
  }

  @override
  Widget build(BuildContext context) {
    var data = jsonDecode(response ?? "{}");
    Map<String, List<String>> clientGroupFeatures = {};
    print(" first time $data");
    for (var merchant in data['merchants']) {
      String clientGroupName = merchant['clientGroupName'];
      if (!clientGroupFeatures.containsKey(clientGroupName)) {
        clientGroupFeatures[clientGroupName] = [];
      }
      if(merchant['user']['role']['name']=='Admin'){
for (var feature in merchant['user']['role']['features']) {
   clientGroupFeatures[clientGroupName]?.add(feature['name']);
}

      }else{
      for (var feature in merchant['user']['role']['features']) {

        for (var privilage in feature['privilages']){
if(privilage['displayName']=='View' && privilage['checked']==true){
 clientGroupFeatures[clientGroupName]?.add(feature['name']);
}
        }
     
      }}
    }
    //  LiveAgentScreen(
    //       applicationNames: _applicationNames, firstAppName: firstAppName)
    Map<String, Widget> featureScreens = {

     
      'LeadManagement': LeadScreen(firstAppName: firstAppName),
      'CustomerConversations':   Chatscreen(),
      'Customers': CustomersScreen(),
      'Orders': OrderScreen(),
      'SKUs': CatalogueScreen(),
'Dashboard':  WebViewScreen(controller: _controller!,),
      //@marketing
      //'Marketing': MarketingScreen(),
      // 'Profile': ProfileScreen(),
    };
    List<Widget> screens = [];
// screens.add(WebViewScreen(dashboardUrl: 'https://retail.snap.pe/merchant/dashboard', token: token));
// screens.add(Placeholder());
    for (var entry in featureScreens.entries) {
      if (entry.key == 'Profile' ||
          entry.key == 'Marketing' ||
          (clientGroupFeatures[clientGroupName]?.contains(entry.key) ??
              false)) {
        screens.add(entry.value);
      }
    }
void onConnected(MqttClientConnectionStatus status) {
  if (status.state == MqttConnectionState.connected) {
    print('Connected to MQTT broker!');
    // Additional actions upon successful connection
  } else {
    print('Failed to connect to MQTT broker.');
  }
}
    print("screens are are $SaveLeadFromCalls t");
    return PopScope(
      canPop: false,
    onPopInvokedWithResult:(isdone,value)async {
   
      FlutterAppMinimizer.minimize();
      print("mimizing the app");
    },
      child: Scaffold(

    key: _scaffoldKey,
      appBar:  (      currenttabindex == screens.length - 1)
    ? null // Remove AppBar for the last page
    :   AppBar(


      
      elevation: 0,
      title:SnapPeUI(). appLogoSmall(),
      actions: [
    

 ValueListenableBuilder<String?>(
            valueListenable: autodialPauseNotifier,
            builder: (context, showIcon, child) {
              return  showIcon=="paused"
                  ? IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () async{

                      await  AutoDialer.changeStatus(status:"restart");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Auto Diailer Restarted')),
                        );
                      },
                    )
                  : SizedBox(); // If false, return an empty space
            },
          ),]

    ),
        drawer: CustomDrawer(context: context),
        body: Container(
          child:  PersistentTabView(
              context,
              controller: _persistantcontroller,
              screens: screens,
              items: SnapPeUI()
                  .customButtomNavigation2(clientGroupFeatures, clientGroupName),
              backgroundColor:
                   Colors.white,
              
              handleAndroidBackButtonPress: true,
              resizeToAvoidBottomInset: true,
              stateManagement: true,
              navBarStyle: NavBarStyle.style3, // Choose the style here
            ),
          ),
//  floatingActionButton: ElevatedButton(onPressed: ()async{
//   await sharedPrefsHelper.setCallListId("12234");
//   print(await sharedPrefsHelper.getCallListId());
// AutoDialer.changeStatus(status:"paused",duration: 5*60);
//  },child: Text('sdcs'),),
    ));

  }
Future<void> initializeWebView() async {
      String? token = await SharedPrefsHelper().getToken();
    // Initialize WebView controller
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) async {
            await setCookies(_controller!);
            print('Loading: $url');
          },
          onPageFinished: (url) async {
          
            print('Finished loading: $url');
          },
          onWebResourceError: (error) => print('Error: $error'),
        ),
      )
      ..loadRequest(
        Uri.parse('https://retail.snap.pe/merchant/dashboard'),
        headers: {
          'Authorization': 'Bearer ${token}',
        },
      );
  }
  
 



 



     

     Future<void> _checkPermissions(BuildContext context) async {
  PermissionStatus callLogPermission = await Permission.phone.status;
  PermissionStatus storagePermission = await Permission.storage.status;
PermissionStatus notificationPermission = await Permission.notification.status;

  PermissionStatus scheduleExactAlarm =await Permission.scheduleExactAlarm.status;
   PermissionStatus ignoreBatteryOptimscheduleExactAlarmizations = await Permission.ignoreBatteryOptimizations.status;
    PermissionStatus systemAlertWindow=await Permission.systemAlertWindow.status;
print("calllogpermssiom${callLogPermission.isGranted}");
print("storageperm${storagePermission.isGranted}");
print("notification${notificationPermission.isGranted}");


Map<String,bool> permssionMap={
"Call_Log_Permssion":callLogPermission.isGranted,
"Storage_Permssion":storagePermission.isGranted,

"Notification_Permssion":notificationPermission.isGranted,
"ScheduleExactAlaram_Permssion":scheduleExactAlarm.isGranted,
"IgnoreBatteryOptimscheduleExactAlarmizations_Permssion":ignoreBatteryOptimscheduleExactAlarmizations.isGranted,
"SystemAlertWindow_Permssion":systemAlertWindow.isGranted,

};

SnapPeNetworks().postAllPermissions(permssionMap);

  if (!callLogPermission.isGranted ||  !notificationPermission.isGranted) {
    
    // Show a dialog explaining why the permissions are needed
    _showPermissionDialog(context);
  } else {
    // Permissions are already granted
  ForegroundServiceManager.startService();
    // ForegroundServiceManager.initService();
    //   ForegroundServiceManager.startService();
  }
}

void _showPermissionDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Permissions Required"),
      content: Text(
        "To proceed, the app requires access to your call logs,Storage and other Permssions  to function properly. Please grant the necessary permissions.",
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _requestPermissions();
          },
          child: Text("Continue"),
        ),
      ],
    ),
  );
}

Future<void> _requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.phone,
    Permission.storage,
    Permission.notification,
    Permission.scheduleExactAlarm,
    Permission.ignoreBatteryOptimizations,
    Permission.systemAlertWindow,
  ].request();

  bool allPermissionsGranted = statuses.values.every((status) => status.isGranted);

  

  
      PermissionStatus callLogPermission = await Permission.phone.status;
  PermissionStatus storagePermission = await Permission.storage.status;
PermissionStatus notificationPermission = await Permission.notification.status;

  PermissionStatus scheduleExactAlarm =await Permission.scheduleExactAlarm.status;
   PermissionStatus ignoreBatteryOptimscheduleExactAlarmizations = await Permission.ignoreBatteryOptimizations.status;
    PermissionStatus systemAlertWindow=await Permission.systemAlertWindow.status;
print("calllogpermssiom${callLogPermission.isGranted}");
print("storageperm${storagePermission.isGranted}");
print("notification${notificationPermission.isGranted}");


Map<String,bool> permssionMap={
"Call_Log_Permssion":callLogPermission.isGranted,
"Storage_Permssion":storagePermission.isGranted,

"Notification_Permssion":notificationPermission.isGranted,
"ScheduleExactAlaram_Permssion":scheduleExactAlarm.isGranted,
"IgnoreBatteryOptimscheduleExactAlarmizations_Permssion":ignoreBatteryOptimscheduleExactAlarmizations.isGranted,
"SystemAlertWindow_Permssion":systemAlertWindow.isGranted,

};

SnapPeNetworks().postAllPermissions(permssionMap);



  if (allPermissionsGranted) {
    ForegroundServiceManager.startService();
  //  ForegroundServiceManager.initService();
  //     ForegroundServiceManager.startService();
    // Proceed to the main part of your app
  } else {
    PermissionStatus callLogPermission = await Permission.phone.status;
  PermissionStatus storagePermission = await Permission.storage.status;

  ForegroundServiceManager.startService();
    // ForegroundServiceManager.initService();
    //   ForegroundServiceManager.startService();
    
 
    
  }
}
  Future<List<String?>?> fetchContacts() async {
    if (await Permission.contacts.request().isGranted) {
      List<Contact> contacts = await FlutterContacts.getContacts(withProperties: true);
  
      return contacts
            .where((contact) => contact.phones.isNotEmpty)
            .map((contact) => contact.phones.first.number)
            .toList();
      
    }
  }

 getImeiNumber() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  print("***${androidInfo.id}");
  SharedPrefsHelper().setmobileImeiNumberId(androidInfo.id) ;// This returns the Android ID, which is unique to the device
}
  
  Future<void> setCookies(WebViewController webViewController) async {
    String? token = await SharedPrefsHelper().getToken();
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();
    String? userId = await SharedPrefsHelper().getMerchantUserId();
    String tokenCookie =
        'document.cookie = "client_group_name=${clientGroupName}_$userId; expires=Thu, 01 Mar 3000 00:00:00 UTC; path=/";';
    String clientCookie = 'document.cookie = "token=$token; path=/";';

    // Inject cookies using JavaScript.
    await webViewController.runJavaScript(tokenCookie);
    await webViewController.runJavaScript(clientCookie);

    print("Set cookie: $tokenCookie");
    print("Set cookie: $clientCookie");
  }
}