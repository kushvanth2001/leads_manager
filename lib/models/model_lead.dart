import 'dart:convert';
import 'package:leads_manager/models/model_customColumn.dart';
import 'package:leads_manager/models/model_leadDetails.dart' as detailsmodel;
import 'package:leads_manager/models/model_leadsource.dart';
import 'package:leads_manager/models/model_tag.dart';

import 'model_Merchants.dart';

LeadModel leadModelFromJson(String str) => LeadModel.fromJson(json.decode(str));

String leadModelToJson(LeadModel leadModel) => json.encode(leadModel.toJson());

class LeadModel {
 LeadModel(
      {this.status, this.messages, this.leads, this.totalRecords, this.pages});

  String? status;
  List<String>? messages;
  List<Lead>? leads;
  int? totalRecords;
  int? pages;

  factory LeadModel.fromJson(Map<String, dynamic> json) => LeadModel(
      status: json["status"],
      messages: [],
      leads: json["leads"] == null
          ? []
          : List<Lead>.from(json["leads"].map((x) => Lead.fromJson(x))),
      totalRecords: json["totalRecords"],
      pages: json["pages"]);

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "leads":
            leads == null ? [] : List<Lead>.from(leads!.map((x) => x.toJson())),
        "totalRecords": totalRecords,
        "pages": pages,
      };
}

class Lead {
  Lead(
      {this.status,
      this.messages,
      this.id,
      this.lastModifiedTime,
      this.lastModifiedBy,
      this.isActive,
      this.customer,
      this.clientGroupId,
      this.customerName,
      this.organizationName,
      this.mobileNumber,
      this.alternateMobileNumber2,
      this.email,
      this.alternateEmail,
      this.city,
      this.state,
      this.country,
      this.countryCode,
      this.pincode,
      this.fullAddress,
      this.assignedTo,
      this.leadStatus,
      this.leadSource,
      this.createdOn,
      this.tagsDto,
      this.assignedBy,
      this.priorityId,
      this.createdBy,
      this.potentialDealValue,
      this.actualDealValue,
      this.score,
      this.customColumns,
      this.followUpDate});

