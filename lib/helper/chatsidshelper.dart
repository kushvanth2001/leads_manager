import 'dart:async';
import 'dart:convert';
import 'package:leads_manager/Controller/leads_controller.dart';
import 'package:leads_manager/domainvariables.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/mqttHelper.dart';
import 'package:leads_manager/models/model_application.dart';
import 'package:leads_manager/services/localNotificationService.dart';
import 'package:leads_manager/views/leads/leadsWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
class ChatIdsHelper {
   Timer? _timer;
  ChatIdsHelper() {
    _initialize();
  }

  static final StreamController<Map<String, dynamic>> _streamController  =StreamController.broadcast();

  Future<void> _initialize() async {
    _timer?.cancel();
var applications=await   fetchApplications();

     await SharedPrefsHelper()
        .setChatSessionId(DateTime.now().millisecondsSinceEpoch.toString());
      var   _applicationNames =
              applications.map((app) => app.applicationName).toList();
        var  firstAppName = _applicationNames[0];
       await SharedPrefsHelper().setFristappName(firstAppName??'');
        var clientgroup=await SharedPrefsHelper().getClientGroupName();
        var userselected=await SharedPrefsHelper().getUserSelectedChatbot(clientgroup);
        if(userselected==null){
          SharedPrefsHelper().setUserSelectedChatBot(firstAppName,clientgroup );
          userselected=firstAppName;
        }
          
          SharedPrefsHelper().setFristappName(firstAppName??"");
          LocalNotificationService.initializeNotifications(
              userselected, firstAppName);


       twominapicall();
  
    String chatSessionId = await SharedPrefsHelper().getChatSessionId() ?? "";
    
        await MqttManager.connectMqtt("wss://mqtt-dev.snap.pe", "$chatSessionId");


   _timer= Timer.periodic(Duration(minutes: 1), (timer) async {
      await twominapicall();
resubscribe();

    });
    
    
   

  
  }

static Future<void> twominapicall() async {
  var k= await SharedPrefsHelper().getLastCallLeadId();
if(k!=null &&k!= LeadController. lastcalledLead.value){
 LeadController. lastcalledLead.value=k;
  LeadController. lastcalledLead.refresh();

}

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
static Future<void> notifyCb() async {
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

static resubscribe()async{
 String   chatSessionId = await SharedPrefsHelper().getChatSessionId() ??'';

    await twominapicall();
      MqttManager.subscribeToTopic("$chatSessionId/delivery-event");
    
     MqttManager.subscribeToTopic("$chatSessionId/notify-dashboard");
     MqttManager.subscribeToTopic("$chatSessionId/customer-chat/customer");


}

  
  }