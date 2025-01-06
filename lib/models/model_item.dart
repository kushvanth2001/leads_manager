// To parse this JSON data, do
//
//     final item = itemFromJson(jsonString);

import 'dart:convert';

import 'model_catalogue.dart';

ItemModel itemFromJson(String str) => ItemModel.fromJson(json.decode(str));

String itemToJson(ItemModel data) => json.encode(data.toJson());

class ItemModel {
  ItemModel({
    this.status,
    this.messages,
    this.skuList,
    this.skuCategorySequence,
    this.totalRecords,
    this.pages,
    this.pricelist,
    this.categories,
  });

  String? status;
  List<dynamic>? messages;
  List<Sku>? skuList;
  dynamic skuCategorySequence;
  int? totalRecords;
  int? pages;
  dynamic pricelist;
  String? categories;

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
        status: json["status"],
        messages: [],
        skuList: List<Sku>.from(json["skuList"].map((x) => Sku.fromJson(x))),
        skuCategorySequence: json["skuCategorySequence"],
        totalRecords: json["totalRecords"],
        pages: json["pages"],
        pricelist: json["pricelist"],
        categories: json["categories"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "skuList": skuList == null
            ? []
            : List<dynamic>.from(skuList!.map((x) => x.toJson())),
        "skuCategorySequence": skuCategorySequence,
        "totalRecords": totalRecords,
        "pages": pages,
        "pricelist": pricelist,
        "categories": categories,
      };
}