  String? status;
  List<String>? messages;
  int? id;
  dynamic lastModifiedTime;
  dynamic lastModifiedBy;
  bool? isActive;
  dynamic customer;
  int? clientGroupId;
  String? customerName;
  String? organizationName;
  String? mobileNumber;
  String? alternateMobileNumber2;
  String? email;
  String? alternateEmail;
  String? city;
  String? state;
  String? country;
  String? countryCode;
  int? pincode;
  String? fullAddress;
  AssignedTo? assignedTo;
  LeadStatus? leadStatus;
 LeadSource? leadSource;
  DateTime? createdOn;
  TagsDto? tagsDto;
  AssignedBy? assignedBy;
  LeadStatus? priorityId;
  String? createdBy;
  dynamic potentialDealValue;
  dynamic actualDealValue;
  String? followUpDate;
  int? score;
  List<CustomColumn>? customColumns;
  factory Lead.fromJson(Map<String, dynamic> json) {
    var customColumnsJson = json['customColumns'] as List<dynamic>?;

    List<CustomColumn>? customColumns;
    if (customColumnsJson != null) {
      customColumns = customColumnsJson
          .map((columnJson) => CustomColumn.fromJson(columnJson))
          .toList();
    }
    return Lead(
      status: json["status"],
      messages: [],
      id: json["id"],
      lastModifiedTime: json["lastModifiedTime"],
      lastModifiedBy: json["lastModifiedBy"],
      isActive: json["isActive"],
      customer: json["customer"],
      clientGroupId: json["clientGroupId"],
      customerName: json["customerName"],
      organizationName: json["organizationName"],
      mobileNumber: json["mobileNumber"],
      alternateMobileNumber2: json["alternateMobileNumber2"],
      email: json["email"],
      alternateEmail: json["alternateEmail"],
      city: json["city"],
      state: json["state"],
      country: json["country"],
      countryCode: json["countryCode"],
      pincode: json["pincode"],
      fullAddress: json["fullAddress"],
      assignedTo: json["assignedTo"] == null
          ? null
          : AssignedTo.fromJson(json["assignedTo"]),
      leadStatus: json["leadStatus"] == null
          ? null
          : LeadStatus.fromJson(json["leadStatus"]),
      leadSource: json["leadSource"] == null
          ? null
          : LeadSource.fromJson(json["leadSource"]),
      createdOn:
          json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
      tagsDto:json["tagsDTO"] == null ? null : TagsDto.fromJson(json["tagsDTO"]),
      assignedBy: json["assignedBy"] == null
          ? null
          : AssignedBy.fromJson(json["assignedBy"]),
      priorityId: json["priorityId"] == null
          ? null
          : LeadStatus.fromJson(json["priorityId"]),
      createdBy: json["createdBy"],
      potentialDealValue: json["potentialDealValue"],
      actualDealValue: json["actualDealValue"],
      score: json["score"],
      customColumns: customColumns,
      followUpDate:json["followUpDate"]
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "messages": [],
      "id": id,
      "lastModifiedTime": lastModifiedTime,
      "lastModifiedBy": lastModifiedBy,
      "isActive": isActive,
      "customer": customer,
      "clientGroupId": clientGroupId,
      "customerName": customerName,
      "organizationName": organizationName,
      "mobileNumber": mobileNumber,
      "alternateMobileNumber2": alternateMobileNumber2,
      "email": email,
      "alternateEmail": alternateEmail,
      "city": city,
      "state": state,
      "country": country,
      "countryCode": countryCode,
      "pincode": pincode,
      "fullAddress": fullAddress,
      "assignedTo": assignedTo == null ? null : assignedTo!.toJson(),
      "leadStatus": leadStatus == null ? null : leadStatus!.toJson(),
      "leadSource": leadSource == null ? null : leadSource!.toJson(),
      "createdOn": createdOn == null ? null : createdOn!.toIso8601String(),
      "tagsDTO": tagsDto == null ? null : tagsDto!.toJson(),
      "assignedBy": assignedBy,
      "priorityId": priorityId == null ? null : priorityId!.toJson(),
      "createdBy": createdBy,
      "potentialDealValue": potentialDealValue,
      "actualDealValue": actualDealValue,
      "customColumns": customColumns?.map((column) => column.toJson()).toList(),
      "followUpDate":followUpDate
    };
  }
}

class AssignedBy {
  AssignedBy({
    this.status,
    this.messages,
    this.id,
    this.firstName,
    this.userId,
    this.lastName,
    this.userName,
    this.mobileNumber,
    this.emailAddress,
    this.password,
    this.isDefault,
    this.userRole,
    this.role,
    this.pincode,
    this.supervisor,
    this.city,
    this.state,
    this.country,
    this.houseNo,
    this.addressLine1,
    this.addressLine2,
    this.addressType,
  });

  String? status;
  List<dynamic>? messages;
  int? id;
  String? firstName;
  int? userId;
  String? lastName;
  dynamic userName;
  int? mobileNumber;
  String? emailAddress;
  dynamic password;
  dynamic isDefault;
  String? userRole;
  Role? role;
  int? pincode;
  Supervisor? supervisor;
  String? city;
  String? state;
  String? country;
  String? houseNo;
  String? addressLine1;
  dynamic addressLine2;
  String? addressType;

