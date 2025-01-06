import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:leads_manager/Controller/chatDetails_controller.dart';
import 'package:leads_manager/helper/autodailhelpr.dart';
import 'package:leads_manager/helper/chatsidshelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:leads_manager/models/model_leadsource.dart';
import 'package:leads_manager/views/chat/NewChatDetailsController.dart';
import 'package:leads_manager/views/chat/chatlistcontroller.dart';
import 'package:video_player/video_player.dart';

import '../models/model_CreateNote.dart' hide Documents;
import 'package:app_links/app_links.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_in_store_app_version_checker/flutter_in_store_app_version_checker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:leads_manager/Controller/chat_controller.dart';
import 'package:leads_manager/firebase_options.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/models/model_lead.dart'; 
import 'package:leads_manager/themedata.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/views/leads/leadDetails/leadDetails.dart';
import 'package:leads_manager/views/leads/leadsWidget.dart';
import 'package:flutter/foundation.dart';
import '../../../domainvariables.dart';
import 'package:call_log/call_log.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:leads_manager/Controller/leads_controller.dart';
import 'package:leads_manager/Controller/switch_controller.dart';
import 'package:leads_manager/Controller/theme_contoller.dart';
import 'package:leads_manager/constants/colorsConstants.dart';
import 'package:leads_manager/helper/callloghelper.dart';
import 'package:leads_manager/helper/mqttHelper.dart';
import 'package:leads_manager/utils/snapPeRoutes.dart';
import 'package:leads_manager/views/chat/chatControllerr.dart';
import 'package:leads_manager/views/chat/chatEntered.dart';
import 'package:leads_manager/views/home.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'views/catalogue/categoryScreen.dart';
import 'views/entry/Registration.dart';
import 'views/entry/login.dart';
import 'views/entry/loginWithPwd.dart';
import 'views/entry/splashScreen.dart';
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}
@pragma('vm:entry-point')
void backgroundMain() {
  WidgetsFlutterBinding.ensureInitialized();
  print("background main");
  print("background main is called at ");
  const MethodChannel _channel = MethodChannel('com.leads.manager/service');

  _channel.setMethodCallHandler((MethodCall call) async {
    if (call.method == 'backgroundMainMethod') {
      
  await SharedPrefsHelper().init();
      // Implement the method that Kotlin is invoking
      print('Method "backgroundMainMethod" called from Android!');
      getcalldatabytimestamp();
      return "Success";
    } else if (call.method == "sendnote") {
      await SharedPrefsHelper().init();
      Map<String, dynamic> arguments =
          Map<String, dynamic>.from(call.arguments);

      final int leadId = int.tryParse(arguments['leadid']) ?? 0;
      final String text = arguments['text'];

      addnote(leadId, text);
    } else if (call.method == "Immediate_save") {
      await SharedPrefsHelper().init();
      WidgetsFlutterBinding.ensureInitialized();
        await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
      await SharedPrefsHelper().init();
      Map<String, dynamic> arguments =
          Map<String, dynamic>.from(call.arguments);

      String mobilenumber = arguments['mobilenumber'];
      postLead(mobilenumber);
    }else if(call.method=="ignore_number"){
  await SharedPrefsHelper().init();
      WidgetsFlutterBinding.ensureInitialized();
        await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
      await SharedPrefsHelper().init();
      Map<String, dynamic> arguments =
          Map<String, dynamic>.from(call.arguments);

      String mobilenumber = arguments['mobilenumber'];
  String? oldval= SharedPrefsHelper().getIgnoreNumProperties();

if (oldval!=null && oldval!=''){

oldval= "$oldval,$mobilenumber";
await SharedPrefsHelper().setIgnoreNumProperties(oldval);
SharedPrefsHelper.prefs.reload();
}else{
  oldval=mobilenumber;
  await SharedPrefsHelper().setIgnoreNumProperties(oldval);
  SharedPrefsHelper.prefs.reload();
}
        
        print(oldval);
                          var  properties = [
                   {
  "status": "OK",
  "messages": [],
  "propertyName": "numbers_to_be_ignored_after_call",
  "propertyType": "client_user_attributes",
  "name": "Numbers to be Ignored",
  "id": 22768173,
  "propertyValue": oldval,
  "propertyAllowedValues": null,
  "propertyDefaultValues": null,
  "isEditable": true,
  "remarks": "<p>These are the value that need to be ignored after the call</p>",
  "category": null, 
  "isVisibleToClient": null,
  "interfaceType": null,
  "pricelistCode": null
}
                        ];
                      
    SnapPeNetworks().changeProperty(properties);
    } 
    
    else {
      throw MissingPluginException('Not implemented');
    }
  });
}

