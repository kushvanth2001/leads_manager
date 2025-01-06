import 'dart:convert';
import 'package:flutter/material.dart'; // Import Flutter material for `setState`

import '../helper/SharedPrefsHelper.dart';
import '../helper/networkHelper.dart';
import '../../../domainvariables.dart';
class ContactList {
  List<String> contactsList;
  String status;

  ContactList({required this.contactsList, required this.status});

  factory ContactList.fromJson(Map<String, dynamic> json) {
    return ContactList(
      contactsList: List<String>.from(json['contactsList']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contactsList': contactsList,
      'status': status,
    };
  }

  Future<List<String>> fetchContactLists() async {
    String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";
    try {
      final response = await NetworkHelper().request(
        RequestType.get,
        Uri.parse('https://${Globals.DomainPointer}/snappe-services-pt/rest/v1/merchant/$clientGroupName/contacts_list?limit=150&page_no=0&sort_order=asc'),
        requestBody: "",
      );

      if (response != null && response.statusCode == 200) {
        final parsed = json.decode(response.body);

        if (parsed != null && parsed is Map<String, dynamic>) {
          List<String> fetchedContactLists = List<String>.from(parsed['contactsList']);
          return fetchedContactLists;
        } else {
          print('Invalid response format');
          throw Exception('Invalid response format');
        }
      } else {
        print('Failed to load contact lists');
        throw Exception('Failed to load contact lists');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw e;
    }
  }
}
