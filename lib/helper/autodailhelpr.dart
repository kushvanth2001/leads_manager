import 'dart:async';
import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:leads_manager/domainvariables.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/mqttHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:leads_manager/widgets/valuenotifiers.dart';

class AutoDialer {
  static Timer? _timer;

  static void startDialer() async{
    if(_timer==null){
 String? calllistid = await SharedPrefsHelper().getCallListId();

if(calllistid!=null){
    _timer = Timer.periodic(Duration(seconds: 30), (Timer timer) async {
      String agent_user_id = await SharedPrefsHelper().getMerchantUserId();
      String merchant_name = await SharedPrefsHelper().getMerchantName();
     
      var payload = jsonEncode({
        "callRequestId": calllistid,
        "agent_user_id": agent_user_id,
        "status": "initiated"
      });
      await MqttManager.publishMessage(
          "call/call_status/${merchant_name}/${agent_user_id}", payload);
    });
    }else{
      print("The CallListId is Not Intilized");
    }
    }
  }

  static postDailerStatus({int duration = 0, bool ispaused = false}) async {
    String? calllistid = await SharedPrefsHelper().getCallListId();
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    String merchant_name = await SharedPrefsHelper().getMerchantName();

    if (calllistid != null) {
      final response = await NetworkHelper().request(
        RequestType.put,
        Uri.parse(
            'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/${merchant_name}/autodial/status'),
        requestBody: jsonEncode({
          "agent_user_id":calllistid,
          "status": ispaused ? "paused" : "restart",
          ispaused ? "duration" : duration: null
        }),
      );
      if (response != null && response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return true;
      } else {
        throw Exception('Failed to change the status of the AutoDailer');
      }
    } else {
      Fluttertoast.showToast(msg: "CallListId is not initilized");
    }
  }

  static changeStatus({String status = "",int duration =0}) async {
    String? calllistid = await SharedPrefsHelper().getCallListId();
    String agent_user_id = await SharedPrefsHelper().getMerchantUserId();
    String merchant_name = await SharedPrefsHelper().getMerchantName();
    if (calllistid != null) {
      stopDialer();
      var payload = jsonEncode({
        "callRequestId": calllistid,
        "agent_user_id": agent_user_id,
        "status": status,
      status=="paused"? "duration":duration:null,
      });
      await MqttManager.publishMessage("call/call_status/${merchant_name}/${agent_user_id}", payload);
      
      status == "restart" ? startDialer() : null;
      if(status=="restart" || status=="paused"){
postDailerStatus(duration: 0,ispaused:status == "paused" ? true: false );
autodialPauseNotifier.value=status;
      }

    } else {
      Fluttertoast.showToast(msg: "The CallRequestId was Returned as Empty ");
    }
  }

  static void stopDialer() {
    _timer?.cancel();
    _timer = null;
  }
}