  factory AssignedBy.fromJson(Map<String, dynamic> json) => AssignedBy(
        status: json["status"],
        messages: [],
        id: json["id"],
        firstName: json["firstName"],
        userId: json["userId"],
        lastName: json["lastName"],
        userName: json["userName"],
        mobileNumber: json["mobileNumber"],
        emailAddress: json["emailAddress"],
        password: json["password"],
        isDefault: json["isDefault"],
        userRole: json["userRole"],
        role: Role.fromJson(json["role"]),
        pincode: json["pincode"],
        supervisor: json["supervisor"] == null
            ? null
            : Supervisor.fromJson(json["supervisor"]),
        city: json["city"],
        state: json["state"],
        country: json["country"],
        houseNo: json["houseNo"],
        addressLine1: json["addressLine1"],
        addressLine2: json["addressLine2"],
        addressType: json["addressType"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "id": id,
        "firstName": firstName,
        "userId": userId,
        "lastName": lastName,
        "userName": userName,
        "mobileNumber": mobileNumber,
        "emailAddress": emailAddress,
        "password": password,
        "isDefault": isDefault,
        "userRole": userRole,
        "role": role == null ? null : role!.toJson(),
        "pincode": pincode,
        "supervisor": supervisor,
        "city": city,
        "state": state,
        "country": country,
        "houseNo": houseNo,
        "addressLine1": addressLine1,
        "addressLine2": addressLine2,
        "addressType": addressType,
      };
}

class Supervisor {
  String? status;
  List<dynamic>? messages;
  int? id;
  String? firstName;
  int? userId;
  String? lastName;
  String? userName;
  int? mobileNumber;
  String? emailAddress;
  dynamic password;
  dynamic isDefault;
  String? userRole;
  Role? role;
  dynamic pincode;
  dynamic supervisor; // This seems to be null in JSON, so it can be dynamic
  String? addressLine1;
  String? addressLine2;
  String? addressType;

  Supervisor(
      {this.status,
      this.messages,
      this.id,
      this.firstName,
      this.userId,
      this.lastName,
      this.userName,
      this.mobileNumber,
      this.emailAddress,
      this.password,
      this.isDefault,
      this.userRole,
      this.role,
      this.pincode,
      this.supervisor,
      this.addressLine1,
      this.addressLine2,
      this.addressType});

  factory Supervisor.fromJson(Map<String, dynamic> json) {
    return Supervisor(
        status: json['status'],
        messages: json['messages'],
        id: json['id'],
        firstName: json['firstName'],
        userId: json['userId'],
        lastName: json['lastName'],
        userName: json['userName'],
        mobileNumber: json['mobileNumber'],
        emailAddress: json['emailAddress'],
        password: json['password'],
        isDefault: json['isDefault'],
        userRole: json['userRole'],
        role: json['role'] == null ? null : Role.fromJson(json['role']),
        pincode: json['pincode'],
        supervisor: json['supervisor'],
        addressLine1: json['addressLine1'],
        addressLine2: json['addressLine2'],
        addressType: json['addressType']);
  }
}

class AssignedTo {
  AssignedTo({
    this.status,
    this.messages,
    this.id,
    this.firstName,
    this.userId,
    this.lastName,
    this.userName,
    this.mobileNumber,
    this.emailAddress,
    this.password,
    this.isDefault,
    this.userRole,
    this.role,
    this.pincode,
    this.city,
    this.state,
    this.country,
    this.houseNo,
    this.addressLine1,
    this.addressLine2,
    this.addressType,
  });

  String? status;
  List<dynamic>? messages;
  int? id;
  String? firstName;
  int? userId;
  String? lastName;
  dynamic userName;
  int? mobileNumber;
  String? emailAddress;
  dynamic password;
  dynamic isDefault;
  String? userRole;
  Role? role;
  int? pincode;
  String? city;
  String? state;
  String? country;
  String? houseNo;
  String? addressLine1;
  dynamic addressLine2;
  String? addressType;

  factory AssignedTo.fromJson(Map<String, dynamic> json) => AssignedTo(
        status: json["status"],
        messages: [],
        id: json["id"],
        firstName: json["firstName"],
        userId: json["userId"],
        lastName: json["lastName"],
        userName: json["userName"],
        mobileNumber: json["mobileNumber"],
        emailAddress: json["emailAddress"],
        password: json["password"],
        isDefault: json["isDefault"],
        userRole: json["userRole"],
        role:json['roler']!=null?  Role.fromJson(json["role"]):null,
        pincode: json["pincode"],
        city: json["city"],
        state: json["state"],
        country: json["country"],
        houseNo: json["houseNo"],
        addressLine1: json["addressLine1"],
        addressLine2: json["addressLine2"],
        addressType: json["addressType"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "id": id,
        "firstName": firstName,
        "userId": userId,
        "lastName": lastName,
        "userName": userName,
        "mobileNumber": mobileNumber,
        "emailAddress": emailAddress,
        "password": password,
        "isDefault": isDefault,
        "userRole": userRole,
        "role": role == null ? null : role!.toJson(),
        "pincode": pincode,
        "city": city,
        "state": state,
        "country": country,
        "houseNo": houseNo,
        "addressLine1": addressLine1,
        "addressLine2": addressLine2,
        "addressType": addressType,
      };
}

class LeadStatus {
  LeadStatus({
    this.status,
    this.messages,
    this.id,
    this.statusName,
    this.lastModifiedTime,
    this.lastModifiedBy,
    this.isActive,
    this.clientGroupId,
    this.name,
  });

