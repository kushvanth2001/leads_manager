// To parse this JSON data, do
//
//     final leadNotesModel = leadNotesModelFromJson(jsonString);

import 'dart:convert';

import 'package:leads_manager/models/model_CreateNote.dart';

LeadNotesModel leadNotesModelFromJson(String str) =>
    LeadNotesModel.fromJson(json.decode(str));

String leadNotesModelToJson(LeadNotesModel data) => json.encode(data.toJson());

class LeadNotesModel {
  LeadNotesModel({
    this.status,
    this.messages,
    this.leadActions,
  });

  String? status;
  List<String>? messages;
  List<LeadAction>? leadActions;

  factory LeadNotesModel.fromJson(Map<String, dynamic> json) => LeadNotesModel(
        status: json["status"],
        messages: [],
        leadActions: json["leadActions"] == null
            ? null
            : List<LeadAction>.from(
                json["leadActions"].map((x) => LeadAction.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "leadActions": leadActions == null
            ? null
            : List<dynamic>.from(leadActions!.map((x) => x.toJson())),
      };
}

class LeadAction {
  LeadAction({
    this.status,
    this.messages,
    this.id,
    this.leadId,
    this.isActive,
    this.remarks,
    this.createdOn,
    this.createdBy,
    this.actualDealValue,
    this.potentialDealValue,
    this.documents
  });

  String? status;
  List<dynamic>? messages;
  int? id;
  int? leadId;
  bool? isActive;
  String? remarks;
  DateTime? createdOn;
  String? createdBy;
  String? actualDealValue;
  String? potentialDealValue;
  Documents? documents;

  factory LeadAction.fromJson(Map<String, dynamic> json) => LeadAction(
        status: json["status"],
        messages: [],
        id: json["id"],
        leadId: json["leadId"],
        isActive: json["isActive"],
        remarks: json["remarks"],
        createdOn: json["createdOn"] == null
            ? null
            : DateTime.parse(json["createdOn"]),
        createdBy: json["createdBy"],
        actualDealValue: json["actualDealValue"],
        potentialDealValue: json["potentialDealValue"],
         documents: json["documents"] == null
            ? null
            : Documents.fromJson(json["documents"]),

      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "id": id,
        "leadId": leadId,
        "isActive": isActive,
        "remarks": remarks,
        "createdOn": createdOn == null ? null : createdOn!.toIso8601String(),
        "createdBy": createdBy,
        "actualDealValue": actualDealValue,
        "potentialDealValue": potentialDealValue,
               "documents": documents == null ? Documents() : documents!.toJson(),
      };
}
