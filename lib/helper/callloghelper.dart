import 'dart:convert'; // For JSON encoding/decoding

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:leads_manager/Controller/leads_controller.dart';
import 'package:leads_manager/ForegroundService.dart';
import 'package:leads_manager/main.dart';
import '../models/model_CreateNote.dart' hide Documents;
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';

import '../constants/networkConstants.dart';
import 'Logshelper.dart';
import 'SharedPrefsHelper.dart';
import 'networkHelper.dart';
import '../../../domainvariables.dart';

String convertToLowerCaseAndRemoveSpaces(String input) {
  // Convert to lowercase
  String lowercase = input.toLowerCase();

  // Remove spaces
  String result = lowercase.replaceAll(' ', '');

  return result;
}

class CallLogHelper {
  Map<String, String> statusFromSynonym = {
    'blocked': 'No response',
    'missed': 'No response',
    'unknown': 'No response',
    'voicemail': 'No response',
    'disconnected': 'Disconnected',
    'rejected': 'Disconnected',
    'answeredexternally': 'Completed',
    'incoming': 'Completed',
    'wifiincoming': 'Completed',
    'outgoing': 'Completed',
    'wifioutgoing': 'Completed',
  };
  Map<String, String> statusFromcalltype = {
    'blocked': 'Incoming',
    'missed': 'Incoming',
    'unknown': 'Incoming',
    'voicemail': 'Incoming',
    'rejected': 'Incoming',
    'answeredexternally': 'Incoming',
    'incoming': 'Incoming',
    'wifiincoming': 'Incoming',
    'outgoing': 'Outgoing',
    'wifioutgoing': 'Outgoing',
  };
  String getStatusFromSynonym(String synonym) {
    String lowercaseSynonym = convertToLowerCaseAndRemoveSpaces(synonym);
    return statusFromSynonym[lowercaseSynonym] ?? 'Unknown';
  }

  String gettaskFromSynonym(String synonym) {
    String lowercaseSynonym = convertToLowerCaseAndRemoveSpaces(synonym);
    return statusFromcalltype[lowercaseSynonym] ?? 'Unknown';
  }

  static Future<bool> postCallsToFirstApi(Map<String, dynamic> prop) async {
    // final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    // // LoggerSingleton().logInfo("Posting thwe frist api $prop");
    // final SharedPreferences prefs = await _prefs;

      SharedPrefsHelper prefshelper=SharedPrefsHelper();
      SharedPreferences _prefs=prefshelper.getprefsobj();
    print("////////posting frist api/////");
    String? clientGroup =await prefshelper.getClientGroupName();
    String? token = await prefshelper.getToken();
    
    print(
        "https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroup/filter-leads?page=0&size=20&sortBy=lastModifiedTime&sortOrder=DESC&mobileNumber=${prop['number'].contains('+') ? prop['number'].substring(1) : prop['number']}");
    var header = {"Content-Type": "application/json", "token": token ?? ""};
    var url = Uri.parse(
        "https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroup/filter-leads?page=0&size=20&sortBy=lastModifiedTime&sortOrder=DESC&mobileNumber=${prop['number'].contains('+') ? prop['number'].substring(1) : prop['number']}");

    try {
      var response = await http.get(url, headers: header);

      // Check if the response is successful (status code 200)
      if (response == null ? false : response.statusCode == 200) {
        //LoggerSingleton().logInfo('success fully posted the data to second api: ${prop}');
        // Parse the response JSON
        final Map<String, dynamic> jsonResponse =
            json.decode(response.body) as Map<String, dynamic>;
        print(jsonResponse);
        print("////////frist  api /////");
        // Check if the "lead" property is not empty
        if (jsonResponse['leads'] != null &&
            (jsonResponse['leads'] as List).isNotEmpty) {
          Map<String, dynamic> leads = (jsonResponse['leads'] as List)[0];
          print("${leads['id']}");
          bool v =await postDataToSecondApi(prop, leads['id'].toString(), leads);
          prefshelper.setleadfromnotification(jsonEncode(leads));
        
          if (v == true) {
            return true;
          } else {
            return false;
          }
          
        } else {
          try {
            Map<String, dynamic> datampa = {};
            datampa["mobilenumber"] = prop["number"];

            var canShowCallDiolougesForNotLead = await  prefshelper.canShowCallDiolougesForNotLead() ??true;;
            var canignore= checkNumberToBeIgnoredorNot( prop["number"]);
            var checkfromcontacts=await prefshelper.getneedtoCheckContactsForNumber();
            if(checkfromcontacts){
             var existed=await checkTheNumberExistsInContact(prop["number"]);
existed? checkfromcontacts=true:checkfromcontacts=false;
            }
            bool canconvertallcallsasleads =await prefshelper.getconvertAllcallsAsLeads();
       if(!canconvertallcallsasleads){
            if (canShowCallDiolougesForNotLead&&!canignore&&!checkfromcontacts) {
              ForegroundServiceManager.showNotLeadOverlayDialog(datampa);
            }}else{

   postLead(prop["number"]);


            }
          } catch (e) {
            print("unable to show the Notlead diolouge$e");
          }
       
          return true;
        }
      } else {
        //LoggerSingleton().logInfo('####FALIED TO POST calls to the first API. Status code: ${response!.statusCode}');
        print(
            'Failed to post calls to the first API. Status code: ${response!.statusCode}');
        return false;
      }
    } catch (error) {
      //throw("Error while while check in Lead or not $error");
      //LoggerSingleton().logInfo("#### ERROR IN POSTING THE FRIST API $error");
      print('Error posting calls to the first API: $error');
      return false;
    }
  }

