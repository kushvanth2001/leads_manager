// To parse this JSON data, do
//
//     final leadStatusModel = leadStatusModelFromJson(jsonString);
import 'dart:convert';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import '../../../domainvariables.dart';
LeadStatusModel leadStatusModelFromJson(String str) =>
    LeadStatusModel.fromJson(json.decode(str));

String leadStatusModelToJson(LeadStatusModel data) =>
    json.encode(data.toJson());

List<AllLeadsStatus> leadStatusListFromJson(String str) =>
    List<AllLeadsStatus>.from(
        json.decode(str).map((x) => AllLeadsStatus.fromJson(x)));

class LeadStatusModel {
  LeadStatusModel({
    this.status,
    this.messages,
    this.allLeadsStatus,
  });

  String? status;
  List<dynamic>? messages;
  List<AllLeadsStatus>? allLeadsStatus;

  factory LeadStatusModel.fromJson(Map<String, dynamic> json) =>
      LeadStatusModel(
        status: json["status"],
        messages: [],
        allLeadsStatus: json["allLeadsStatus"] == null
            ? []
            : List<AllLeadsStatus>.from(
                json["allLeadsStatus"].map((x) => AllLeadsStatus.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "allLeadsStatus": allLeadsStatus == null
            ? []
            : List<dynamic>.from(allLeadsStatus!.map((x) => x.toJson())),
      };
}

class AllLeadsStatus {
  AllLeadsStatus({
    this.status,
    this.messages,
    this.id,
    this.statusName,
    this.lastModifiedTime,
    this.lastModifiedBy,
    this.isActive,
    this.clientGroupId,
this.color
  });

  String? status;
  List<dynamic>? messages;
  int? id;
  String? statusName;
  dynamic lastModifiedTime;
  dynamic lastModifiedBy;
  bool? isActive;
    String? color; 
  dynamic clientGroupId;


  factory AllLeadsStatus.fromJson(Map<String, dynamic> json) => AllLeadsStatus(
        status: json["status"],
        messages: [],
        id: json["id"],
        statusName: json["statusName"],
        lastModifiedTime: json["lastModifiedTime"],
        lastModifiedBy: json["lastModifiedBy"],
        isActive: json["isActive"],
        clientGroupId: json["clientGroupId"],
        color:            json["color"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "id": id,
        "statusName": statusName,
        "lastModifiedTime": lastModifiedTime,
        "lastModifiedBy": lastModifiedBy,
        "isActive": isActive,
        "clientGroupId": clientGroupId,
        "color":color
      };
  dynamic operator [](String propertyName) {
    switch (propertyName) {
      case 'status':
        return status;
      case 'messages':
        return messages;
      case 'id':
        return id;
      case 'statusName':
        return statusName;
      case 'lastModifiedTime':
        return lastModifiedTime;
      case 'lastModifiedBy':
        return lastModifiedBy;
      case 'isActive':
        return isActive;
      case 'clientGroupId':
        return clientGroupId;
      case 'color':
        return color;
      default:
        throw ArgumentError('Invalid property name: $propertyName');
    }
  }
}

Future<List<dynamic>> getAllLeadsStatus() async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  try {
    final response = await NetworkHelper().request(
      RequestType.get,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/lead-status'),
      requestBody: "",
    );
    if (response != null && response.statusCode == 200) {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      final parsed = jsonDecode(response.body)['allLeadsStatus'];
      return parsed;
    } else {
      print(
          'Failed to load all leads status with status code: ${response?.statusCode}');
      throw Exception('Failed to load all leads status');
    }
  } catch (e) {
    print('Exception occurred: $e');
    throw e;
  }
}
