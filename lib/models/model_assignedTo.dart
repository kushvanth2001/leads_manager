// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:leads_manager/helper/SharedPrefsHelper.dart';
// import 'package:leads_manager/helper/networkHelper.dart';
// import '../../../domainvariables.dart';
// class AssignedTo {
//   String? status;
//   List<dynamic>? messages;
//   dynamic? pages;
//   dynamic? totalRecords;
//   List<User>? users;

//   AssignedTo({
//     this.status,
//     this.messages,
//     this.pages,
//     this.totalRecords,
//     this.users,
//   });

//   factory AssignedTo.fromJson(Map<String, dynamic> json) {
//     List<dynamic> usersList = json['users'];
//     List<User>? users = usersList.map((user) => User.fromJson(user)).toList();

//     return AssignedTo(
//       status: json['status'] ?? '',
//       messages: json['messages'] ?? [],
//       pages: json['pages'] ?? '',
//       totalRecords: json['totalRecords'] ?? '',
//       users: users,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'status': status,
//         'messages': messages,
//         'pages': pages,
//         'totalRecords': totalRecords,
//         'users': users?.map((user) => user.toJson()).toList(),
//       };


// }

// class User {
//   String? status;
//   List<dynamic>? messages;
//   int? id;
//   String? firstName;
//   int? userId;
//   String? lastName;
//   dynamic? userName;
//   int? mobileNumber;
//   String? emailAddress;
//   dynamic? password;
//   dynamic? isDefault;
//   String? userRole;
//   Role? role;
//   dynamic? pincode;
//   dynamic? supervisor;
//   dynamic? city;
//   dynamic? state;
//   dynamic? country;
//   dynamic? houseNo;
//   String? addressLine1;
//   dynamic? addressLine2;
//   String? addressType;

//   User({
//     this.status,
//     this.messages,
//     this.id,
//     this.firstName,
//     this.userId,
//     this.lastName,
//     this.userName,
//     this.mobileNumber,
//     this.emailAddress,
//     this.password,
//     this.isDefault,
//     this.userRole,
//     this.role,
//     this.pincode,
//     this.supervisor,
//     this.city,
//     this.state,
//     this.country,
//     this.houseNo,
//     this.addressLine1,
//     this.addressLine2,
//     this.addressType,
//   });
//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       status: json['status'] ?? "",
//       messages: json['messages'] ?? [],
//       id: json['id'] ?? 0,
//       firstName: json['firstName'] ?? "",
//       userId: json['userId'] ?? 0,
//       lastName: json['lastName'] ?? "",
//       userName: json['userName'],
//       mobileNumber: json['mobileNumber'] ?? 0,
//       emailAddress: json['emailAddress'] ?? "",
//       password: json['password'],
//       isDefault: json['isDefault'],
//       userRole: json['userRole'] ?? "",
//       role:json['role']!=null? Role.fromJson(json['role']) : Role(),
//       pincode: json['pincode'],
//       supervisor: json['supervisor'],
//       city: json['city'],
//       state: json['state'],
//       country: json['country'],
//       houseNo: json['houseNo'],
//       addressLine1: json['addressLine1'] ?? "",
//       addressLine2: json['addressLine2'],
//       addressType: json['addressType'] ?? "",
//     );
//   }
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['status'] = this.status;
//     data['messages'] = this.messages;
//     data['id'] = this.id;
//     data['firstName'] = this.firstName;
//     data['userId'] = this.userId;
//     data['lastName'] = this.lastName;
//     data['userName'] = this.userName;
//     data['mobileNumber'] = this.mobileNumber;
//     data['emailAddress'] = this.emailAddress;
//     data['password'] = this.password;
//     data['isDefault'] = this.isDefault;
//     data['userRole'] = this.userRole;
//     data['role'] = this.role?.toJson();
//     data['pincode'] = this.pincode;
//     data['supervisor'] = this.supervisor;
//     data['city'] = this.city;
//     data['state'] = this.state;
//     data['country'] = this.country;
//     data['houseNo'] = this.houseNo;
//     data['addressLine1'] = this.addressLine1;
//     data['addressLine2'] = this.addressLine2;
//     data['addressType'] = this.addressType;
//     return data;
//   }
// }

// class Role {
//   final int? id;
//   final String? name;
//   final String? description;
//   final int? userId;
//   final bool? isInternal;
//   final List<dynamic>? features;

//   Role({
//     this.id,
//     this.name,
//     this.description,
//     this.userId,
//     this.isInternal,
//     List<dynamic>? features,
//   }) : this.features = features ?? [];

//   factory Role.fromJson(Map<String, dynamic> json) {
//     return Role(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       description: json['description'] ?? '',
//       userId: json['userId'] ?? 0,
//       isInternal: json['isInternal'] ?? false,
//       features:
//           json['features'] != null ? List<dynamic>.from(json['features']) : [],
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'name': name,
//         'description': description,
//         'userId': userId,
//         'isInternal': isInternal,
//         'features': features,
//       };
// }


