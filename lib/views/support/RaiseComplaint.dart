import 'package:flutter/material.dart';
import '../../constants/colorsConstants.dart';
import 'package:http/http.dart' as http;
import '../../domainvariables.dart';
import '../../helper/SharedPrefsHelper.dart';
import 'dart:convert';

import '../../helper/networkHelper.dart';
import 'support.dart';

class RaiseComplaint extends StatelessWidget {
  final TextEditingController txtSubjectName = TextEditingController();
  final TextEditingController txtCategory = TextEditingController();
  final TextEditingController txtDescription = TextEditingController();
  final String currentTime = DateTime.now().toUtc().toIso8601String();
  final Function refreshCallback;
  RaiseComplaint({required this.refreshCallback});
  @override
  Widget build(BuildContext context) {
    return Container(); // Return an empty container or any other widget
  }

  void showComplaintDialog(BuildContext context, [Complaint? complaint]) {
    txtSubjectName.text = complaint?.name ?? "";
    txtDescription.text = complaint?.description ?? "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: complaint == null
              ? Text('Raise a Complaint')
              : Text("Edit"), // Add your dialog title here
          content: Container(
            height: 300, // Adjust as needed
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: txtSubjectName,
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: kPrimaryColor),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: txtCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: kPrimaryColor),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: txtDescription,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: kPrimaryColor),
                      ),
                    ),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            //primarycolorerror
                            // primary: Colors.redAccent, // Background color
                            // onPrimary: Colors.white, // Text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: EdgeInsets.all(12.0),
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop();
                          },
                          child: Text("      Cancel      ",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      if (complaint == null)
                        Center(
                          child: 
                          
                          
                          ElevatedButton(
                            style:
                            
                             ElevatedButton.styleFrom(
                                     //primarycolorerror
                              // primary: const Color.fromARGB(
                              //     255, 23, 151, 255), // Background color
                              // onPrimary: Colors.white, // Text color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: EdgeInsets.all(12.0),
                            ),
                            onPressed: () async {
                              await raiseComplaint();
                              refreshCallback();
                              Navigator.of(context).pop();
                            },
                            child: Text("    Add    ",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      if (complaint != null)
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                     //primarycolorerror
                              // primary: const Color.fromARGB(
                              //     255, 23, 151, 255), // Background color
                              // onPrimary: Colors.white, // Text color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: EdgeInsets.all(12.0),
                            ),
                            onPressed: () async {
                              await updateComplaint(complaint);
                              refreshCallback();
                              Navigator.of(context).pop();
                            },
                            child: Text("    Update    ",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> raiseComplaint() async {
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    var url =
        'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/task?isSupport=true';
    var body = {
      'description': txtDescription.text,
      'taskStatus': {
        'id': null,
      },
      'name': txtSubjectName.text,
      'startTime': currentTime,
      'documents': {
        'documents': [],
      },
    };

    print('Request body: $body');

    var response = await NetworkHelper().request(
      RequestType.post,
      Uri.parse(url),
      requestBody: jsonEncode(body),
    );

    if (response?.statusCode == 200) {
      print('Complaint raised successfully');
    } else {
      print('Failed to raise complaint');
    }
  }

  Future<void> updateComplaint(Complaint complaint) async {
    // String clientGroupName =
    //     await SharedPrefsHelper().getClientGroupName() ?? "";
    // var url =
    //     'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/task?isSupport=true';
    // var body = {
    //   'description': txtDescription.text,
    //   'taskStatus': {
    //     'id': null,
    //   },
    //   'name': txtSubjectName.text,
    //   'startTime': currentTime,
    //   'documents': {
    //     'documents': [],
    //   },
    // };

    // print('Request body: $body');

    // var response = await NetworkHelper().request(
    //   RequestType.post,
    //   Uri.parse(url),
    //   requestBody: jsonEncode(body),
    // );

    // if (response?.statusCode == 200) {
    //   print('Complaint raised successfully');
    // } else {
    //   print('Failed to raise complaint');
    // }
  }
}
