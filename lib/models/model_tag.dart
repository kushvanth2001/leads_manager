import 'dart:convert';

import 'package:leads_manager/domainvariables.dart';
import 'package:leads_manager/models/model_leadDetails.dart';

import '../helper/SharedPrefsHelper.dart';
import '../helper/networkHelper.dart';

class Tag {
  Tag({
    this.status,
    this.messages,
    this.id,
    this.name,
    this.type,
    this.clientGroupId,
    this.color,
    this.description,
     this.isLeadTag,
    this.createdOn,

  });

  String? status;
  List<String>? messages;
  int? id;
  String? name;
  String? type;
  int? clientGroupId;
  String? color;
  String? description;
    bool? isLeadTag;
  DateTime? createdOn;


  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        status: json["status"],
        messages: [],
        id: json["id"],
        name: json["name"],
        type: json["type"],
        clientGroupId: json["clientGroupId"],
        color: json["color"],
        description: json["description"],
       isLeadTag: json['isLeadTag'] as bool?,
      createdOn: json['createdOn'] != null
          ? DateTime.parse(json['createdOn'] as String)
          : null,
      
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "id": id,
        "name": name,
        "type": type,
        "clientGroupId": clientGroupId,
        "color": color,
        "description": description,
          'isLeadTag': isLeadTag ?? false,
      'createdOn': createdOn?.toIso8601String() ?? '',
      };

static Future<List<Tag>> fetchTags() async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  final response = await NetworkHelper().request(
    RequestType.get,
    Uri.parse(
    'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/tags?type=lead'),
    requestBody: "",
  );
  if (response != null && response.statusCode == 200) {

    final data = jsonDecode(response.body);
    return (data['tags'] as List)
        .map((tag) => Tag.fromJson(tag))
        .toList();
  } else {
    throw Exception('Failed to load data');
  }
}
static Future<void> AssignTags(String id,TagsDto2 tags) async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  final response = await NetworkHelper().request(
    RequestType.put,
    Uri.parse(
    'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/${clientGroupName}/tag/$id'),
    requestBody: jsonEncode( tags.toJson()),
  );
  if (response != null && response.statusCode == 200) {

    final data = jsonDecode(response.body);
  } else {
    throw Exception('Failed to AssignTags');
  }
}
}
