// To parse this JSON data, do
//
//     final customerDetailsModel = customerDetailsModelFromJson(jsonString);

import 'dart:convert';

CustomerDetailsModel customerDetailsModelFromJson(String str) =>
    CustomerDetailsModel.fromJson(json.decode(str));

String customerDetailsModelToJson(CustomerDetailsModel data) =>
    json.encode(data.toJson());

class CustomerDetailsModel {
  CustomerDetailsModel({
    this.id,
    this.pincode,
    this.city,
    this.addressLine1,
    this.houseNo,
    this.community,
    this.state,
    this.country,
    this.gstNumber,
    this.organizationName,
    this.userId,
    this.relationId,
    this.mobileNumber,
    this.emailAddress,
    this.firstName,
    this.lastName,
    this.customerName,
    this.role,
    this.roleId,
    this.customerRefferal,
    this.parentCustomerId,
    this.parentCustomerName,
    this.referralLink,
    this.guid,
    this.affiliateStatus,
    this.pagingId,
    this.gstNo,
    this.leadId,
    this.panNo,
    this.tagsDto,
    this.events,
  });

  int? id;
  int? pincode;
  String? city;
  String? addressLine1;
  String? houseNo;
  String? community;
  dynamic state;
  dynamic country;
  dynamic gstNumber;
  dynamic organizationName;
  int? userId;
  int? relationId;
  String? mobileNumber;
  dynamic emailAddress;
  String? firstName;
  String? lastName;
  String? customerName;
  String? role;
  int? roleId;
  dynamic customerRefferal;
  dynamic parentCustomerId;
  dynamic parentCustomerName;
  dynamic referralLink;
  String? guid;
  dynamic affiliateStatus;
  dynamic pagingId;
  dynamic gstNo;
  dynamic leadId;
  dynamic panNo;
  TagsDto? tagsDto;
  List<Event>? events;

  factory CustomerDetailsModel.fromJson(Map<String, dynamic> json) =>
      CustomerDetailsModel(
        id: json["id"],
        pincode: json["pincode"],
        city: json["city"],
        addressLine1: json["addressLine1"],
        houseNo: json["houseNo"],
        community: json["community"],
        state: json["state"],
        country: json["country"],
        gstNumber: json["gstNumber"],
        organizationName: json["organizationName"],
        userId: json["userId"],
        relationId: json["relationId"],
        mobileNumber: json["mobileNumber"],
        emailAddress: json["emailAddress"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        customerName: json["customerName"],
        role: json["role"],
        roleId: json["roleId"],
        customerRefferal: json["customerRefferal"],
        parentCustomerId: json["parentCustomerId"],
        parentCustomerName: json["parentCustomerName"],
        referralLink: json["referralLink"],
        guid: json["guid"],
        affiliateStatus: json["affiliateStatus"],
        pagingId: json["pagingId"],
        gstNo: json["gstNo"],
        leadId: json["leadId"],
        panNo: json["panNo"],
        tagsDto: TagsDto.fromJson(json["tagsDTO"]),
        events: List<Event>.from(json["events"].map((x) => Event.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "pincode": pincode,
        "city": city,
        "addressLine1": addressLine1,
        "houseNo": houseNo,
        "community": community,
        "state": state,
        "country": country,
        "gstNumber": gstNumber,
        "organizationName": organizationName,
        "userId": userId,
        "relationId": relationId,
        "mobileNumber": mobileNumber,
        "emailAddress": emailAddress,
        "firstName": firstName,
        "lastName": lastName,
        "customerName": customerName,
        "role": role,
        "roleId": roleId,
        "customerRefferal": customerRefferal,
        "parentCustomerId": parentCustomerId,
        "parentCustomerName": parentCustomerName,
        "referralLink": referralLink,
        "guid": guid,
        "affiliateStatus": affiliateStatus,
        "pagingId": pagingId,
        "gstNo": gstNo,
        "leadId": leadId,
        "panNo": panNo,
        "tagsDTO": tagsDto == null ? null : tagsDto!.toJson(),
        "events": events == null
            ? null
            : List<dynamic>.from(events!.map((x) => x.toJson())),
      };
}

class Event {
  Event({
    this.status,
    this.messages,
    this.id,
    this.name,
    this.description,
    this.clientGroupId,
    this.customerId,
    this.releventId,
    this.eventType,
    this.createdOn,
  });

  String? status;
  List<String>? messages;
  int? id;
  String? name;
  String? description;
  int? clientGroupId;
  int? customerId;
  int? releventId;
  dynamic eventType;
  DateTime? createdOn;

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        status: json["status"],
        messages: [],
        id: json["id"],
        name: json["name"],
        description: json["description"],
        clientGroupId: json["clientGroupId"],
        customerId: json["customerId"],
        releventId: json["releventId"],
        eventType: json["eventType"],
        createdOn: json["createdOn"] == null
            ? null
            : DateTime.parse(json["createdOn"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "id": id,
        "name": name,
        "description": description,
        "clientGroupId": clientGroupId,
        "customerId": customerId,
        "releventId": releventId,
        "eventType": eventType,
        "createdOn": createdOn == null ? null : createdOn!.toIso8601String(),
      };
}

class TagsDto {
  TagsDto({
    this.tags,
  });

  List<dynamic>? tags;

  factory TagsDto.fromJson(Map<String, dynamic> json) => TagsDto(
        tags: List<dynamic>.from(json["tags"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "tags": tags == null ? null : List<dynamic>.from(tags!.map((x) => x)),
      };
}
