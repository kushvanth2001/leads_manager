// To parse this JSON data, do
//
//     final leadDetailsModel = leadDetailsModelFromJson(jsonString);

import 'dart:convert';

import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:leads_manager/models/model_customColumn.dart';
import 'package:leads_manager/models/model_lead.dart';
import 'package:leads_manager/models/model_leadsource.dart';
import 'package:leads_manager/models/model_tag.dart';
// import 'package:leads_manager/models/model_priceslabs.dart';
// import 'package:leads_manager/models/model_scheme.dart';
import 'package:leads_manager/models/model_unit.dart';
import '../../../domainvariables.dart';
LeadDetailsModel leadDetailsModelFromJson(String str) =>
    LeadDetailsModel.fromJson(json.decode(str));

String leadDetailsModelToJson(LeadDetailsModel data) =>
    json.encode(data.toJson());

class LeadDetailsModel {
  LeadDetailsModel({
    this.status,
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
    this.altMobileNumCountryCode,
    this.pincode,
    this.fullAddress,
    this.assignedTo,
    this.leadStatus,
    this.leadSource,
    this.createdOn,
    this.tagsDto,
    this.isNoteAvailable,
    this.assignedBy,
    this.priorityId,
    this.createdBy,
    this.potentialDealValue,
    this.actualDealValue,
    this.followUpDate,
    this.score,
    this.logsDTO,
    this.customColumns,
  });

  String? status;
  List<String>? messages;
  int? id;
  String? lastModifiedTime;
  String? lastModifiedBy;
  bool? isActive;
  String? customer;
  int? clientGroupId;
  String? customerName;
  String? organizationName;
  int? mobileNumber;
  String? alternateMobileNumber2;
  String? email;
  String? alternateEmail;
  String? city;
  String? state;
  String? country;
  String? countryCode;
  String? altMobileNumCountryCode;
  int? pincode;
  String? fullAddress;
  AssignedTo? assignedTo;
  LeadStatus? leadStatus;
  LeadSource? leadSource;
  DateTime? createdOn;
  TagsDto2? tagsDto;
  bool? isNoteAvailable;
  String? assignedBy; //change this ie, create a assignedBy class
  PriorityId? priorityId;
  String? createdBy;
  String? potentialDealValue;
  String? actualDealValue;
  String? followUpDate;
  int? score;
  String? logsDTO; //change this later, create a logsDto class
  List<CustomColumn>? customColumns;

