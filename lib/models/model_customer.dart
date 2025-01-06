// To parse this JSON data, do
//
//     final customersModel = customersModelFromJson(jsonString);

import 'dart:convert';

CustomersModel customersModelFromJson(String str) =>
    CustomersModel.fromJson(json.decode(str));

String customersModelToJson(CustomersModel data) => json.encode(data.toJson());

class CustomersModel {
  CustomersModel({
    this.customers,
    this.leads,
    this.pages,
    this.totalRecords,
  });

  List<Customer>? customers;
  List<dynamic>? leads;
  int? pages;
  int? totalRecords;

  factory CustomersModel.fromJson(Map<String, dynamic> json) => CustomersModel(
        customers: List<Customer>.from(
            json["customers"].map((x) => Customer.fromJson(x))),
        leads: List<dynamic>.from(json["leads"].map((x) => x)),
        pages: json["pages"],
        totalRecords: json["totalRecords"],
      );

  Map<String, dynamic> toJson() => {
        "customers": customers == null
            ? []
            : List<dynamic>.from(customers!.map((x) => x.toJson())),
        "leads": leads == null ? [] : List<dynamic>.from(leads!.map((x) => x)),
        "pages": pages,
        "totalRecords": totalRecords,
      };
}

class Customer {
  Customer({
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
  String? state;
  dynamic country;
  dynamic gstNumber;
  String? organizationName;
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
  int? pagingId;
  String? gstNo;
  dynamic leadId;
  String? panNo;
  TagsDto? tagsDto;
  List<Event>? events;

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json["id"],
        pincode: json["pincode"],
        city: json["city"] == null ? null : json["city"],
        addressLine1: json["addressLine1"],
        houseNo: json["houseNo"] == null ? null : json["houseNo"],
        community: json["community"],
        state: json["state"] == null ? null : json["state"],
        country: json["country"],
        gstNumber: json["gstNumber"],
        organizationName:
            json["organizationName"] == null ? null : json["organizationName"],
        userId: json["userId"],
        relationId: json["relationId"],
        mobileNumber: json["mobileNumber"],
        emailAddress: json["emailAddress"],
        firstName: json["firstName"] == null ? null : json["firstName"],
        lastName: json["lastName"] == null ? null : json["lastName"],
        customerName:
            json["customerName"] == null ? null : json["customerName"],
        role: json["role"],
        roleId: json["roleId"],
        customerRefferal: json["customerRefferal"],
        parentCustomerId: json["parentCustomerId"],
        parentCustomerName: json["parentCustomerName"],
        referralLink: json["referralLink"],
        guid: json["guid"],
        affiliateStatus: json["affiliateStatus"],
        pagingId: json["pagingId"],
        gstNo: json["gstNo"] == null ? null : json["gstNo"],
        leadId: json["leadId"],
        panNo: json["panNo"] == null ? null : json["panNo"],
        tagsDto: TagsDto.fromJson(json["tagsDTO"]),
        events: List<Event>.from(json["events"].map((x) => Event.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "pincode": pincode,
        "city": city == null ? null : city,
        "addressLine1": addressLine1,
        "houseNo": houseNo == null ? null : houseNo,
        "community": community,
        "state": state == null ? null : state,
        "country": country,
        "gstNumber": gstNumber,
        "organizationName": organizationName == null ? null : organizationName,
        "userId": userId,
        "relationId": relationId,
        "mobileNumber": mobileNumber,
        "emailAddress": emailAddress,
        "firstName": firstName == null ? null : firstName,
        "lastName": lastName == null ? null : lastName,
        "customerName": customerName == null ? null : customerName,
        "role": role,
        "roleId": roleId,
        "customerRefferal": customerRefferal,
        "parentCustomerId": parentCustomerId,
        "parentCustomerName": parentCustomerName,
        "referralLink": referralLink,
        "guid": guid,
        "affiliateStatus": affiliateStatus,
        "pagingId": pagingId,
        "gstNo": gstNo == null ? null : gstNo,
        "leadId": leadId,
        "panNo": panNo == null ? null : panNo,
        "tagsDTO": tagsDto == null ? null : tagsDto!.toJson(),
        "events": events == null
            ? []
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
  List<dynamic>? messages;
  int? id;
  dynamic name;
  dynamic description;
  int? clientGroupId;
  int? customerId;
  int? releventId;
  EventType? eventType;
  DateTime? createdOn;

  factory Event.fromJson(Map<String?, dynamic> json) => Event(
        status: json["status"],
        messages: [],
        id: json["id"],
        name: json["name"],
        description: json["description"],
        clientGroupId: json["clientGroupId"],
        customerId: json["customerId"],
        releventId: json["releventId"],
        eventType: json["eventType"] == null
            ? null
            : EventType.fromJson(json["eventType"]),
        createdOn: DateTime.parse(json["createdOn"]),
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
        "eventType": eventType == null ? null : eventType!.toJson(),
        "createdOn": createdOn?.toIso8601String(),
      };
}

class EventType {
  EventType({
    this.id,
    this.name,
  });

  dynamic id;
  String? name;

  factory EventType.fromJson(Map<String, dynamic> json) => EventType(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
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
        "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
      };
}
