// To parse this JSON data, do
//
//     final merchantProfile = merchantProfileFromJson(jsonString);

import 'dart:convert';

MerchantProfile merchantProfileFromJson(String str) =>
    MerchantProfile.fromJson(json.decode(str));

String merchantProfileToJson(MerchantProfile data) =>
    json.encode(data.toJson());

class MerchantProfile {
  MerchantProfile({
    this.status,
    this.messages,
    this.merchantName,
    this.phoneNo,
    this.bankAccountNumber,
    this.bankName,
    this.ifsc,
    this.upiCode,
    this.mode,
    this.categories,
    this.kycDetails,
    this.user,
  });

  String? status;
  List<String>? messages;
  String? merchantName;
  String? phoneNo;
  String? bankAccountNumber;
  String? bankName;
  String? ifsc;
  String? upiCode;
  String? mode;
  List<Category>? categories;
  KycDetails? kycDetails;
  User? user;

  factory MerchantProfile.fromJson(Map<String, dynamic> json) =>
      MerchantProfile(
        status: json["status"] == null ? null : json["status"],
        messages: json["messages"] == null
            ? null
            : List<String>.from(json["messages"].map((x) => x)),
        merchantName:
            json["merchantName"] == null ? null : json["merchantName"],
        phoneNo: json["phoneNo"] == null ? null : json["phoneNo"],
        bankAccountNumber: json["bankAccountNumber"] == null
            ? null
            : json["bankAccountNumber"],
        bankName: json["bankName"] == null ? null : json["bankName"],
        ifsc: json["ifsc"] == null ? null : json["ifsc"],
        upiCode: json["upiCode"] == null ? null : json["upiCode"],
        mode: json["mode"] == null ? null : json["mode"],
        categories: json["categories"] == null
            ? null
            : List<Category>.from(
                json["categories"].map((x) => Category.fromJson(x))),
        kycDetails: json["kycDetails"] == null
            ? null
            : KycDetails.fromJson(json["kycDetails"]),
        user: json["user"] == null ? null : User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status == null ? null : status,
        "messages": messages == null
            ? null
            : List<dynamic>.from(messages!.map((x) => x)),
        "merchantName": merchantName == null ? null : merchantName,
        "phoneNo": phoneNo == null ? null : phoneNo,
        "bankAccountNumber":
            bankAccountNumber == null ? null : bankAccountNumber,
        "bankName": bankName == null ? null : bankName,
        "ifsc": ifsc == null ? null : ifsc,
        "upiCode": upiCode == null ? null : upiCode,
        "mode": mode == null ? null : mode,
        "categories": categories == null
            ? null
            : List<dynamic>.from(categories!.map((x) => x)),
        "kycDetails": kycDetails == null ? null : kycDetails!.toJson(),
        "user": user == null ? null : user!.toJson(),
      };
}

class Category {
  Category({
    this.status,
    this.messages,
    this.id,
    this.category,
    this.description,
    this.imageUrl,
    this.bannerUrl,
    this.icon,
    this.subCategories,
    this.other,
  });