  factory LeadDetailsModel.fromJson(Map<String, dynamic> json) {
    var customColumnsJson = json['customColumns'] as List<dynamic>?;

    List<CustomColumn>? customColumns;
    if (customColumnsJson != null) {
      customColumns = customColumnsJson
          .map((columnJson) => CustomColumn.fromJson(columnJson))
          .toList();
    }
    return LeadDetailsModel(
        status: json['status'],
        messages: [],
        id: json['id'],
        lastModifiedTime: json['lastModifiedTime'],
        lastModifiedBy: json['lastModifiedBy'],
        isActive: json['isActive'],
        customer: null,
        clientGroupId: json['clientGroupId'],
        customerName: json['customerName'],
        organizationName: json['organizationName'],
        mobileNumber: json['mobileNumber'] != null
            ? int.tryParse(json['mobileNumber'])
            : null,
        alternateMobileNumber2: json['alternateMobileNumber2'],
        email: json['email'],
        alternateEmail: json['alternateEmail'],
        city: json['city'],
        state: json['state'],
        country: json['country'],
        countryCode: json['countryCode'],
        altMobileNumCountryCode: json['altMobileNumCountryCode'],
        pincode: json['pincode'],
        fullAddress: json['fullAddress'],
        assignedTo: json["assignedTo"] == null
            ? null
            : AssignedTo.fromJson(json["assignedTo"]),
        leadStatus: json["leadStatus"] == null
            ? null
            : LeadStatus.fromJson(json["leadStatus"]),
        leadSource: json["leadSource"] == null
            ? null
            : LeadSource.fromJson(json["leadSource"]),
        createdOn: null,
        tagsDto: TagsDto2.fromJson(json["tagsDTO"]),
        isNoteAvailable: json['isNoteAvailable'],
        assignedBy: null,
        priorityId: json["priorityId"] == null
            ? null
            : PriorityId.fromJson(json['priorityId']),
        createdBy: json['createdBy'],
        potentialDealValue: json['potentialDealValue'],
        actualDealValue: json['actualDealValue'],
        followUpDate: json['followUpDate'],
        score: json['score'],
        customColumns: customColumns);
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'messages': [],
      'id': id,
      'lastModifiedTime': lastModifiedTime,
      'lastModifiedBy': lastModifiedBy,
      'isActive': isActive,
      'customer': customer,
      'clientGroupId': clientGroupId,
      'customerName': customerName,
      'organizationName': organizationName,
      'mobileNumber': mobileNumber,
      'alternateMobileNumber2': alternateMobileNumber2,
      'email': email,
      'alternateEmail': alternateEmail,
      'city': city,
      'state': state,
      'country': country,
      'countryCode': countryCode,
      'altMobileNumCountryCode': altMobileNumCountryCode,
      'pincode': pincode,
      'fullAddress': fullAddress,
      'assignedTo': assignedTo == null ? null : assignedTo!.toJson(),
      'leadStatus': leadStatus == null ? null : leadStatus!.toJson(),
      'leadSource': leadSource == null ? null : leadSource!.toJson(),
      'createdOn': createdOn == null ? null : createdOn!.toIso8601String(),
      'tagsDto': tagsDto == null ? null : tagsDto!.toJson(),
      'isNoteAvailable': isNoteAvailable,
      'assignedBy': null,
      'priorityId': priorityId?.toJson(),
      'createdBy': createdBy,
      'potentialDealValue': potentialDealValue,
      'actualDealValue': actualDealValue,
      'followUpDate': followUpDate,
      'score': score,
      'logsDto': logsDTO,
      'customColumns': customColumns?.map((column) => column.toJson()).toList(),
    };
  }
}

class PriorityId {
  String? status;
  List<String>? messages;
  int? id;
  dynamic lastModifiedTime;
  dynamic lastModifiedBy;
  bool? isActive;
  String? name;

  PriorityId({
    this.status,
    this.messages,
    this.id,
    this.lastModifiedTime,
    this.lastModifiedBy,
    this.isActive,
    this.name,
  });

