// To parse this JSON data, do
//
//     final applicationModel = applicationModelFromJson(jsonString);

import 'dart:convert';
import '../../../domainvariables.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';

ApplicationModel applicationModelFromJson(String str) =>
    ApplicationModel.fromJson(json.decode(str));

String applicationModelToJson(ApplicationModel data) =>
    json.encode(data.toJson());

class ApplicationModel {
  ApplicationModel({
    this.status,
    this.messages,
    this.application,
  });

  String? status;
  List<String>? messages;
  List<Application>? application;

  factory ApplicationModel.fromJson(Map<String, dynamic> json) =>
      ApplicationModel(
        status: json["status"],
        messages: [],
        application: List<Application>.from(
            json["application"].map((x) => Application.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "application": List<dynamic>.from(application!.map((x) => x.toJson())),
      };
}

class Application {
  Application({
    this.status,
    this.messages,
    this.id,
    this.uniqueName,
    this.applicationName,
    this.apiKey,
    this.url,
    this.isDefault,
    this.phoneNo,
    this.properties,
    this.type,
    this.messengerType,
    this.telegramLink,
    this.chatApplicationName,
    this.sessionLife,
    this.medium,
    this.agent,
    this.telegramEnvironment,
    this.telegramAppId,
    this.telegramCode,
    this.telegramActivate,
  });

  String? status;
  List<String>? messages;
  int? id;
  String? uniqueName;
  String? applicationName;
  String? apiKey;
  String? url;
  dynamic isDefault;
  String? phoneNo;
  dynamic properties;
  dynamic type;
  dynamic messengerType;
  dynamic telegramLink;
  String? chatApplicationName;
  int? sessionLife;
  String? medium;
  String? agent;
  String? telegramEnvironment;
  String? telegramAppId;
  String? telegramCode;
  bool? telegramActivate;

  factory Application.fromJson(Map<String, dynamic> json) => Application(
        status: json["status"],
        messages: [],
        id: json["id"],
        uniqueName: json["uniqueName"],
        applicationName: json["applicationName"],
        apiKey: json["apiKey"],
        url: json["url"],
        isDefault: json["isDefault"],
        phoneNo: json["phoneNo"],
        properties: json["properties"],
        type: json["type"],
        messengerType: json["messengerType"],
        telegramLink: json["telegramLink"],
        chatApplicationName: json["chatApplicationName"],
        sessionLife: json["sessionLife"],
        medium: json["medium"],
        agent: json["agent"],
        telegramEnvironment: json["telegramEnvironment"],
        telegramAppId: json["telegramAppId"],
        telegramCode: json["telegramCode"],
        telegramActivate: json["telegramActivate"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "id": id,
        "uniqueName": uniqueName,
        "applicationName": applicationName,
        "apiKey": apiKey,
        "url": url,
        "isDefault": isDefault,
        "phoneNo": phoneNo,
        "properties": properties,
        "type": type,
        "messengerType": messengerType,
        "telegramLink": telegramLink,
        "chatApplicationName": chatApplicationName,
        "sessionLife": sessionLife,
        "medium": medium,
        "agent": agent,
        "telegramEnvironment": telegramEnvironment,
        "telegramAppId": telegramAppId,
        "telegramCode": telegramCode,
        "telegramActivate": telegramActivate,
      };
}
Future<Map<String,dynamic>> fetchApplicationsjsonbyids(int id ) async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  try {
    final response = await NetworkHelper().request(
      RequestType.get,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/applications/$id'),
      requestBody: "",
    );
    if (response != null && response.statusCode == 200) {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      final jsonResponse = json.decode(response.body);
      return jsonResponse["application"];
    
      
    } else {
      print('Failed to load applications');
      throw Exception('Failed to load applications');
    }
  } catch (e) {
    print('Exception occurred: $e');
    throw e;
  }
}

Future<List<Application>> fetchApplications() async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  try {
    final response = await NetworkHelper().requestwithouteasyloading (
      RequestType.get,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/applications?onlyDedicatedApps=true'),
      requestBody: "",
    );
    if (response != null && response.statusCode == 200) {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      final jsonResponse = json.decode(response.body);
      final List<dynamic> applicationsList = jsonResponse["application"];
      SharedPrefsHelper().setApplications(jsonEncode( applicationsList));
      final List<Application> applications =
          applicationsList.map((json) => Application.fromJson(json)).toList();
      return applications;
    } else {
      print('Failed to load applications');
      throw Exception('Failed to load applications');
    
      
    }
  } catch (e) {
    print('Exception occurred: $e');
      return [];
    
  }
}

Future<List<Application>> fetchApplicationsforLinkedNumber() async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  final response = await NetworkHelper().request(
    RequestType.get,
    Uri.parse(
        'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/linked-numbers'),
    requestBody: "",
  );

  if (response != null && response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final List<dynamic> applicationsList = jsonResponse["application"];
    final List<Application> applications =
        applicationsList.map((json) => Application.fromJson(json)).toList();
    return applications;
  } else {
    throw Exception('Failed to load applications');
  }
}