  // Method to post data to the second API
  static Future<bool> postDataToSecondApi(Map<String, dynamic> leadData,
      String leadid, Map<String, dynamic>? respone) async {
SharedPrefsHelper prefshelper=SharedPrefsHelper();
      SharedPreferences _prefs=prefshelper.getprefsobj();
            // final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    //LoggerSingleton().logInfo('Posting the second api call $leadData');
   // final SharedPreferences prefs = await _prefs;
    if (respone != null) {
      Map<String, dynamic> k = respone;
      DateFormat dateFormat = DateFormat('hh:mm a');
      (respone["customerName"] != null && respone["customerName"] != "")
          ? k["nameormobilenumber"] = respone["customerName"]
          : k["nameormobilenumber"] = respone["mobileNumber"];
      (leadData["duration"] == null || leadData["duration"] == null)
          ? k["duration"] = "-"
          : k["duration"] = formatDuration(leadData["duration"]);
      k['timestamp'] = dateFormat.format(DateTime.fromMillisecondsSinceEpoch(
          leadData['timestamp'] ?? DateTime.now().millisecondsSinceEpoch));
      k['leadid'] = leadid;
      var ku =await prefshelper.canShowCallDiolougesForLead()??true;
      if (ku) {
        ForegroundServiceManager.showOverlayDialog(k);
      }
    }
   


    String? clientGroup = await prefshelper.getClientGroupName();  
    String? token = await prefshelper.getToken();
    String clientphno = "${ await prefshelper.getClientPhoneNo()??"91111111111"}";
      
            
    String clientname = await prefshelper.getUserName() ?? "";
    DateTime starttimeinmill =
        DateTime.fromMillisecondsSinceEpoch(leadData["timestamp"]).toUtc();
    DateTime endtime = starttimeinmill
        .add(Duration(seconds: leadData["duration"] ?? 0))
        .toUtc();
    DateFormat formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
    var body = {};
  var calllistid= await prefshelper.getCallListId();
    body = {
      "status": "OK",
      "isActive": true,
      "startTime": "${starttimeinmill.toIso8601String()}",
      "endTime": "${endtime.toIso8601String()}",
      "leadId": leadid,
      "callType": CallLogHelper().gettaskFromSynonym(leadData["callType"]),
      "statusName": leadData["duration"] == 0
          ? convertToLowerCaseAndRemoveSpaces(leadData["callType"]) == 'missed'
              ? 'Missed'
              : ' No response'
          : 'Completed',
      "fromNumber": clientphno,
      "toNumber":
          processPhoneNumber(leadData['number'], removeCountryCode: true),
      "remarks": "",
      "agentPhoneNumber": clientphno,
      "agentName": clientname,

    };
calllistid!=null?body['callRequestId']=calllistid:null;
    print(
        "https://${Globals.DomainPointer}/snappe-services-pt/rest/v1/merchants/$clientGroup/call-logs");
    var header = {"Content-Type": "application/json", "token": token ?? ""};
    var url = Uri.parse(
        "https://${Globals.DomainPointer}/snappe-services-pt/rest/v1/merchants/$clientGroup/call-logs");

    try {
      var response =
          await http.post(url, body: jsonEncode(body), headers: header);

      // Perform the second API request with leadData

      if (response == null ? false : response.statusCode == 200) {
        print("${jsonDecode(response.body)}");
        print('Data successfully posted to the second API.');
        //LoggerSingleton().logInfo('success fully posted the data to second api: ${response!.statusCode}');
        postCallLogNotification2(
            CallLogHelper().gettaskFromSynonym(leadData["callType"]),
            int.tryParse(leadid) ?? 0);

            updateLastCallLead(leadid);
        return true;
      } else {
        //LoggerSingleton().logInfo( '####FALIED TO POST calls to the second API. Status code: ${response!.statusCode}');
        return false;
      }
    } catch (error) {
      //LoggerSingleton().logInfo('####ERROR IN POSTING THE SECOND API: ${error}');
      
      print('Error posting data to the second API: $error');
      return false;
    }
  }