  factory PriorityId.fromJson(Map<String, dynamic> json) {
    return PriorityId(
      status: json['status'],
      messages: List<String>.from(json['messages']),
      id: json['id'],
      lastModifiedTime: json['lastModifiedTime'],
      lastModifiedBy: json['lastModifiedBy'],
      isActive: json['isActive'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['messages'] = this.messages;
    data['id'] = this.id;
    data['lastModifiedTime'] = this.lastModifiedTime;
    data['lastModifiedBy'] = this.lastModifiedBy;
    data['isActive'] = this.isActive;
    data['name'] = this.name;
    return data;
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
  List<String>? messages;
  int? id;
  String? firstName;
  int? userId;
  String? lastName;
  String? userName;
  int? mobileNumber;
  String? emailAddress;
  String? password;
  dynamic isDefault;
  String? userRole;
  Role? role;
  String? pincode;
  String? city;
  String? state;
  String? country;
  String? houseNo;
  String? addressLine1;
  String? addressLine2;
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
        role: Role.fromJson(json["role"]),
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
        "role": role?.toJson(),
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
  List<dynamic>? features;

  factory Role.fromJson(Map<String, dynamic> json) => Role(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        userId: json["userId"],
        isInternal: json["isInternal"],
        features: List<dynamic>.from(json["features"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "userId": userId,
        "isInternal": isInternal,
        "features": features == null
            ? null
            : List<dynamic>.from(features!.map((x) => x)),
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
    this.isPredefineRemoved,
  });

  String? status;
  List<String>? messages;
  int? id;
  String? statusName;
  DateTime? lastModifiedTime;
  String? lastModifiedBy;
  bool? isActive;
  int? clientGroupId;
  String? name;
  bool? isPredefineRemoved;

  factory LeadStatus.fromJson(Map<String, dynamic> json) => LeadStatus(
        status: json["status"],
        messages: [],
        id: json["id"],
        statusName: json["statusName"],
        lastModifiedTime: json["lastModifiedTime"] != null
          ? DateTime.parse( json["lastModifiedTime"]):null,
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
        "lastModifiedTime": lastModifiedTime?.toIso8601String()??"",
        "lastModifiedBy": lastModifiedBy,
        "isActive": isActive,
        "clientGroupId": clientGroupId,
        "name": name,
      };
}

class Scheme {
  String name;
  String description;

  Scheme({required this.name, required this.description});

  factory Scheme.fromJson(Map<String, dynamic> json) {
    return Scheme(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

PriceSlabs unitFromJson(String str) => PriceSlabs.fromJson(json.decode(str));

String unitToJson(PriceSlabs data) => json.encode(data.toJson());

class PriceSlabs {
  List<PriceSlab> allPriceSlab;

  PriceSlabs({required this.allPriceSlab});

  factory PriceSlabs.fromJson(Map<String, dynamic> json) {
    List<dynamic> allPriceSlabJson = json['priceSlabs']['allPriceSlab'];
    List<PriceSlab> allPriceSlab =
        allPriceSlabJson.map((e) => PriceSlab.fromJson(e)).toList();
    return PriceSlabs(allPriceSlab: allPriceSlab);
  }

  Map<String, dynamic> toJson() => {
        "allPriceSlab": allPriceSlab.map((e) => e.toJson()).toList(),
      };
}

class PriceSlab {
  double quantity;
  double price;

  PriceSlab({required this.quantity, required this.price});

  factory PriceSlab.fromJson(Map<String, dynamic> json) {
    return PriceSlab(
      quantity: json['quantity'] ?? 0,
      price: json['price'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "quantity": quantity,
        "price": price,
      };
}

TagsDto2 tagsDtoFromJson(String str) => TagsDto2.fromJson(json.decode(str));

String tagsDtoToJson2(TagsDto2 data) => json.encode(data.toJson());

List<Tag> tagListFromJson(String str) =>
    List<Tag>.from(json.decode(str).map((x) => Tag.fromJson(x)));

class TagsDto2 {
  TagsDto2({this.tags});

  List<Tag>? tags;

  factory TagsDto2.fromJson(Map<String, dynamic> json) => TagsDto2(
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
//      this.isLeadTag,
//     this.createdOn,
//   });

//   String? status;
//   List<String>? messages;
//   int? id;
//   String? name;
//   String? type;
//   int? clientGroupId;
//   String? color;
//   String? description;
//     bool? isLeadTag;
//   DateTime? createdOn;

//   factory Tag.fromJson(Map<String, dynamic> json) => Tag(
//         status: json["status"],
//         messages: [],
//         id: json["id"],
//         name: json["name"],
//         type: json["type"],
//         clientGroupId: json["clientGroupId"],
//         color: json["color"],
//         description: json["description"],
//        isLeadTag: json['isLeadTag'] as bool?,
//       createdOn: json['createdOn'] != null
//           ? DateTime.parse(json['createdOn'] as String)
//           : null,
      
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
//           'isLeadTag': isLeadTag ?? false,
//       'createdOn': createdOn?.toIso8601String() ?? '',
//       };

// static Future<List<Tag>> fetchTags() async {
//   String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
//   final response = await NetworkHelper().request(
//     RequestType.get,
//     Uri.parse(
//         'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/tags'),
//     requestBody: "",
//   );
//   if (response != null && response.statusCode == 200) {
//     final data = jsonDecode(response.body);
//     return (data['tags'] as List)
//         .map((tag) => Tag.fromJson(tag))
//         .toList();
//   } else {
//     throw Exception('Failed to load data');
//   }
// }


// }

Future<List<LeadSource>> fetchLeadSources() async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  try {
    final response = await NetworkHelper().request(
      RequestType.get,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/lead-source'),
      requestBody: "",
    );
    if (response != null && response.statusCode == 200) {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      final parsed = jsonDecode(response.body)['allLeadsSources'];
      return List<LeadSource>.from(
          parsed.map((json) => LeadSource.fromJson(json)));
    } else {
      print('Failed to load lead sources ${response?.statusCode}');
      throw Exception('Failed to load lead sources');
    }
  } catch (e) {
    print('Exception occurred: $e');
    throw e;
  }
}
