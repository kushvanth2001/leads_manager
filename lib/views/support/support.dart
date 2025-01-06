import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import '../../constants/styleConstants.dart';
import '../../domainvariables.dart';
import '../../helper/SharedPrefsHelper.dart';
import '../../models/model_taskpage.dart';
import '../leads/TaskNotesPage.dart';
import '../leads/leadNotesScreen.dart';
import '../leads/taskDetails.dart';
import 'dart:convert';
import '../../helper/networkHelper.dart';
import 'package:intl/intl.dart';
import '../../utils/snapPeUI.dart';
import 'RaiseComplaint.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  List<Widget> cards = [];

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    try {
      String clientGroupName =
          await SharedPrefsHelper().getClientGroupName() ?? "";
      // String userId = await SharedPrefsHelper().getMerchantUserId();
      final response = await NetworkHelper().request(
        RequestType.get,
        Uri.parse(
            'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/tasks?page=0&size=20&type=support&isMyComplaints=true'),
        requestBody: "",
      );

      if (response != null && response.statusCode == 200) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
        final jsonResponse = json.decode(response.body);
        final List<dynamic> complaintsList = jsonResponse["tasks"];
        final List<Complaint> complaints =
            complaintsList.map((json) => Complaint.fromJson(json)).toList();
        print(". $complaints .");

        cards = complaints.map<Widget>((complaint) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${complaint.name}',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text('Id : ${complaint.id}'),
                        Text(
                            'Created On : ${complaint.createdOn.split("T")[0]}'),
                        Text('Description : ${complaint.description}'),
                      ],
                    ),
                  ),
                  PopupMenuButton<int>(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.edit),
                            Text("   Edit",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.delete),
                            Text(
                              "   Delete",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 1) {
                        RaiseComplaint(refreshCallback: fetchComplaints)
                            .showComplaintDialog(context, complaint);
                        await fetchComplaints();
                      } else if (value == 2) {
                        await SnapPeNetworks(). deleteTask(complaint.id);
                        await fetchComplaints();
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList();
        setState(() {});
      } else {
        print('Failed to load tasks');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: SnapPeUI().appBarText("My Complaints ", kBigFontSize),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.back_hand_rounded),
            onPressed: () {
              RaiseComplaint(refreshCallback: fetchComplaints)
                  .showComplaintDialog(context);
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: cards.isEmpty
                ? SnapPeUI().noDataFoundImage2(msg: "You have no Complaints !!")
                : ListView.builder(
                    itemCount: cards.length,
                    itemBuilder: (context, index) => cards[index],
                  ),
          ),
        ],
      ),
    );
  }


}

class Complaint {
  final int id;
  final String name;
  final String createdOn;
  final String description;
  final String customerName;
  final int customerMobileNumber;
  final String startTime;
  final String endTime;

  Complaint({
    required this.id,
    required this.name,
    required this.createdOn,
    required this.description,
    required this.customerName,
    required this.customerMobileNumber,
    required this.startTime,
    required this.endTime,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'],
      name: json['name'],
      createdOn: json['createdOn'],
      description: json['description'],
      customerName: json['customerName'],
      customerMobileNumber: json['customerMobileNumber'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }
}