Future<void> main(List<String> args) async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SharedPrefsHelper().init();
  
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
 


    Get.put(LeadController());


  //  Get.put(ChatControllerr());
   // Get.put(ChatController());
 FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    runApp(MyApp());
    Themes.easyloadingsetup();
    
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
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

  bool allPermissionsGranted =
      statuses.values.every((status) => status.isGranted);

  if (allPermissionsGranted) {
    print("All permissions granted");
    // Proceed to the main part of your app
  } else {
    // Handle the case when some permissions are denied
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;

  StreamSubscription<Uri>? _linkSubscription;
  @override
  void initState() {
    initDeepLinks();
    GlobalChatNumbers.clearAppName();

    super.initState();
    Timer(Duration(seconds: 5), () {
      SharedPrefsHelper().settostaccisbility(true);
    });

    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    // Remove the WidgetsBindingObserver
    WidgetsBinding.instance!.removeObserver(this);

    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle links
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('onAppLink: $uri');

      // Future.delayed(Duration(seconds: 1), () {
      //   final leadId = int.tryParse(uri.pathSegments.last);
      //   if (leadId != null) {
      //     Get.to(
      //       LeadDetails(
      //         lead: Lead(id: leadId),
      //         isNewLead: false,
      //       ),
      //     );
      //   }
      // });
    });
  }

  void openAppLink(Uri uri) {
    // _navigatorKey.currentState?.pushNamed(uri.fragment);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: kStatusBarColor,
        systemNavigationBarColor: kNavigationBarColor,
      ),
      child: GetMaterialApp(
        theme: Themes.lightthemedata,
        themeMode: ThemeMode.light,
        onGenerateRoute: (settings) {
          // Handle deep links here

          Uri? uri = Uri.tryParse(settings.name ?? '');

          // If the deep link matches the pattern for lead details
          if (uri != null &&
              uri.pathSegments.isNotEmpty &&
              uri.pathSegments.length > 1) {
            if (uri.pathSegments[1] == 'leaddetails') {
              if (uri.pathSegments.length > 2) {
                if (uri.pathSegments[2] != "Immediate_save") {
                  final leadId = int.tryParse(uri.pathSegments[2]);
                  if (leadId != null) {
                    return MaterialPageRoute(
                      builder: (context) => LeadDetails(
                        lead: Lead(id: leadId),
                        isNewLead: false,
                      ),
                    );
                  }
                } else {
                  final mobilenumber = uri.pathSegments[3];
                  print("url path segments${uri.pathSegments[3]}");
                  if (mobilenumber != null) {
                    return MaterialPageRoute(
                      builder: (context) => LeadDetails(
                          lead: Lead(
                              mobileNumber:
                                  isValidIndianMobileNumber(mobilenumber),
                                  leadSource: LeadSource.fromJson( {
        "status": "OK",
        "messages": [],
        "id": 26,
        "sourceName": "Phone Call"
      })
                                  
                                  ),
                          isNewLead: true,
                          dynamicCallback: (p0) async {
                            Iterable<CallLogEntry> entries =
                                await CallLog.query(
                              dateFrom: DateTime.now()
                                  .subtract(Duration(seconds: 60))
                                  .millisecondsSinceEpoch,
                              dateTo: DateTime.now().millisecondsSinceEpoch,
                              number: p0.mobileNumber,
                            );
                            List<Map<String, dynamic>> data =
                                entries.map((e) => e.toMap()).toList();
                            try {
                              for (int i = 0; i < data.length; i++) {
                                await CallLogHelper.postDataToSecondApi(
                                    data[i], p0.id.toString(), null);
                              }
                            } catch (e) {
                              print(
                                  "Error in post calllog fromlead: ${e}${p0.id}");
                            }
                            SystemNavigator.pop();
                          }),
                    );
                  }
                }
              }
            }
          }
        },
        debugShowCheckedModeBanner: false,
        initialRoute: SnapPeRoutes.splashRoute,
        builder: EasyLoading.init(),
        unknownRoute:
            GetPage(name: SnapPeRoutes.splashRoute, page: () => SplashScreen()),
        routes: {
          SnapPeRoutes.loginRoute: (context) => LogIn(),
          SnapPeRoutes.homeRoute: (context) => Home(),
          SnapPeRoutes.registrationRoute: (context) => Registration(),
          SnapPeRoutes.loginWithPwdRoute: (context) => LogInWithPwd(),
          SnapPeRoutes.splashRoute: (context) => SplashScreen(),
          SnapPeRoutes.categoryRoute: (context) => CategoryScreen(),
          SnapPeRoutes.leadDetails: (context) => LeadDetails(
                lead: Lead(),
                isNewLead: true,
              ),
        },
      ),
    );
  }
}

