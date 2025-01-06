import 'dart:convert';
import '../../../domainvariables.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';

class PriorityModel {
  String status;
  List<dynamic> messages;
  List<Priority> allPriorities;

  PriorityModel({
    required this.status,
    required this.messages,
    required this.allPriorities,
  });

  factory PriorityModel.fromJson(Map<String, dynamic> json) {
    return PriorityModel(
      status: json['status'],
      messages: json['messages'],
      allPriorities: List<Priority>.from(
        json['allPriorities'].map((priority) => Priority.fromJson(priority)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'messages': messages,
      'allPriorities':
          allPriorities.map((priority) => priority.toJson()).toList(),
    };
  }
}

class Priority {
  String status;
  List<dynamic> messages;
  int id;
  DateTime? lastModifiedTime;
  String? lastModifiedBy;
  bool isActive;
  String name;

  Priority({
    required this.status,
    required this.messages,
    required this.id,
    this.lastModifiedTime,
    this.lastModifiedBy,
    required this.isActive,
    required this.name,
  });

  factory Priority.fromJson(Map<String, dynamic> json) {
    return Priority(
      status: json['status'],
      messages: json['messages'],
      id: json['id'],
      lastModifiedTime: json['lastModifiedTime'] != null
          ? DateTime.parse(json['lastModifiedTime'])
          : null,
      lastModifiedBy: json['lastModifiedBy'],
      isActive: json['isActive'],
      name: json['name'],
    );
  }
  Map<String, dynamic> toJson() => {
        'status': status,
        'messages': messages,
        'id': id,
        'lastModifiedTime': lastModifiedTime?.toIso8601String(),
        'lastModifiedBy': lastModifiedBy,
        'isActive': isActive,
        'name': name,
      };
}

 Future<List<Priority>> fetchPriorities() async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  try {
    final response = await NetworkHelper().request(
      RequestType.get,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/priorities'),
      requestBody: "",
    );
    if (response != null && response.statusCode == 200) {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      final parsed = jsonDecode(response.body)['allPriorities'];
      return List<Priority>.from(parsed.map((json) => Priority.fromJson(json)));
    } else {
      print('Failed to load priorities ${response?.statusCode}');
      throw Exception('Failed to load priorities');
    }
  } catch (e) {
    print('Exception occurred: $e');
    throw e;
  }
}
