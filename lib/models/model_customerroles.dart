import 'dart:convert';

import '../helper/SharedPrefsHelper.dart';
import '../helper/networkHelper.dart';
import '../../../domainvariables.dart';
class CustomerRole {
  final int id;
  final String name;
  final String? parentName;
  final int? parentId;
  final String? description;
  final bool autoApprove;
  final bool isVisible;

  CustomerRole({
    required this.id,
    required this.name,
    this.parentName,
    this.parentId,
    this.description,
    required this.autoApprove,
    required this.isVisible,
  });

  factory CustomerRole.fromJson(Map<String, dynamic> json) {
    return CustomerRole(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      parentName: json['parentName'],
      parentId: json['parentId'],
      description: json['description'],
      autoApprove: json['autoApprove'] ?? false,
      isVisible: json['isVisible'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentName': parentName,
      'parentId': parentId,
      'description': description,
      'autoApprove': autoApprove,
      'isVisible': isVisible,
    };
  }

 static Future<List<CustomerRole>> fetchCustomerRoles() async {
  try {
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";
    final response = await NetworkHelper().request(
      RequestType.get,
      Uri.parse('https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/customers-roles'),
      requestBody: "",
    );

    print('Response for customer roles: ${response?.body}');

    if (response != null && response.statusCode == 200) {
      dynamic parsed = json.decode(response.body);
parsed= parsed["customerRoles"];
      if (parsed != null && parsed is List<dynamic>) {
        final List<CustomerRole> roles = parsed
            .map((json) => CustomerRole.fromJson(json))
            .toList();

        return roles;
      } else {
        print('Invalid response format for customer roles');
        throw Exception('Invalid response format');
      }
    } else {
      print('Failed to load customer roles');
      throw Exception('Failed to load customer roles');
    }
  } catch (e) {
    print('Exception occurred while fetching customer roles: $e');
    throw e;
  }
}

}
