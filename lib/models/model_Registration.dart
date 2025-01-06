// To parse this JSON data, do
//
//     final registration = registrationFromJson(jsonString);

import 'dart:convert';

RegistrationModel registrationFromJson(String str) =>
    RegistrationModel.fromJson(json.decode(str));

String registrationToJson(RegistrationModel data) => json.encode(data.toJson());

class RegistrationModel {
  RegistrationModel({
    this.status,
    this.messages,
    this.id,
    this.clientName,
    this.firstName,
    this.lastName,
    this.email,
    this.userName,
    this.password,
    this.clientGroupName,
    this.displayName,
    this.website,
    this.city,
    this.pincode,
    this.logoUrl,
    this.addressLine1,
    this.addressLine2,
    this.lattitude,
    this.longitude,
    this.houseNo,
    this.clientgroup,
    this.addressType,
    this.applications,
    this.countryCode,
    this.mobileNumber,
    this.applicationId,
    this.subMerchantUpiCodeId,
    this.categories,
    this.mode,
    this.sampleClientGroupId,
    this.planId,
    this.kycDetails,
    this.modules,
    this.source,
    this.community,
    this.users,
  });

  String? status;
  List<String>? messages;
  int? id;
  String? clientName;
  String? firstName;
  String? lastName;
  String? email;
  String? userName;
  String? password;
  String? clientGroupName;
  String? displayName;
  String? website;
  String? city;
  int? pincode;
  String? logoUrl;
  String? addressLine1;
  String? addressLine2;
  dynamic lattitude;
  dynamic longitude;
  dynamic houseNo;
  dynamic clientgroup;
  String? addressType;
  Applications? applications;
  String? countryCode;
  String? mobileNumber;
  dynamic applicationId;
  dynamic subMerchantUpiCodeId;
  dynamic categories;
  String? mode;
  dynamic sampleClientGroupId;
  dynamic planId;
  KycDetails? kycDetails;
  List<dynamic>? modules;
  dynamic source;
  List<dynamic>? community;
  List<dynamic>? users;

  factory RegistrationModel.fromJson(Map<String, dynamic> json) =>
      RegistrationModel(
        status: json["status"],
        messages: [],
        id: json["id"],
        clientName: json["clientName"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        email: json["email"],
        userName: json["userName"],
        password: json["password"],
        clientGroupName: json["clientGroupName"],
        displayName: json["displayName"],
        website: json["website"],
        city: json["city"],
        pincode: json["pincode"],
        logoUrl: json["logoUrl"],
        addressLine1: json["addressLine1"],
        addressLine2: json["addressLine2"],
        lattitude: json["lattitude"],
        longitude: json["longitude"],
        houseNo: json["houseNo"],
        clientgroup: json["clientgroup"],
        addressType: json["addressType"],
        applications: Applications.fromJson(json["applications"]),
        countryCode: json["countryCode"],
        mobileNumber: json["mobileNumber"],
        applicationId: json["applicationId"],
        subMerchantUpiCodeId: json["subMerchantUpiCodeId"],
        categories: json["categories"],
        mode: json["mode"],
        sampleClientGroupId: json["sampleClientGroupId"],
        planId: json["planId"],
        kycDetails: KycDetails.fromJson(json["kycDetails"]),
        modules: json["modules"] == null
            ? []
            : List<dynamic>.from(json["modules"].map((x) => x)),
        source: json["source"],
        community: json["community"] == null
            ? []
            : List<dynamic>.from(json["community"].map((x) => x)),
        users: json["users"] == null
            ? []
            : List<dynamic>.from(json["users"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "id": id,
        "clientName": clientName,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "userName": userName,
        "password": password,
        "clientGroupName": clientGroupName,
        "displayName": displayName,
        "website": website,
        "city": city,
        "pincode": pincode,
        "logoUrl": logoUrl,
        "addressLine1": addressLine1,
        "addressLine2": addressLine2,
        "lattitude": lattitude,
        "longitude": longitude,
        "houseNo": houseNo,
        "clientgroup": clientgroup,
        "addressType": addressType,
        "applications": applications == null ? null : applications!.toJson(),
        "countryCode": countryCode,
        "mobileNumber": mobileNumber,
        "applicationId": applicationId,
        "subMerchantUpiCodeId": subMerchantUpiCodeId,
        "categories": categories,
        "mode": mode,
        "sampleClientGroupId": sampleClientGroupId,
        "planId": planId,
        "kycDetails": kycDetails == null ? null : kycDetails!.toJson(),
        "modules":
            modules == null ? [] : List<dynamic>.from(modules!.map((x) => x)),
        "source": source,
        "community": community == null
            ? []
            : List<dynamic>.from(community!.map((x) => x)),
        "users": users == null ? [] : List<dynamic>.from(users!.map((x) => x)),
      };
}

class Applications {
  Applications({
    this.status,
    this.messages,
    this.application,
  });

  String? status;
  List<String>? messages;
  List<dynamic>? application;

  factory Applications.fromJson(Map<String, dynamic> json) => Applications(
        status: json["status"],
        messages: [],
        application: json["application"] == null
            ? null
            : List<dynamic>.from(json["application"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "application": application == null
            ? null
            : List<dynamic>.from(application!.map((x) => x)),
      };
}

class KycDetails {
  KycDetails({
    this.status,
    this.messages,
    this.id,
    this.gstNo,
    this.gstFile,
    this.panNo,
    this.panFile,
    this.custmerId,
    this.clientGroupId,
  });

  String? status;
  List<String>? messages;
  dynamic id;
  dynamic gstNo;
  dynamic gstFile;
  dynamic panNo;
  dynamic panFile;
  dynamic custmerId;
  dynamic clientGroupId;

  factory KycDetails.fromJson(Map<String, dynamic> json) => KycDetails(
        status: json["status"],
        messages: [],
        id: json["id"],
        gstNo: json["gstNo"],
        gstFile: json["gstFile"],
        panNo: json["panNo"],
        panFile: json["panFile"],
        custmerId: json["custmerId"],
        clientGroupId: json["clientGroupId"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "id": id,
        "gstNo": gstNo,
        "gstFile": gstFile,
        "panNo": panNo,
        "panFile": panFile,
        "custmerId": custmerId,
        "clientGroupId": clientGroupId,
      };
}
