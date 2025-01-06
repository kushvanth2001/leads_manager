// To parse this JSON data, do
//
//     final merchantsModel = merchantsModelFromJson(jsonString);

import 'dart:convert';

MerchantsModel merchantsModelFromJson(String str) =>
    MerchantsModel.fromJson(json.decode(str));

String merchantsModelToJson(MerchantsModel data) => json.encode(data.toJson());

User userFromJson(String str) => User.fromJson(json.decode(str));

class MerchantsModel {
  MerchantsModel({
    this.status,
    this.messages,
    this.merchants,
  });

  String? status;
  List<String>? messages;
  List<Merchant>? merchants;

  factory MerchantsModel.fromJson(Map<String, dynamic> json) => MerchantsModel(
        status: json["status"],
        messages: [],
        merchants: List<Merchant>.from(
            json["merchants"].map((x) => Merchant.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "merchants": merchants == null
            ? []
            : List<dynamic>.from(merchants!.map((x) => x.toJson())),
      };
}

class Merchant {
  Merchant({
    this.status,
    this.messages,
    this.clientName,
    this.clientGroupName,
    this.role,
    this.phoneNo,
    this.displayName,
    this.userId,
    this.mode,
    this.user,
    this.clientId,
  });

  String? status;
  List<String>? messages;
  String? clientName;
  String? clientGroupName;
  String? role;
  String? phoneNo;
  String? displayName;
  int? userId;
  String? mode;
  User? user;
  int? clientId;

  factory Merchant.fromJson(Map<String, dynamic> json) => Merchant(
        status: json["status"],
        messages: [],
        clientName: json["clientName"],
        clientGroupName: json["clientGroupName"],
        role: json["role"],
        phoneNo: json["phoneNo"],
        displayName: json["displayName"],
        userId: json["userId"],
        mode: json["mode"],
        user: User.fromJson(json["user"]),
        clientId: json["clientId"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "clientName": clientName,
        "clientGroupName": clientGroupName,
        "role": role,
        "phoneNo": phoneNo,
        "displayName": displayName,
        "userId": userId,
        "mode": mode,
        "user": user == null ? null : user!.toJson(),
        "clientId": clientId,
      };
}

class User {
  User({
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
  List<String>? messages;
  int? id;
  String? firstName;
  int? userId;
  String? lastName;
  String? userName;
  int? mobileNumber;
  String? emailAddress;
  String? password;
  bool? isDefault;
  String? userRole;
  Role? role;
  int? pincode;
  String? city;
  String? state;
  String? country;
  String? houseNo;
  String? addressLine1;
  String? addressLine2;
  String? addressType;

  factory User.fromJson(Map<String, dynamic> json) => User(
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
        role:json["role"]!=null? Role.fromJson(json["role"]):null,
        pincode: json["pincode"],
        city: json["city"] == null ? null : json["city"],
        state: json["state"] == null ? null : json["state"],
        country: json["country"] == null ? null : json["country"],
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
        "city": city == null ? null : city,
        "state": state == null ? null : state,
        "country": country == null ? null : country,
        "houseNo": houseNo,
        "addressLine1": addressLine1,
        "addressLine2": addressLine2,
        "addressType": addressType,
      };
      dynamic operator [](String propertyName) {
    switch (propertyName) {
       case 'fullName':
        return fullName;
      case 'status':
        return status;
      case 'messages':
        return messages;
      case 'id':
        return id;
      case 'firstName':
        return firstName;
      case 'userId':
        return userId;
      case 'lastName':
        return lastName;
      case 'userName':
        return userName;
      case 'mobileNumber':
        return mobileNumber;
      case 'emailAddress':
        return emailAddress;
      case 'password':
        return password;
      case 'isDefault':
        return isDefault;
      case 'userRole':
        return userRole;
      case 'role':
        return role;
      case 'pincode':
        return pincode;
      case 'city':
        return city;
      case 'state':
        return state;
      case 'country':
        return country;
      case 'houseNo':
        return houseNo;
      case 'addressLine1':
        return addressLine1;
      case 'addressLine2':
        return addressLine2;
      case 'addressType':
        return addressType;
      default:
        throw ArgumentError('Invalid property name: $propertyName');
    }
  }
    String get fullName => "$firstName $lastName";
}

class Role {
  Role({
    this.id,
    this.name,
    this.description,
    this.userId,
    this.isInternal,
    this.features,
  });

  int? id;
  String? name;
  String? description;
  int? userId;
  bool? isInternal;
  List<Feature>? features;

  factory Role.fromJson(Map<String, dynamic> json) => Role(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        userId: json["userId"],
        isInternal: json["isInternal"],
        features: List<Feature>.from(
            json["features"].map((x) => Feature.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "userId": userId,
        "isInternal": isInternal,
        "features": features == null
            ? null
            : List<dynamic>.from(features!.map((x) => x.toJson())),
      };
}

class Feature {
  Feature({
    this.id,
    this.name,
    this.description,
    this.privilages,
  });

  int? id;
  String? name;
  String? description;
  List<Privilage>? privilages;

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        privilages: List<Privilage>.from(
            json["privilages"].map((x) => Privilage.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "privilages": privilages == null
            ? null
            : List<dynamic>.from(privilages!.map((x) => x.toJson())),
      };
}

class Privilage {
  Privilage({
    this.id,
    this.name,
    this.displayName,
    this.checked,
  });

  int? id;
  String? name;
  String? displayName;
  bool? checked;

  factory Privilage.fromJson(Map<String, dynamic> json) => Privilage(
        id: json["id"],
        name: json["name"],
        displayName: json["displayName"],
        checked: json["checked"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "displayName": displayName,
        "checked": checked,
      };
}
