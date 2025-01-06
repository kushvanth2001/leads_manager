// To parse this JSON data, do
//
//     final priceListModel = priceListModelFromJson(jsonString);

import 'dart:convert';

PriceListModel priceListModelFromJson(String str) =>
    PriceListModel.fromJson(json.decode(str));

String priceListModelToJson(PriceListModel data) => json.encode(data.toJson());

class PriceListModel {
  PriceListModel({
    this.status,
    this.messages,
    this.pricelistMasters,
  });

  String? status;
  List<String>? messages;
  List<PricelistMaster>? pricelistMasters;

  factory PriceListModel.fromJson(Map<String, dynamic> json) => PriceListModel(
        status: json["status"],
        messages: [],
        pricelistMasters: List<PricelistMaster>.from(
            json["pricelistMasters"].map((x) => PricelistMaster.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "pricelistMasters": pricelistMasters == null
            ? []
            : List<dynamic>.from(pricelistMasters!.map((x) => x.toJson())),
      };
}

class PricelistMaster {
  PricelistMaster({
    this.id,
    this.name,
    this.description,
    this.visible,
    this.code,
    this.clientGroupId,
    this.merchantName,
    this.customerRoleId,
    this.customerRoleName,
    this.discountPercent,
    this.commissionPercent,
    this.remarks,
    this.public,
  });

  int? id;
  String? name;
  String? description;
  bool? visible;
  String? code;
  int? clientGroupId;
  String? merchantName;
  int? customerRoleId;
  String? customerRoleName;
  double? discountPercent;
  double? commissionPercent;
  String? remarks;
  bool? public;

  factory PricelistMaster.fromJson(Map<String, dynamic> json) =>
      PricelistMaster(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        visible: json["visible"],
        code: json["code"],
        clientGroupId: json["clientGroupId"],
        merchantName: json["merchantName"],
        customerRoleId: json["customerRoleId"],
        customerRoleName: json["customerRoleName"],
        discountPercent: json["discountPercent"],
        commissionPercent: json["commissionPercent"],
        remarks: json["remarks"],
        public: json["public"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "visible": visible,
        "code": code,
        "clientGroupId": clientGroupId,
        "merchantName": merchantName,
        "customerRoleId": customerRoleId,
        "customerRoleName": customerRoleName,
        "discountPercent": discountPercent,
        "commissionPercent": commissionPercent,
        "remarks": remarks,
        "public": public,
      };
}