  static Future<bool> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true; // Connected to the internet
    } else {
      return false; // No internet connection
    }
  }
}

String capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
sendtopopup(String leadid) async {
  //  SharedPreferences _sharedprefs =
  //             await SharedPreferences.getInstance();
  //        await _sharedprefs.reload();
  //         _sharedprefs.setString("Truecallerpopup", leadid);

  //         await FlutterOverlayWindow.showOverlay(
  //           height: 1017,
  //             alignment: OverlayAlignment.center,
  //             enableDrag: false);
}
String formatDuration(int seconds) {
  final int minutes = seconds ~/ 60;
  final int remainingSeconds = seconds % 60;

  if (minutes > 0 && remainingSeconds > 0) {
    return '$minutes minute${minutes > 1 ? 's' : ''} $remainingSeconds second${remainingSeconds > 1 ? 's' : ''}';
  } else if (minutes > 0) {
    return '$minutes minute${minutes > 1 ? 's' : ''}';
  } else {
    return '$remainingSeconds second${remainingSeconds > 1 ? 's' : ''}';
  }
}

String formatTimestamp(int timestamp) {
  // Convert the timestamp to a DateTime object
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  // Format the DateTime object to a string
  String formattedTime = DateFormat('h:mm a').format(dateTime);

  return formattedTime;
}
bool checkNumberToBeIgnoredorNot(String number) {
  // Get the comma-separated numbers from preferences
  var nums=SharedPrefsHelper().getIgnoreNumProperties();
if(nums==null){
  return false;
}
  List<String> ignoreNumbers = nums?.split(',') ?? [];

  // Handle the case for empty list
  if (ignoreNumbers.isEmpty) {
    return false;
  }

  // Check if any number in the list ends with the given number
  for (String ignoreNumber in ignoreNumbers) {
    if (ignoreNumber.trim().endsWith(number)) {
      return true;
    }
  }

  // If no number matches, return false
  return false;
}
Future<bool> checkTheNumberExistsInContact(String mobileNumber) async {
  var contacts = await SharedPrefsHelper().getContacts();
  if (contacts.isEmpty) {
    return false;
  } else {
    for (var contact in contacts) {
      if (contact!.replaceAll(' ', '').endsWith(mobileNumber)) {
        return true;
      }
    }
    return false;
  }






}
updateLastCallLead(String leadid){

SharedPrefsHelper().setLastCallLeadId(leadid);
LeadController.lastcalledLead.value=leadid;
LeadController.lastcalledLead.refresh();
print(LeadController.lastcalledLead.value);
}