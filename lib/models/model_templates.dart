import 'dart:convert';

import '../helper/SharedPrefsHelper.dart';
import '../helper/networkHelper.dart';
import '../../../domainvariables.dart';
class TemplateModel {
  final String status;
  final List<String> messages;
  final List<Template> templates;

  TemplateModel({
    required this.status,
    required this.messages,
    required this.templates,
  });
 static Future<List<Template>> getTemplatesForMerchant(String merchant, ) async {
     String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";
      final response = await NetworkHelper().request(
      RequestType.get,
      Uri.parse(
        'https://${Globals.DomainPointer}/snappe-services/rest/v1/gupshup/$merchant/templates?merchant=$clientGroupName',
      ),
      requestBody: "",
    );
    

    if (response!.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body)['templates'];
      return jsonList.map((json) => Template.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load templates');
    }
  }

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    List<dynamic>? templatesJson = json['templates'];
    List<Template> templates = templatesJson?.map((template) => Template.fromJson(template)).toList() ?? [];

    return TemplateModel(
      status: json['status'] ?? '',
      messages: List<String>.from(json['messages'] ?? []),
      templates: templates,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'messages': messages,
      'templates': templates.map((template) => template.toJson()).toList(),
    };
  }
}

class Template {
  final String appId;
  final String category;
  final int createdOn;
  final String data;
  final String elementName;
  final String externalId;
  final String id;
  final String languageCode;
  final String languagePolicy;
  final dynamic master;
  final String meta;
  final int modifiedOn;
  final String namespace;
  final String status;
  final String templateType;
  final String vertical;
  final dynamic reason;
  final dynamic url;
  final dynamic templateId;

  Template({
    required this.appId,
    required this.category,
    required this.createdOn,
    required this.data,
    required this.elementName,
    required this.externalId,
    required this.id,
    required this.languageCode,
    required this.languagePolicy,
    required this.master,
    required this.meta,
    required this.modifiedOn,
    required this.namespace,
    required this.status,
    required this.templateType,
    required this.vertical,
    required this.reason,
    required this.url,
    required this.templateId,
  });

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      appId: json['appId'] ?? '',
      category: json['category'] ?? '',
      createdOn: json['createdOn'] ?? 0,
      data: json['data'] ?? '',
      elementName: json['elementName'] ?? '',
      externalId: json['externalId'] ?? '',
      id: json['id'] ?? '',
      languageCode: json['languageCode'] ?? '',
      languagePolicy: json['languagePolicy'] ?? '',
      master: json['master'],
      meta: json['meta'] ?? '',
      modifiedOn: json['modifiedOn'] ?? 0,
      namespace: json['namespace'] ?? '',
      status: json['status'] ?? '',
      templateType: json['templateType'] ?? '',
      vertical: json['vertical'] ?? '',
      reason: json['reason'],
      url: json['url'],
      templateId: json['templateId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appId': appId,
      'category': category,
      'createdOn': createdOn,
      'data': data,
      'elementName': elementName,
      'externalId': externalId,
      'id': id,
      'languageCode': languageCode,
      'languagePolicy': languagePolicy,
      'master': master,
      'meta': meta,
      'modifiedOn': modifiedOn,
      'namespace': namespace,
      'status': status,
      'templateType': templateType,
      'vertical': vertical,
      'reason': reason,
      'url': url,
      'templateId': templateId,
    };
  }
}