Future<void> twominapicall() async {
  try {
    var requestBody = {
      "user_id": await SharedPrefsHelper().getMerchantUserId() ?? 109,
      "client_group_name":
          await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads",
      "divigo_session_id": await SharedPrefsHelper().getChatSessionId() ?? "0",
      "type": "mqtt",
    };
    print("reqest" + requestBody.toString());

    String token = await SharedPrefsHelper().getToken() ?? "";
    final response = await http.post(
      Uri.parse(
          'https://${Globals.Chatbotpointer}/messenger/chatbot/rest/v1/mqtt/connection'),
      body: jsonEncode(requestBody),
      headers: {'Content-Type': 'application/json', "token": token ?? ""},
    );

    if (response != null && response.statusCode == 200) {
      String chatSessionId = await SharedPrefsHelper().getChatSessionId() ?? "";
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      var k = await SharedPrefsHelper().getChatSessionId() ?? "";
      print("regiester divigo session id" + k);
    } else {
      print(response.statusCode);
      print('Failed to add customer');
      throw Exception('Failed to add customer');
    }
  } catch (e) {
    print('Exception occurred: $e');
  }
}

Future<void> notifyCb() async {
  try {
    String clientgroupname =
        await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";
    String applicationname = validateString(await SharedPrefsHelper()
            .getUserSelectedChatbot(clientgroupname)) ??
        await SharedPrefsHelper().getFristappName() ??
        "";
    String sessionid = await SharedPrefsHelper().getChatSessionId() ?? '0';
    String token = await SharedPrefsHelper().getToken() ?? "";
    final response = await http.get(
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientgroupname/conversations/$applicationname/notify-cb?session_id=$sessionid'),
      headers: {'Content-Type': 'application/json', "token": token ?? ""},
    );
    if (response != null && response.statusCode == 200) {
      print('Response Body: ${response.body}');
      var k = await SharedPrefsHelper().getFristappName() ?? "";
      print("regiester divigo session id" + k);
    } else {
      print(response.statusCode);
      print('Failed to notifycb');
      throw Exception('Failed to notify cb');
    }
  } catch (e) {
    print(e);
    throw Exception(e);
  }
}

