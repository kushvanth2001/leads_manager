import 'dart:convert';

import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import '../../../domainvariables.dart';
class Document {
  final int? id;
  final String? fileLink;
  final String? description;
  final String? fileData;
  final String? createdOn;
  final String? downloadLink;

  Document({
    this.id,
    this.fileLink,
    this.description,
    this.fileData,
    this.createdOn,
    this.downloadLink,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
       id: json['id'] ?? 0,
      fileLink: json['fileLink'] ?? '',
      description: json['description'] ?? '',
      createdOn: json['createdOn'] ?? '',
      downloadLink: json['downloadLink'] ?? '',
    
    );
  }
}

Future<List<Document>> fetchDocuments() async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  final response = await NetworkHelper().request(
    RequestType.get,
    Uri.parse(
        'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/documents'),
    requestBody: "",
  );
  if (response != null && response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return (data['documents'] as List)
        .map((doc) => Document.fromJson(doc))
        .toList();
  } else {
    throw Exception('Failed to load data');
  }
}
