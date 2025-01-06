import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../domainvariables.dart';
import '../helper/SharedPrefsHelper.dart';
import '../helper/networkHelper.dart';
import '../models/model_lead.dart';
import '../utils/snapPeNetworks.dart';
import '../utils/snapPeUI.dart';
import '../views/leads/leadDetails/leadDetails.dart';
import 'leads_controller.dart';

class AppLifecycleController extends GetxController with WidgetsBindingObserver {
  
  SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
  final phoneNumbersNotifier = ValueNotifier<List<String>?>(null);
  Map<String, List<Map<String, dynamic>>> totalData = {};
  bool _isDialogOpen = false;

  Future<void> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    if (prefs.containsKey('storelocalnotlead')) {
      String jsonString = prefs.getString('storelocalnotlead') ?? "";
      totalData = castToDesiredType(jsonDecode(jsonString));
      phoneNumbersNotifier.value = totalData.keys.toList();
      print('total data: $totalData');
    } else {
      print('No data found.');
    }
  }

  Future<void> deleteData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('storelocalnotlead')) {
      String jsonString = prefs.getString('storelocalnotlead') ?? "";
      Map<String, dynamic> data = jsonDecode(jsonString);
      data.remove(key);
      prefs.setString('storelocalnotlead', jsonEncode(data));
    } else {
      print('No data found.');
    }
  }

  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('storelocalnotlead')) {
      await prefs.setString('storelocalnotlead', jsonEncode({}));
      print("cleared successfully");
    } else {
      print('No data found.');
    }
  }

  Map<String, List<Map<String, dynamic>>> castToDesiredType(dynamic jsonData) {
    try {
      Map<String, List<Map<String, dynamic>>> result = {};
      if (jsonData is Map<String, dynamic>) {
        jsonData.forEach((key, value) {
          if (value is List) {
            List<Map<String, dynamic>> listValue = [];
            for (var item in value) {
              if (item is Map<String, dynamic>) {
                listValue.add(Map<String, dynamic>.from(item));
              }
            }
            result[key] = listValue;
          }
        });
      }
      return result;
    } catch (e) {
      print('Error casting to desired type: $e');
      return {};
    }
  }

  Future<void> getLeadSaveProperty() async {
    String propertyValue = await sharedPrefsHelper.getProperties() ?? '';
    String clientName = await sharedPrefsHelper.getClientName() ?? "";
    String clientPhoneNo = await sharedPrefsHelper.getClientPhoneNo() ?? "";
    print("called and $propertyValue");
    if (propertyValue == "Yes") {
      SnapPeUI().sendSwitchValue(true);
    } else {
      SnapPeUI().sendSwitchValue(false);
    }
  }

  Future<void> _postLead(String? phoneNumber, List<Map<String, dynamic>> data) async {
    String clientName = await sharedPrefsHelper.getClientName() ?? "";
    String clientPhoneNo = await sharedPrefsHelper.getClientPhoneNo() ?? "";
    if (phoneNumber != null && phoneNumber != "") {
      int leadId = 0;
      var clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
      var uri = Uri.parse("https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/lead");
      var request = http.Request('POST', uri);
      request.headers['Content-Type'] = 'application/json';
      Map<String, dynamic> lead = {
        "mobileNumber": phoneNumber[0] == "+" ? phoneNumber.substring(1) : phoneNumber,
        "leadSource": {
          "status": "OK",
          "messages": [],
          "id": 26,
          "sourceName": "Phone Call"
        }
      };
      request.body = jsonEncode(lead);
      var response = await NetworkHelper().request(RequestType.post, uri, requestBody: request.body);
      if (response != null && response.statusCode == 200) {
        var responseJson = jsonDecode(response.body);
        leadId = responseJson["id"];
        try {
          for (int i = 0; i < data.length; i++) {
            await postCallLog(data[i]["timestamp"].toInt(), data[i]["duration"].toInt(), leadId, data[i]["callType"] ?? "", data[i]["number"] ?? "", clientPhoneNo, clientName);
            await postCallLogNotification2(data[i]["callType"] ?? "", leadId);
          }
        } catch (e) {
          print("Error in post calllog from lead: $e");
        }
      } else {
        throw Exception('Failed to post lead');
      }
    }
  }

  Future<void> postCallLog(int callTime, int callDuration, int leadId, String callStatus, String phoneNumber, String clientPhoneNo, String clientName) async {
    try {
      DateTime startTime = DateTime.fromMillisecondsSinceEpoch(callTime, isUtc: true);
      DateTime endTime = DateTime.fromMillisecondsSinceEpoch(callTime + Duration(seconds: callDuration).inMilliseconds, isUtc: true);
      final formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
      final formattedStartTime = formatter.format(startTime);
      final formattedEndTime = formatter.format(endTime);
      final requestBodyMap = {
        "status": "OK",
        "isActive": true,
        "startTime": startTime.toIso8601String() ?? "",
        "endTime": endTime.toIso8601String(),
        "leadId": leadId,
        "callType": "call",
        "statusName": capitalize(callStatus),
        "fromNumber": clientPhoneNo,
        "toNumber": phoneNumber,
        "remarks": "",
        "agentPhoneNumber": clientPhoneNo,
        "agentName": clientName,
      };
      String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
      final response = await NetworkHelper().request(RequestType.post, Uri.parse("https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/call-logs"), requestBody: jsonEncode(requestBodyMap));
      if (response!.statusCode == 200) {
        print("Second API call succeeded");
      } else {
        print("Second API call failed with status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in postCallLog: $e");
    }
  }

  void _showPhoneNumbersDialog() async {
    String propertyValue = await sharedPrefsHelper.getProperties() ?? '';
    if (_isDialogOpen) return;
    if (propertyValue == "Yes") {
      _isDialogOpen = true;
      Get.dialog(
        AlertDialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Color.fromARGB(255, 232, 232, 232),
          title: Text('ADD LEAD FROM CALLS'),
          content: ValueListenableBuilder<List<String>?>(
            valueListenable: phoneNumbersNotifier,
            builder: (context, phoneNumbers, child) {
                   if (phoneNumbers == null || phoneNumbers.isEmpty) {
                
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (Navigator.canPop(context)) {
  Navigator.pop(context);
}

                  });
                  return Container();
                }
              return Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: 60,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: phoneNumbers!.length,
                  
                  itemBuilder: (context, index) {
                    return Card(
                      child: InkWell(
                        splashColor: Colors.blueAccent,
                        onTap: () {},
                        child: ListTile(
                          title: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  phoneNumbers[index].contains('+') ? phoneNumbers[index].substring(1) : phoneNumbers[index],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 1),
                              InkWell(
                                onTap: () async {
                                  try {
                                    await _postLead(phoneNumbers[index], totalData["${phoneNumbers[index]}"]!);
                                    await deleteData(phoneNumbers[index]);
                                    await fetchData();
                                  } catch (e) {
                                    print('postLead error: $e');
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 11,
                                  backgroundColor: Colors.green,
                                  child: Icon(Icons.check, color: Colors.white, size: 18),
                                ),
                              ),
                              SizedBox(width: 5),
                              InkWell(
                                onTap: () async {
                                  await deleteData(phoneNumbers[index]);
                                  await fetchData();
                                },
                                child: CircleAvatar(
                                  radius: 11,
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.clear, color: Colors.white, size: 18),
                                ),
                              ),
                              SizedBox(width: 5),
                              InkWell(
                                onTap: () {
                                
                                },
                                child: CircleAvatar(
                                  radius: 11,
                                  backgroundColor: Colors.blue,
                                  child: Icon(Icons.info, color: Colors.white, size: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                _isDialogOpen = false;
                Get.back();
              },
            ),
          ],
        ),
        barrierDismissible: false,
      ).then((value) {
        _isDialogOpen = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchData();
      getLeadSaveProperty();
      _showPhoneNumbersDialog();
    }
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    fetchData();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    phoneNumbersNotifier.dispose();
    super.onClose();
  }

  String capitalize(String text) {
    return text.isNotEmpty ? text[0].toUpperCase() + text.substring(1).toLowerCase() : '';
  }

  Future<void> postCallLogNotification2(String callStatus, int leadId) async {
    var uri = Uri.parse("https://${Globals.DomainPointer}/snappe-services/rest/v1/notifications");
    var request = http.Request('POST', uri);
    request.headers['Content-Type'] = 'application/json';
    Map<String, dynamic> callLogNotification = {
      "status": "OK",
      "source": "websocket",
      "destination": "ui",
      "payload": {
        "leadId": leadId,
        "callStatus": capitalize(callStatus),
        "message": "Call log added successfully"
      }
    };
    request.body = jsonEncode(callLogNotification);
    var response = await NetworkHelper().request(RequestType.post, uri, requestBody: request.body);
    if (response != null && response.statusCode == 200) {
      print("Notification sent successfully");
    } else {
      print("Failed to send notification");
    }
  }
}