Future<String> getReleaseVersion() async {
  final contents = await rootBundle.loadString('pubspec.yaml');
  final lines = contents.split('\n');

  for (var line in lines) {
    if (line.startsWith('version:')) {
      final version = line.split(':')[1].trim();
      return version;
    }
  }
  return 'Error: Version not found';
}

void checkForNewVersion() async {
  print('chek for new version');
  try {
    final checker = InStoreAppVersionChecker(appId: 'com.leads.manager');
    final hasUpdate = await checker.checkUpdate();
    if (hasUpdate.canUpdate) {
      Get.dialog(
        barrierDismissible: false,
        PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text('New Version Available'),
            content: Text(
                """Please try to update the app first. If the update doesn't work, uninstall the existing version from your device and reinstall it from the Play Store"""),
            actions: [
              TextButton(
                onPressed: () async{
                  Get.back();
                  try{
await InAppUpdate.checkForUpdate();
                await        InAppUpdate.performImmediateUpdate()
                            .catchError((e) {
                              print(e);
                            Fluttertoast.showToast(msg: e.toString());
                             return AppUpdateResult.inAppUpdateFailed;
                            });
                      }catch(e){
                      print(e);
                    }
                },
                child: Text('Update'),
              ),
            ],
          ),
        ),
      );
    }
  } catch (e) {
    print("version error $e");
  }
}

void _launchInstagramPlayStore() async {
  const url = 'https://play.google.com/store/apps/details?id=com.leads.manager';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Future<void> getcalldatabytimestamp() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
    if (await InternetConnectionChecker().hasConnection) {
      final SharedPrefsHelper prefsHelper = SharedPrefsHelper();
    SharedPreferences _prefs=prefsHelper.getprefsobj();
      await _prefs .reload();
      if (!_prefs.containsKey("last_call_timestamp")) {
        _prefs.setInt(
            "last_call_timestamp", DateTime.now().millisecondsSinceEpoch);
      }
      int from = _prefs.getInt("last_call_timestamp") ??
          DateTime.now().millisecondsSinceEpoch;
      int to = DateTime.now().millisecondsSinceEpoch;
      print('from:$from');
      print("to:$to");
      Iterable<CallLogEntry> entries = await CallLog.query(
        dateFrom: from,
        dateTo: to,
      );

      print('Number of call log entries: ${entries.length}');
      List<Map<String, dynamic>> l = entries.map((e) => e.toMap()).toList();
      if (l.length != 0) {
        _prefs.setInt("last_call_timestamp", l[0]["timestamp"] + 1);

        for (int i = 0; i < l.length; i++) {
          CallLogHelper.postCallsToFirstApi(l[i]);
        }
      }
    }
  } catch (e, stackTrace) {
    FirebaseCrashlytics.instance
        .recordError(e, stackTrace, reason: 'A non-fatal error occurred');
    print(e);
  }
}

String processPhoneNumber(String phoneNumber,
    {required bool removeCountryCode}) {
  if (phoneNumber.isEmpty) {
    throw ArgumentError('Phone number cannot be null or empty');
  }

  // Trim leading and trailing spaces
  phoneNumber = phoneNumber.trim();

  // Remove any non-numeric characters
  phoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

  // Return only the last 10 digits
  return phoneNumber.length <= 10
      ? phoneNumber
      : phoneNumber.substring(phoneNumber.length - 10);
}
// Future<void> initalizeservice() async {
//  // LoggerSingleton().logInfo("->Initilizing service");

//   final service = FlutterBackgroundService();
//   await service.configure(
//       iosConfiguration: IosConfiguration(),
//       androidConfiguration: AndroidConfiguration(
//           initialNotificationContent: "Capturing CallLogs",
//           onStart: servicelogic,
//           isForegroundMode: true,
//           autoStart: true,
//           autoStartOnBoot: true));
// }