  String? status;
  List<String>? messages;
  int? id;
  String? category;
  String? description;
  String? imageUrl;
  String? bannerUrl;
  String? icon;
  List<dynamic>? subCategories;
  dynamic other;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        status: json["status"] == null ? null : json["status"],
        messages: json["messages"] == null
            ? null
            : List<String>.from(json["messages"].map((x) => x)),
        id: json["id"] == null ? null : json["id"],
        category: json["category"] == null ? null : json["category"],
        description: json["description"],
        imageUrl: json["imageUrl"] == null ? null : json["imageUrl"],
        bannerUrl: json["bannerUrl"] == null ? null : json["bannerUrl"],
        icon: json["icon"] == null ? null : json["icon"],
        subCategories: json["subCategories"] == null
            ? null
            : List<dynamic>.from(json["subCategories"].map((x) => x)),
        other: json["other"],
      );

  Map<String, dynamic> toJson() => {
        "status": status == null ? null : status,
        "messages": messages == null
            ? null
            : List<dynamic>.from(messages!.map((x) => x)),
        "id": id == null ? null : id,
        "category": category == null ? null : category,
        "description": description,
        "imageUrl": imageUrl == null ? null : imageUrl,
        "bannerUrl": bannerUrl == null ? null : bannerUrl,
        "icon": icon == null ? null : icon,
        "subCategories": subCategories == null
            ? null
            : List<dynamic>.from(subCategories!.map((x) => x)),
        "other": other,
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
  int? id;
  String? gstNo;
  dynamic gstFile;
  String? panNo;
  dynamic panFile;
  dynamic custmerId;
  int? clientGroupId;

  factory KycDetails.fromJson(Map<String, dynamic> json) => KycDetails(
        status: json["status"] == null ? null : json["status"],
        messages: json["messages"] == null
            ? null
            : List<String>.from(json["messages"].map((x) => x)),
        id: json["id"] == null ? null : json["id"],
        gstNo: json["gstNo"] == null ? null : json["gstNo"],
        gstFile: json["gstFile"],
        panNo: json["panNo"] == null ? null : json["panNo"],
        panFile: json["panFile"],
        custmerId: json["custmerId"],
        clientGroupId:
            json["clientGroupId"] == null ? null : json["clientGroupId"],
      );

  Map<String, dynamic> toJson() => {
        "status": status == null ? null : status,
        "messages": messages == null
            ? null
            : List<dynamic>.from(messages!.map((x) => x)),
        "id": id == null ? null : id,
        "gstNo": gstNo == null ? null : gstNo,
        "gstFile": gstFile,
        "panNo": panNo == null ? null : panNo,
        "panFile": panFile,
        "custmerId": custmerId,
        "clientGroupId": clientGroupId == null ? null : clientGroupId,
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
        status: json["status"] == null ? null : json["status"],
        messages: json["messages"] == null
            ? null
            : List<String>.from(json["messages"].map((x) => x)),
        id: json["id"] == null ? null : json["id"],
        firstName: json["firstName"] == null ? null : json["firstName"],
        userId: json["userId"] == null ? null : json["userId"],
        lastName: json["lastName"] == null ? null : json["lastName"],
        userName: json["userName"] == null ? null : json["userName"],
        mobileNumber:
            json["mobileNumber"] == null ? null : json["mobileNumber"],
        emailAddress:
            json["emailAddress"] == null ? null : json["emailAddress"],
        password: json["password"] == null ? null : json["password"],
        isDefault: json["isDefault"] == null ? null : json["isDefault"],
        userRole: json["userRole"] == null ? null : json["userRole"],
        role: json["role"] == null ? null : Role.fromJson(json["role"]),
        pincode: json["pincode"] == null ? null : json["pincode"],
        city: json["city"] == null ? null : json["city"],
        state: json["state"] == null ? null : json["state"],
        country: json["country"] == null ? null : json["country"],
        houseNo: json["houseNo"] == null ? null : json["houseNo"],
        addressLine1:
            json["addressLine1"] == null ? null : json["addressLine1"],
        addressLine2:
            json["addressLine2"] == null ? null : json["addressLine2"],
        addressType: json["addressType"] == null ? null : json["addressType"],
      );

  Map<String, dynamic> toJson() => {
        "status": status == null ? null : status,
        "messages": messages == null
            ? null
            : List<dynamic>.from(messages!.map((x) => x)),
        "id": id == null ? null : id,
        "firstName": firstName == null ? null : firstName,
        "userId": userId == null ? null : userId,
        "lastName": lastName == null ? null : lastName,
        "userName": userName == null ? null : userName,
        "mobileNumber": mobileNumber == null ? null : mobileNumber,
        "emailAddress": emailAddress == null ? null : emailAddress,
        "password": password == null ? null : password,
        "isDefault": isDefault == null ? null : isDefault,
        "userRole": userRole == null ? null : userRole,
        "role": role == null ? null : role!.toJson(),
        "pincode": pincode == null ? null : pincode,
        "city": city == null ? null : city,
        "state": state == null ? null : state,
        "country": country == null ? null : country,
        "houseNo": houseNo == null ? null : houseNo,
        "addressLine1": addressLine1 == null ? null : addressLine1,
        "addressLine2": addressLine2 == null ? null : addressLine2,
        "addressType": addressType == null ? null : addressType,
      };
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
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        description: json["description"] == null ? null : json["description"],
        userId: json["userId"] == null ? null : json["userId"],
        isInternal: json["isInternal"] == null ? null : json["isInternal"],
        features: json["features"] == null
            ? null
            : List<Feature>.from(
                json["features"].map((x) => Feature.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "description": description == null ? null : description,
        "userId": userId == null ? null : userId,
        "isInternal": isInternal == null ? null : isInternal,
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
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        description: json["description"] == null ? null : json["description"],
        privilages: json["privilages"] == null
            ? null
            : List<Privilage>.from(
                json["privilages"].map((x) => Privilage.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "description": description == null ? null : description,
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
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        displayName: json["displayName"] == null ? null : json["displayName"],
        checked: json["checked"] == null ? null : json["checked"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "displayName": displayName == null ? null : displayName,
        "checked": checked == null ? null : checked,
      };
}
