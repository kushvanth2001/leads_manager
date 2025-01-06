// To parse this JSON data, do
//
//     final consumerModel = consumerModelFromJson(jsonString);

import 'dart:convert';

ConsumerModel consumerModelFromJson(String str) => ConsumerModel.fromJson(json.decode(str));

String consumerModelToJson(ConsumerModel data) => json.encode(data.toJson());

class ConsumerModel {
    ConsumerModel({
        this.status,
        this.messages,
        this.phoneNo,
        this.alternativeNo1,
        this.primaryEmailAddress,
        this.alternativeEmailAddress,
        this.firstName,
        this.middleName,
        this.lastName,
        this.countryCode,
        this.userName,
        this.password,
        this.userId,
        this.city,
        this.houseNo,
        this.addressLine1,
        this.latitude,
        this.longitude,
        this.community,
        this.communityName,
        this.applicationNo,
        this.applicationName,
        this.pincode,
        this.upiId,
        this.token,
        this.merchantName,
        this.guid,
        this.referredBy,
        this.parentCustomerId,
        this.addressType,
        this.organizationName,
        this.isValid
    });

    String? status;
    List<String>? messages;
    String? phoneNo;
    String? alternativeNo1;
    String? primaryEmailAddress;
    String? alternativeEmailAddress;
    String? firstName;
    String? middleName;
    String? lastName;
    dynamic countryCode;
    String? userName;
    String? password;
    int? userId;
    String? city;
    String? houseNo;
    String? addressLine1;
    String? latitude;
    String? longitude;
    String? community;
    String? communityName;
    dynamic applicationNo;
    String? applicationName;
    int? pincode;
    String? upiId;
    dynamic token;
    String? merchantName;
    String? guid;
    String? referredBy;
    dynamic parentCustomerId;
    String? addressType;
    String? organizationName;
    bool? isValid;

    factory ConsumerModel.fromJson(Map<String, dynamic> json) => ConsumerModel(
        status: json["status"],
        messages: [],
        phoneNo: json["phoneNo"],
        alternativeNo1: json["alternativeNo1"],
        primaryEmailAddress: json["primaryEmailAddress"],
        alternativeEmailAddress: json["alternativeEmailAddress"],
        firstName: json["firstName"],
        middleName: json["middleName"],
        lastName: json["lastName"],
        countryCode: json["countryCode"],
        userName: json["userName"],
        password: json["password"],
        userId: json["userId"],
        city: json["city"],
        houseNo: json["houseNo"],
        addressLine1: json["addressLine1"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        community: json["community"],
        communityName: json["communityName"],
        applicationNo: json["applicationNo"],
        applicationName: json["applicationName"],
        pincode: json["pincode"],
        upiId: json["upiId"],
        token: json["token"],
        merchantName: json["merchantName"],
        guid: json["guid"],
        referredBy: json["referredBy"],
        parentCustomerId: json["parentCustomerId"],
        addressType: json["addressType"],
        organizationName : json["organizationName"],
        isValid:json["isValid"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "phoneNo": phoneNo,
        "alternativeNo1": alternativeNo1,
        "primaryEmailAddress": primaryEmailAddress,
        "alternativeEmailAddress": alternativeEmailAddress,
        "firstName": firstName,
        "middleName": middleName,
        "lastName": lastName,
        "countryCode": countryCode,
        "userName": userName,
        "password": password,
        "userId": userId,
        "city": city,
        "houseNo": houseNo,
        "addressLine1": addressLine1,
        "latitude": latitude,
        "longitude": longitude,
        "community": community,
        "communityName": communityName,
        "applicationNo": applicationNo,
        "applicationName": applicationName,
        "pincode": pincode,
        "upiId": upiId,
        "token": token,
        "merchantName": merchantName,
        "guid": guid,
        "referredBy": referredBy,
        "parentCustomerId": parentCustomerId,
        "addressType": addressType,
        "organizationName":organizationName,
        "isValid":isValid
    };
}
