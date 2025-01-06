import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:leads_manager/models/model_CreateNote.dart';
import 'package:leads_manager/models/model_leadDetails.dart';
import 'package:leads_manager/utils/snapPeUI.dart';
import 'package:leads_manager/views/leads/leadDetails/notesWidget.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/views/leads/leadsScreen.dart';
import '../../../Controller/leadDetails_controller.dart';
import '../../../Controller/leads_controller.dart';
import '../../../constants/colorsConstants.dart';
import 'package:leads_manager/models/model_lead.dart' as model_lead;
import '../../../models/model_lead.dart';
import '../../domainvariables.dart';

class TaskNotesScreen extends StatefulWidget {
  String? taskId;
  TaskNotesScreen({Key? key, this.taskId}) : super(key: key);

  @override
  State<TaskNotesScreen> createState() => _TaskNotesScreenState();
}

class _TaskNotesScreenState extends State<TaskNotesScreen> {
  bool showLoading = true;

  @override
  void initState() {
    super.initState();
  }

  TextEditingController textController = TextEditingController();

  openCreateNoteDialog(TextEditingController textController) {
    return Get.defaultDialog(
      title: "Create Note",
      content: Column(
        children: [
          TextField(
            controller: textController,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: kPrimaryColor))),
            maxLines: 10,
            // maxLength: 200,
            keyboardType: TextInputType.multiline,
          )
        ],
      ),
      textConfirm: "Save",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        String? taskId = widget.taskId; //Assuming task.id is a string
        int? taskIdAsInt;

        try {
          taskIdAsInt = int.parse(taskId ?? "0");
          await SnapPeNetworks().createTaskNotes(taskIdAsInt,
              CreateNote(remarks: "<p>${textController.text}</p>"));
        } catch (e) {
          print('Unable to parse task id: $e');
        }
        Get.back();
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => super.widget));
      },
      onCancel: () {},
    );
  }

  Future<List<TaskNote>> fetchTaskNotes(taskId) async {
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";

    final response = await NetworkHelper().request(
      RequestType.get,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/task-actions/$taskId'),
      requestBody: "",
    );

    if (response != null && response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body)['tasks'];
      return jsonResponse.map((task) => TaskNote.fromJson(task)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  @override
  Widget build(BuildContext context) {
    buildNotes() {
      return FutureBuilder<List<TaskNote>>(
        future: fetchTaskNotes(widget.taskId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return Expanded(
                child: Center(
                    child: Text('Notes are empty!',
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 30))),
              );
            } else {
              return Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20.0),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    DateTime dateTime =
                        DateTime.parse(snapshot.data![index].createdOn);
                    String formattedDate =
                        DateFormat('h:mm a, MMMM d y').format(dateTime);

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15.0), // Adjust as needed
                      ),
                      elevation: 5, // Adjust as needed
                      child: ListTile(
                        title: Text(
                          snapshot.data![index].remarks
                              .replaceAll(RegExp('<[^>]*>'), ''),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(formattedDate),
                      ),
                    );
                  },
                ),
              );
            }
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              openCreateNoteDialog(textController);
            },
          ),
        ],
      ),
      body: Column(children: [
        buildNotes(),
      ]),
    );
  }
}

class TaskNote {
  final String id;
  final String remarks;
  final String createdOn;

  TaskNote({required this.id, required this.remarks, required this.createdOn});

  factory TaskNote.fromJson(Map<String, dynamic> json) {
    return TaskNote(
      id: json['id'].toString(),
      remarks: json['remarks'],
      createdOn: json['createdOn'],
    );
  }
}