  String? status;
  List<dynamic>? messages;
  int? id;
  String? statusName;
  dynamic lastModifiedTime;
  dynamic lastModifiedBy;
  bool? isActive;
  dynamic clientGroupId;
  String? name;

  factory LeadStatus.fromJson(Map<String, dynamic> json) => LeadStatus(
        status: json["status"],
        messages: [],
        id: json["id"],
        statusName: json["statusName"],
        lastModifiedTime: json["lastModifiedTime"],
        lastModifiedBy: json["lastModifiedBy"],
        isActive: json["isActive"],
        clientGroupId: json["clientGroupId"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "id": id,
        "statusName": statusName,
        "lastModifiedTime": lastModifiedTime,
        "lastModifiedBy": lastModifiedBy,
        "isActive": isActive,
        "clientGroupId": clientGroupId,
        "name": name,
      };
}

// class LeadSource {
//   LeadSource({
//     this.status,
//     this.messages,
//     this.id,
//     this.sourceName,
//   });

//   String? status;
//   List<dynamic>? messages;
//   int? id;
//   String? sourceName;


//   factory LeadSource.fromJson(Map<String, dynamic> json) => LeadSource(
//       status: json["status"],
//       messages: [],
//       id: json["id"],
//       sourceName: json["sourceName"]);

//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "messages": [],
//         "id": id,
//         "sourceName": sourceName,
//       };
// }

TagsDto tagsDtoFromJson(String str) => TagsDto.fromJson(json.decode(str));

String tagsDtoToJson(TagsDto data) => json.encode(data.toJson());

List<Tag> tagListFromJson(String str) =>
    List<Tag>.from(json.decode(str).map((x) => Tag.fromJson(x)));

class TagsDto {
  TagsDto({this.tags});

  List<Tag>? tags;

  factory TagsDto.fromJson(Map<String, dynamic> json) => TagsDto(
        tags: json["tags"] == null
            ? []
            : List<Tag>.from(json["tags"].map((x) => Tag.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "tags": tags == null
            ? []
            : List<dynamic>.from(tags!.map((x) => x.toJson())),
      };
}

// class Tag {
//   Tag({
//     this.status,
//     this.messages,
//     this.id,
//     this.name,
//     this.type,
//     this.clientGroupId,
//     this.color,
//     this.description,
//   });

//   String? status;
//   List<String>? messages;
//   int? id;
//   String? name;
//   String? type;
//   int? clientGroupId;
//   String? color;
//   String? description;



//   factory Tag.fromJson(Map<String, dynamic> json) => Tag(
//         status: json["status"],
//         messages: [],
//         id: json["id"],
//         name: json["name"],
//         type: json["type"],
//         clientGroupId: json["clientGroupId"],
//         color: json["color"],
//         description: json["description"],
//       );

//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "messages": [],
//         "id": id,
//         "name": name,
//         "type": type,
//         "clientGroupId": clientGroupId,
//         "color": color,
//         "description": description,
//       };
//   dynamic operator [](String propertyName) {
//     switch (propertyName) {
//       case 'status':
//         return status;
//       case 'messages':
//         return messages;
//       case 'id':
//         return id;
//       case 'name':
//         return name;
//       case 'type':
//         return type;
//       case 'clientGroupId':
//         return clientGroupId;
//       case 'color':
//         return color;
//       case 'description':
//         return description;
//       default:
//         throw ArgumentError('Invalid property name: $propertyName');
//     }
//   }
// }