// @pragma('vm:entry-point')
// servicelogic(ServiceInstance service) async {
//    DartPluginRegistrant.ensureInitialized();
//   Timer.periodic(Duration(minutes: 1,seconds: 30), (Timer timer) async {
//     print('backgroundservice is working');

//        getcalldatabytimestamp();

//   });
// }
Future<void> addnote(int? id, String text) async {
  await SnapPeNetworks()
      .createLeadNotes(id, CreateNote(remarks: "<p>$text</p>"));
}

void showDialerAlertDialog(String phoneNumber,String? name) {
  print("in the alert diolouge");
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );

  canLaunchUrl(launchUri).then((value) {

    AutoDialer.startDialer();
    if (value) {
      Get.defaultDialog(
        title: "Confirm Call",
        middleText: "Do you want to call ${name!=null? "Lead  $name - ":""} $phoneNumber?",
        textConfirm: "Yes",
        textCancel: "Exit",
        textCustom: "Pause",
        onCustom: (){

Get.back();
pauseDialog();

        },
        onConfirm: () {
          launchUrl(launchUri);

          Get.back(); 
        },
        onCancel: (){
          AutoDialer.changeStatus(status: "declined");
          Get.back();

        },


        
      );
    } else {
      print('Could not launch $launchUri');
    }
  });
}


pauseDialog(){
  
int result=5*60;
return   Get.defaultDialog(

      title: "Pause Duration",
      content: DropDownTextField(
        initialValue: result,
        dropDownList: [
DropDownValueModel(name: "5 min", value:5*60 ),
DropDownValueModel(name: "10 min", value:10*60 ),
DropDownValueModel(name: "30 min", value:30*60 ),
DropDownValueModel(name: "60 min", value:60*60 )
      ],
      
      onChanged: (value){
      result=  value.value;
      },
      ),
      textConfirm: "Yes",
      
      onConfirm: () {
Get.back();
AutoDialer.changeStatus(status: "paused",duration: result);
      },
  
    );
}

postLead(String? phoneNumber) async {
  print('inpostlead');
 
  if (phoneNumber != null && phoneNumber != "") {
    if(isValidIndianMobileNumber(phoneNumber)!=null){
    Iterable<CallLogEntry> entries = await CallLog.query(
      dateFrom:
          DateTime.now().subtract(Duration(seconds: 60)).millisecondsSinceEpoch,
      dateTo: DateTime.now().millisecondsSinceEpoch,
      number: phoneNumber,
    );
    List<Map<String, dynamic>> data = entries.map((e) => e.toMap()).toList();

    int leadid = 0;
    var clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
    var uri = Uri.parse(
        "https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/lead");
    var request = http.Request('POST', uri);
    request.headers['Content-Type'] = 'application/json';
   
    Map<String, dynamic> lead = {
      "mobileNumber": isValidIndianMobileNumber(phoneNumber),
      "leadSource": {
        "status": "OK",
        "messages": [],
        "id": 26,
        "sourceName": "Phone Call"
      }
    };
    request.body = jsonEncode(lead);
    print("request ${lead} \n\\n\n\n\\nn\\n\n/n/n");
    var response = await NetworkHelper()
        .requestwithouteasyloading(RequestType.post, uri, requestBody: request.body);
    if (response != null && response.statusCode == 200) {
      var responseJson = jsonDecode(response.body);
      leadid = responseJson["id"];

      print("this is responseJson $responseJson");
      print(data);
      final apiCalls = <Future<dynamic>>[];
      try {
        for (int i = 0; i < data.length; i++) {
          await CallLogHelper.postDataToSecondApi(
              data[i], leadid.toString(), null);
        }
      } catch (e) {
        print("Error in post calllog fromlead: $e");
      }
    } else {
      print("$request");
      throw Exception(
          'Failed to post lead $lead,$clientGroupName,$data,${response?.statusCode},');
    }
    
    }else{
      Fluttertoast.showToast(msg: "This is not a valid indian number");
    }
  }
}
