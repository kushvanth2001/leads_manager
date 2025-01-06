import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leads_manager/Controller/leads_controller.dart';
import 'package:leads_manager/constants/styleConstants.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:leads_manager/utils/snapPeUI.dart';
import 'package:leads_manager/views/leads/callLogWidget.dart';

import '../../domainvariables.dart';

class CallLogsScreen extends StatefulWidget {
  final int? leadId;
  final LeadController leadController;
  final VoidCallback onBack;
  CallLogsScreen(
      {required this.leadId,
      required this.leadController,
      required this.onBack});

  @override
  _CallLogsScreenState createState() => _CallLogsScreenState();
}

class _CallLogsScreenState extends State<CallLogsScreen> {
  late Future<List<dynamic>> futureCallLogs;

  @override
  void initState() {
    super.initState();
    futureCallLogs = fetchCallLogs(widget.leadId);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onBack();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text("Call Logs")),
        body: Center(
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                futureCallLogs = fetchCallLogs(widget.leadId);
              });
            },
            child: FutureBuilder<List<dynamic>>(
              future: futureCallLogs,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return Text("No Call Logs Available");
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        DateTime dateTime = DateTime.parse(
                                "${snapshot.data![index]['startTime']}Z")
                            .toLocal();
                        String formattedDateTime =
                            DateFormat('EEEE, MMMM d, yyyy, h:mm a')
                                .format(dateTime);

                        return Card(
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(
                                  snapshot.data![index]['statusName'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: kBigFontSize),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: (snapshot.data![index]['agentName'] !=
                                              null &&
                                          snapshot.data![index]
                                                  ['agentPhoneNumber'] !=
                                              null)
                                      ? Text(
                                          "Agent Name : ${snapshot.data![index]['agentName'] ?? ""} \nAgent Number : ${snapshot.data![index]['agentPhoneNumber'] ?? ""}")
                                      : Text("-"),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(snapshot.data![index]['callDuration']),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("$formattedDateTime"),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }

                // By default, show a loading spinner.
                return Center();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CallLog {
  final DateTime timestamp;
  final Duration duration;
  final String recordingLink;
  final String status;

  CallLog(
      {required this.timestamp,
      required this.duration,
      required this.recordingLink,
      required this.status});
}

Future<List<dynamic>> fetchCallLogs(int? leadId) async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  final response = await NetworkHelper().request(
    RequestType.get,
    Uri.parse(
        'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/call-logs?leadId=$leadId'),
    requestBody: "",
  );

  if (response != null && response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return jsonDecode(response.body)['callLogs'];
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load call logs');
  }
}
