// To parse this JSON data, do
//
//     final communityModel = communityModelFromJson(jsonString);

import 'dart:convert';

CommunityModel communityModelFromJson(String str) =>
    CommunityModel.fromJson(json.decode(str));

String communityModelToJson(CommunityModel data) => json.encode(data.toJson());

class CommunityModel {
  CommunityModel({
    this.status,
    this.messages,
    this.communities,
  });

  String? status;
  List<String>? messages;
  List<Community>? communities;

  factory CommunityModel.fromJson(Map<String, dynamic> json) => CommunityModel(
        status: json["status"],
        messages: [],
        communities: json["communities"] == null
            ? []
            : List<Community>.from(
                json["communities"].map((x) => Community.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "communities": communities == null
            ? []
            : List<dynamic>.from(communities!.map((x) => x.toJson())),
      };
}

class Community {
  Community({
    this.status,
    this.messages,
    this.id,
    this.name,
    this.communityName,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.addressLine1,
    this.allowedPinCodes,
    this.deliveryLocationType,
    this.deliveryDay,
    this.deliveryTime,
    this.mobileNo,
    this.landLineNo,
    this.addressLine2,
    this.houseNo,
    this.clientGroupName,
    this.username,
    this.clientGroupId,
    this.userId,
    this.deliveryLocationId,
    this.deliveryCharges,
    this.enablePickup,
    this.minimumMinutes,
    this.minimumDays,
    this.minimumHours,
    this.valid,
  });

  String? status;
  List<dynamic>? messages;
  int? id;
  String? name;
  String? communityName;
  String? city;
  dynamic state;
  dynamic country;
  int? pincode;
  String? addressLine1;
  dynamic allowedPinCodes;
  String? deliveryLocationType;
  dynamic deliveryDay;
  dynamic deliveryTime;
  dynamic mobileNo;
  dynamic landLineNo;
  String? addressLine2;
  String? houseNo;
  dynamic clientGroupName;
  dynamic username;
  dynamic clientGroupId;
  dynamic userId;
  int? deliveryLocationId;
  dynamic deliveryCharges;
  dynamic enablePickup;
  int? minimumMinutes;
  int? minimumDays;
  int? minimumHours;
  bool? valid;

  factory Community.fromJson(Map<String, dynamic> json) => Community(
        status: json["status"],
        messages: [],
        id: json["id"],
        name: json["name"],
        communityName: json["communityName"],
        city: json["city"],
        state: json["state"],
        country: json["country"],
        pincode: json["pincode"],
        addressLine1: json["addressLine1"],
        allowedPinCodes: json["allowedPinCodes"],
        deliveryLocationType: json["deliveryLocationType"],
        deliveryDay: json["deliveryDay"],
        deliveryTime: json["deliveryTime"],
        mobileNo: json["mobileNo"],
        landLineNo: json["landLineNo"],
        addressLine2:
            json["addressLine2"] == null ? null : json["addressLine2"],
        houseNo: json["houseNo"] == null ? null : json["houseNo"],
        clientGroupName: json["clientGroupName"],
        username: json["username"],
        clientGroupId: json["clientGroupId"],
        userId: json["userId"],
        deliveryLocationId: json["delivery_locationId"],
        deliveryCharges: json["deliveryCharges"],
        enablePickup: json["enablePickup"],
        minimumMinutes: json["minimumMinutes"],
        minimumDays: json["minimumDays"],
        minimumHours: json["minimumHours"],
        valid: json["valid"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "id": id,
        "name": name,
        "communityName": communityName,
        "city": city,
        "state": state,
        "country": country,
        "pincode": pincode,
        "addressLine1": addressLine1,
        "allowedPinCodes": allowedPinCodes,
        "deliveryLocationType": deliveryLocationType,
        "deliveryDay": deliveryDay,
        "deliveryTime": deliveryTime,
        "mobileNo": mobileNo,
        "landLineNo": landLineNo,
        "addressLine2": addressLine2 == null ? null : addressLine2,
        "houseNo": houseNo == null ? null : houseNo,
        "clientGroupName": clientGroupName,
        "username": username,
        "clientGroupId": clientGroupId,
        "userId": userId,
        "delivery_locationId": deliveryLocationId,
        "deliveryCharges": deliveryCharges,
        "enablePickup": enablePickup,
        "minimumMinutes": minimumMinutes,
        "minimumDays": minimumDays,
        "minimumHours": minimumHours,
        "valid": valid,
      };
}
