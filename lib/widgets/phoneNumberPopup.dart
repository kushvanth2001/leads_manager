import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:leads_manager/Controller/leads_controller.dart';
import 'package:leads_manager/domainvariables.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/callloghelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:leads_manager/models/model_lead.dart';
import 'package:leads_manager/views/leads/leadDetails/leadDetails.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Phonenumberpopup extends StatefulWidget {
  const Phonenumberpopup({super.key});

  @override
  State<Phonenumberpopup> createState() => _PhonenumberpopupState();
}

class _PhonenumberpopupState extends State<Phonenumberpopup> {
  LeadController leadController = Get.find<LeadController>();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (leadController.phonenumberdiologuevalues.value.isEmpty) {
        Get.back();
        return SizedBox.shrink();
        // Do not show the dialog if no data
      }

      return AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add other Numbers as Leads'),
            Text(
              'Tap or Swipe for actions.',
              style: TextStyle(
                fontSize: 14, // Smaller font for the subtitle
                color: Colors.grey, // Grey color for a subtitle feel
              ),
            ),
          ],
        ),
        content: Container(
            height: 400,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              itemCount: leadController.phonenumberdiologuevalues.value.length,
              itemBuilder: (context, index) {
                final phoneNumber = leadController
                    .phonenumberdiologuevalues.value.keys
                    .elementAt(index);
                final numbers = leadController
                        .phonenumberdiologuevalues.value[phoneNumber] ??
                    [];
                final fristmap = leadController.phonenumberdiologuevalues
                        .value[phoneNumber]?[0] as Map<String, dynamic> ??
                    {};

                return Slidable(
                  endActionPane: ActionPane(motion: ScrollMotion(), children: [
                    SlidableAction(
                      onPressed: (context) async {
                        await deleteData(fristmap["number"]);
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.arrow_forward_rounded,
                      label: "Delete Number",
                    )
                  ]),
                  startActionPane: ActionPane(
                    motion: ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          isValidIndianMobileNumber(fristmap["number"]) != null
                              ? await _postLead(fristmap["number"], numbers)
                              : Fluttertoast.showToast(
                                  msg: "Cant Post this Number as a lead");
                          await deleteData(fristmap["number"]);
                        },
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        icon: Icons.arrow_forward_rounded,
                        label: "Covert to Lead",
                      )
                    ],
                  ),
                  child: InkWell(
                    onTap: () async {
                      isValidIndianMobileNumber(fristmap["number"]) != null
                          ? Get.to(() => LeadDetails(
                                lead: Lead(mobileNumber: fristmap["number"]),
                                isNewLead: true,
                                dynamicCallback: (p0) async {
                                  try {
                                    if (p0 != null) {
                                      for (int i = 0; i < numbers.length; i++) {
                                        CallLogHelper.postDataToSecondApi(
                                            numbers[i], p0.id.toString(),null);
                                      }
                                    }
                                  } catch (e) {
                                    print("Error in post calllog fromlead: $e");
                                  }

                                  await deleteData(fristmap["number"]);
                                },
                              ))
                          : Fluttertoast.showToast(
                             msg: "Unable to Post this lead it not a valid Indian number");
                    },
                    child: Card(
                      elevation: 3,
                      child: ListTile(
                        title: Text(fristmap["number"]),
                      ),
                    ),
                  ),
                );
              },
            )),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              for (var entry
                  in leadController.phonenumberdiologuevalues.value.entries) {
                final phoneNumber = entry.key;
                final dialogues = entry.value;
                isValidIndianMobileNumber(phoneNumber) != null
                    ? _postLead(phoneNumber, dialogues)
                    : Fluttertoast.showToast(
                        msg: "Cant Post this Number as a lead");
              }
              await clearData();
            },
            child: Text('Save All'),
          ),
        ],
      );
    });
  }

  _postLead(String? phoneNumber, List<Map<String, dynamic>> data) async {
    print('inpostlead');

    if (phoneNumber != null && phoneNumber != "") {
      int leadid = 0;
      var clientGroupName =
          await SharedPrefsHelper().getClientGroupName() ?? "";
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
      print("request ${phoneNumber} \n\\n\n\n\\nn\\n\n/n/n");
      var response = await NetworkHelper()
          .request(RequestType.post, uri, requestBody: request.body);
      if (response != null && response.statusCode == 200) {
        var responseJson = jsonDecode(response.body);
        leadid = responseJson["id"];

        print("this is responseJson $responseJson");
        print(data);
        final apiCalls = <Future<dynamic>>[];
        try {
          for (int i = 0; i < data.length; i++) {
            await CallLogHelper.postDataToSecondApi(data[i], leadid.toString(),null);
          }
        } catch (e) {
          print("Error in post calllog fromlead: $e");
        }
      } else {
        print("$request");
        throw Exception(
            'Failed to post lead $lead,$clientGroupName,$data,${response?.statusCode},');
      }
    }
  }

  Future<void> fetchData() async {
    try {
      final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
      final SharedPreferences prefs = await _prefs;

      await prefs.reload();

      if (prefs.containsKey('not_lead_localstorage')) {
        String jsonString = prefs.getString('not_lead_localstorage') ?? "";
        Map<String, dynamic> l = jsonDecode(jsonString);

        leadController.phonenumberdiologuevalues.value =
            castToDesiredType(jsonDecode(jsonString));
      } else {
        print('No data found.');
      }
    } catch (e) {
      print("error from the fetch data home $e");
      throw ("error from the fetch data home $e");
    }
  }

  Future<void> deleteData(String k) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> l = {};

      if (prefs.containsKey('not_lead_localstorage')) {
        String jsonString = prefs.getString('not_lead_localstorage') ?? "";
        l = jsonDecode(jsonString);

        l.containsKey(k) ? l.remove(k) : null;
        prefs.setString('not_lead_localstorage', jsonEncode(l));
        await fetchData();
      } else {
        print('No data found.');
      }
    } catch (e) {
      print("error from the delete data home $e");
      throw ("error from the delete data home $e");
    }
  }

  Future<void> clearData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> l = {};
      if (prefs.containsKey('not_lead_localstorage')) {
        await prefs.setString('not_lead_localstorage', jsonEncode(l));
        print("cleared successfully");
        await fetchData();
      } else {
        print('No data found.');
      }
      prefs.reload();
    } catch (e) {
      print("error from the clear data home $e");
      throw ("error from the clear data home $e");
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
      // Return an empty map or handle the error as needed
      return {};
    }
  }
}

String? isValidIndianMobileNumber(String input) {
  String cleanedInput = input.replaceAll(RegExp(r'[^0-9]'), '');

  final length = cleanedInput.length;

  if (length == 10) {
    cleanedInput = '91' + cleanedInput;
    return cleanedInput;
  } else if (length == 12 && cleanedInput.startsWith('91')) {
    return cleanedInput;
  }
  return null;
}
