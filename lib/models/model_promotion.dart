import 'dart:convert';
import '../../../domainvariables.dart';
import '../helper/SharedPrefsHelper.dart';
import '../helper/networkHelper.dart';
import '../marketing/addpromotions.dart';

class Promotions {
  int id;
  String name;
  String uniquePromotionId;
  int clientGroupId;
  dynamic communicationList;
  String sendUserNumber;
  List<Application> applications;
  int? noOfMessagesPerApplication;
  String messageTemplate;
  String applicationType;
  String? templateUrl;
  String? medium;
  String? environment;
  int from;
  int to;
  String? description;
  String messageText;
  String? attachmentUrls;
  String? externalDataUrl;
  String status;
  String createdOn;
  String startDate;
  String? endDate;
  String startTime;
  String endTime;
  String? chatbotResponse;
  String? senderName;
  String createrName;
  String mappedParams;
  String? urlTracking;
  String? removeDuplicates;
  String? batchSize;
  String? timeInterval;
  String? replyTo;

  Promotions({
    required this.id,
    required this.name,
    required this.uniquePromotionId,
    required this.clientGroupId,
    required this.communicationList,
    required this.sendUserNumber,
    required this.applications,
    this.noOfMessagesPerApplication,
    required this.messageTemplate,
    required this.applicationType,
    this.templateUrl,
    this.medium,
    this.environment,
    required this.from,
    required this.to,
    this.description,
    required this.messageText,
    this.attachmentUrls,
    this.externalDataUrl,
    required this.status,
    required this.createdOn,
    required this.startDate,
    this.endDate,
    required this.startTime,
    required this.endTime,
    this.chatbotResponse,
    this.senderName,
    required this.createrName,
    required this.mappedParams,
    this.urlTracking,
    this.removeDuplicates,
    this.batchSize,
    this.timeInterval,
    this.replyTo,
  });

 factory Promotions.fromJson(Map<String, dynamic> json) {
  return Promotions(
    id: json['id'] ?? 0,
    name: json['name'] ?? "",
    uniquePromotionId: json['uniquePromotionId'] ?? "",
    clientGroupId: json['clientGroupId'] ?? 0,
    communicationList: json['communicationList'] ?? {},
    sendUserNumber: json['sendUserNumber'] ?? "",
    applications: List<Application>.from(json['applications']?.map((app) => Application.fromJson(app)) ?? []),
    noOfMessagesPerApplication: json['noOfMessagesPerApplication'] ?? 0,
    messageTemplate: json['messageTemplate'] ?? "",
    applicationType: json['applicationType'] ?? "",
    templateUrl: json['templateUrl'] ?? "",
    medium: json['medium'] ?? "",
    environment: json['environment'] ?? "",
    from: json['from'] ?? 0,
    to: json['to'] ?? 0,
    description: json['description'] ?? "",
    messageText: json['messageText'] ?? "",
    attachmentUrls: json['attachmentUrls'] ?? "",
    externalDataUrl: json['externalDataUrl'] ?? "",
    status: json['status'] ?? "",
    createdOn: json['createdOn'] ?? "",
    startDate: json['startDate'] ?? "",
    endDate: json['endDate'] ?? "",
    startTime: json['startTime'] ?? "",
    endTime: json['endTime'] ?? "",
    chatbotResponse: json['chatbotResponse'] ?? "",
    senderName: json['senderName'] ?? "",
    createrName: json['createrName'] ?? "",
    mappedParams: json['mappedParams'] ?? "",
    urlTracking: json['urlTracking'] ?? "",
    removeDuplicates: json['removeDuplicates'] ?? "",
    batchSize: json['batchSize'] ?? "",
    timeInterval: json['timeInterval'] ?? "",
    replyTo: json['replyTo'] ?? "",
  );
}

Map<String, dynamic> toJson() {
  return {
    'id': id == 0 ? null : id,
    'name': name.isEmpty ? null : name,
    'uniquePromotionId': uniquePromotionId.isEmpty ? null : uniquePromotionId,
    'clientGroupId': clientGroupId == 0 ? null : clientGroupId,
    'communicationList': communicationList.toJson(),
    'sendUserNumber': sendUserNumber.isEmpty ? null : sendUserNumber,
  //  'applications': applications.map((app) => app.toJson()).toList(),
    'noOfMessagesPerApplication': noOfMessagesPerApplication == 0 ? null : noOfMessagesPerApplication,
    'messageTemplate': messageTemplate.isEmpty ? null : messageTemplate,
    'applicationType': applicationType.isEmpty ? null : applicationType,
    'templateUrl': templateUrl!.isEmpty ? null : templateUrl,
    'medium': medium!.isEmpty? null : medium,
    'environment': environment!.isEmpty ? null : environment,
    'from': from == 0 ? null : from,
    'to': to == 0 ? null : to,
    'description': description!.isEmpty ? null : description,
    'messageText': messageText.isEmpty ? null : messageText,
    'attachmentUrls': attachmentUrls!.isEmpty ? null : attachmentUrls,
    'externalDataUrl': externalDataUrl!.isEmpty ? null : externalDataUrl,
    'status': status.isEmpty ? null : status,
    'createdOn': createdOn.isEmpty ? null : createdOn,
    'startDate': startDate.isEmpty ? null : startDate,
    'endDate': endDate!.isEmpty ? null : endDate,
    'startTime': startTime.isEmpty ? null : startTime,
    'endTime': endTime.isEmpty ? null : endTime,
    'chatbotResponse': chatbotResponse!.isEmpty ? null : chatbotResponse,
    'senderName': senderName!.isEmpty ? null : senderName,
    'createrName': createrName.isEmpty ? null : createrName,
    'mappedParams': mappedParams.isEmpty ? null : mappedParams,
    'urlTracking': urlTracking!.isEmpty ? null : urlTracking,
    'removeDuplicates': removeDuplicates!.isEmpty ? null : removeDuplicates,
    'batchSize': batchSize!.isEmpty ? null : batchSize,
    'timeInterval': timeInterval!.isEmpty ? null : timeInterval,
    'replyTo': replyTo!.isEmpty ? null : replyTo,
  };

  }



static Future<Promotions> getPromotionById(int promotionId) async {
  try {
    // Replace 'YOUR_BASE_URL' with your actual base URL

 String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";
    final response = await NetworkHelper().request(
      RequestType.get,
      Uri.parse('https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/merchant-promotions/$promotionId'),
      // Add headers or cookies if needed
    );

    if (response != null && response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return Promotions.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch promotion');
    }
  } catch (error) {
    print('Error: $error');
    throw Exception('Failed to fetch promotion');
  }
}
}