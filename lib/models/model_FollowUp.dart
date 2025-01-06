// To parse this JSON data, do
//
//     final followUpModel = followUpModelFromJson(jsonString);

import 'dart:convert';

import 'package:leads_manager/models/model_Merchants.dart';

FollowUpModel followUpModelFromJson(String str) =>
    FollowUpModel.fromJson(json.decode(str));

String followUpModelToJson(FollowUpModel data) => json.encode(data.toJson());

class FollowUpModel {
  FollowUpModel({
    this.status,
    this.isActive,
    this.createdBy,
    this.documents,
    this.leadId,
    this.taskId,
    this.remarks,
    this.remindcusomer,
    this.endTime,
    this.startTime,
required this.AssignedTo,
this.reminderMessage
  });

  String? status;
  bool? isActive;
  dynamic createdBy;
  Documents? documents;
  int? leadId;
  int? taskId;
  String? remarks;
  bool? remindcusomer;
  String? startTime;
  String? endTime;
  User AssignedTo;
String? reminderMessage;
  factory FollowUpModel.fromJson(Map<String, dynamic> json) => FollowUpModel(
        status: json["status"],
        isActive: json["isActive"],
        createdBy: json["createdBy"],
        documents: Documents.fromJson(json["documents"]),
        leadId: json["leadId"],
        taskId: json["taskId"],
        remarks: json["remarks"],
        remindcusomer: json["remindCustomer"],
        startTime: json['startTime'],
        endTime:json['endTime'],
AssignedTo: json["assignedTo"],
reminderMessage: json["reminderMessage"]
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "isActive": isActive,
        "createdBy": createdBy,
        "documents":
            documents == null ? Documents().toJson() : documents!.toJson(),
        "leadId": leadId,
        "taskId": taskId,
        "remarks": remarks,
        "remindCustomer":remindcusomer!=null?remindcusomer:false,
        'endTime':endTime,
        'startTime':startTime,
"assignedTo":AssignedTo.toJson(),
   "assignedBy": null,
  "taskStatus": {
    "id": null,
    "name": null,
    "clientGroupId": null
    

  },
   "customerId": null,
  "customerName": null,
  "areaCommunity": null,
  "customerAddress": null,
  "customerMobileNumber": null,
  "reportedClientGroupId": null,
"reminderMessage":reminderMessage
      };
}

class Documents {
  Documents({
    this.documents,
  });

  List<dynamic>? documents;

  factory Documents.fromJson(Map<String, dynamic> json) => Documents(
        documents: json["documents"] == null
            ? null
            : List<dynamic>.from(json["documents"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "documents": documents == null
            ? []
            : List<dynamic>.from(documents!.map((x) => x)),
      };
}
