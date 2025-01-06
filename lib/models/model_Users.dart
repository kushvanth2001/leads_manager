// To parse this JSON data, do
//
//     final users = usersFromJson(jsonString);

import 'dart:convert';
import '../helper/SharedPrefsHelper.dart';
import '../helper/networkHelper.dart';
import 'model_Merchants.dart';
import '../../../domainvariables.dart';
UsersModel usersModelFromJson(String str) =>
    UsersModel.fromJson(json.decode(str));

String usersModelToJson(UsersModel data) => json.encode(data.toJson());

List<User> userListFromJson(String str) =>
    List<User>.from(jsonDecode(str).map((json) => User.fromJson(json)));

class UsersModel {
  UsersModel({
    this.status,
    this.messages,
    this.pages,
    this.totalRecords,
    this.users,
  });

  String? status;
  List<dynamic>? messages;
  dynamic pages;
  dynamic totalRecords;
  List<User>? users;

  factory UsersModel.fromJson(Map<String, dynamic> json) => UsersModel(
        status: json["status"],
        messages: [],
        pages: json["pages"],
        totalRecords: json["totalRecords"],
        users: json["users"] == null
            ? []
            : List<User>.from(json["users"].map((x) => User.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "pages": pages,
        "totalRecords": totalRecords,
        "users": users == null
            ? []
            : List<dynamic>.from(users!.map((x) => x.toJson())),
      };

 Future<UsersModel?> fetchUsers() async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";
    String url =
        'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/users?isInternal=true&isPrivilageRequired=false';

  
    final response = await NetworkHelper().request(
      RequestType.get,
      Uri.parse(url),
      requestBody: "",
    );

    if (response != null && response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UsersModel.fromJson(data);
    } else {
      throw Exception('Failed to load data');
    }
}


}
