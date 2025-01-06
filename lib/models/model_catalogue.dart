// To parse this JSON data, do
//
// final catalogue = catalogueFromJson(jsonString);

import 'dart:convert';

import 'package:leads_manager/models/model_unit.dart';

Catalogue catalogueFromJson(String str) => Catalogue.fromJson(json.decode(str));

String catalogueToJson(Catalogue data) => json.encode(data.toJson());

class Catalogue {
  Catalogue({
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
  List<String>? messages;
  List<Sku>? skuList;
  String? skuCategorySequence;
  int? totalRecords;
  int? pages;
  dynamic pricelist;
  String? categories;

  factory Catalogue.fromJson(Map<String, dynamic> json) => Catalogue(
        status: json["status"],
        messages: [],
        skuList: json["skuList"] == null
            ? []
            : List<Sku>.from(json["skuList"].map((x) => Sku.fromJson(x))),
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

class Sku {
  Sku({
    this.brand,
    this.displayName,
    this.mrp,
    this.sellingPrice,
    this.unit,
    this.measurement,
    this.moq,
    this.discountPercent,
    this.type,
    this.status,
    this.messages,
    this.id,
    this.availability,
    this.showMrp,
    this.images,
    this.description,
    this.thirdPartySku,
    this.length,
    this.width,
    this.height,
    this.weight,
    this.gst,
    this.hsnSacCode,
    this.includedInMrp,
    this.variant,
    this.skuVariants,
    this.isVisible,
    this.tags,
    this.trackInventory,
    this.availableStock,
    this.valid,
    this.quantity,
    this.totalAmount,
    this.skuId,
    this.discountValue,
this.discountType,
    this.itemStatus,
    this.remarks,
    this.size,
    this.igst,


        // Newly added properties
    this.orderItemStatus,
    this.cgst,
    this.sgst,
    this.schemeId,
    this.parentItemId,
    this.complimentaryItems,
    this.appliedSchemes,
    this.boxId,
    this.batchNumber,
    this.subscriptionOrderId,
    this.currencyType

  });

  String? status;
  List<dynamic>? messages;
  int? id;
  String? brand;
  String? displayName;
  String? discountType;
  String? type;
  bool? availability = true;
  bool? showMrp = true;
  double? mrp;
  double? sellingPrice;
  List<ImageC>? images;
  Unit? unit;
  String? measurement = "1";
  String? description;
  String? thirdPartySku;
  double? length;
  double? width;
  double? height;
  double? weight;
  int? moq = 1;
  double? gst;
  double? igst;
  String? hsnSacCode;
  bool? includedInMrp = true;
  double? discountPercent;
  Variant? variant;
  List<Sku>? skuVariants;
  bool? isVisible = true;
  String? tags;
  bool? trackInventory;
  int? availableStock;
  bool? valid;
  dynamic quantity;
  double? totalAmount;
  //
  int? skuId;
 
  String? itemStatus;
  String? remarks;
  double? discountValue;
  String? size;
  //double? discount;

   String? orderItemStatus;
  double? cgst;
  double? sgst;
  int? schemeId;
  int? parentItemId;
  List<dynamic>? complimentaryItems;
  dynamic appliedSchemes;
  String? boxId;
  String? batchNumber;
  int? subscriptionOrderId;
  String? currencyType;

          
    
  factory Sku.fromJson(Map<String, dynamic> json) => Sku(
        status: json["status"],
        messages: [],
        id: json["id"],
         skuId: json["skuId"],

        brand: json["brand"],
        displayName: json["displayName"],
        type: json["type"],
        availability: json["availability"],
        igst: json["igst"]??0.0,
        showMrp: json["showMrp"],
                discountType: json["discountType"]??"lumpsum",
        
        mrp: json["mrp"] == null ? null : json["mrp"].toDouble(),
        sellingPrice: json["sellingPrice"].toDouble(),
        images:
            List<ImageC>.from(json["images"].map((x) => ImageC.fromJson(x))),
        unit: Unit.fromJson(json["unit"]),
        measurement: json["measurement"] ?? "",
        description: json["description"] ?? "",
        thirdPartySku:
            json["thirdPartySku"] == null ? null : json["thirdPartySku"],
        length: json["length"] == null ? null : json["length"].toDouble(),
        width: json["width"] == null ? null : json["width"].toDouble(),
        height: json["height"] == null ? null : json["height"].toDouble(),
        weight: json["weight"] == null ? null : json["weight"].toDouble(),
        moq: json["moq"] == null ? null : json["moq"],
        gst: json["gst"] == null ? null : json["gst"].toDouble(),
        hsnSacCode: json["hsnSacCode"] == null ? null : json["hsnSacCode"],
        includedInMrp:
            json["includedInMrp"] == null ? true : json["includedInMrp"],
        discountPercent: json["discountPercent"] == null
            ? 0
            : json["discountPercent"].toDouble(),
             discountValue: json["discountValue"] == null
            ? 0
            : json["discountValue"].toDouble(),
        variant:
            json["variant"] == null ? null : Variant.fromJson(json["variant"]),
        skuVariants: json["skuVariants"] == null
            ? []
            : List<Sku>.from(json["skuVariants"].map((x) => Sku.fromJson(x))),
        isVisible: json["isVisible"],
        tags: json["tags"] == null ? null : json["tags"],
        trackInventory: json["trackInventory"],
        availableStock: json["availableStock"],
        quantity: json["quantity"]??0.0,  
        valid: json["valid"],
        totalAmount:
            json["totalAmount"] == null ? null : json["totalAmount"].toDouble(),


   orderItemStatus: json['orderItemStatus'] as String?,
      cgst: (json['cgst'] as num?)?.toDouble(),
      sgst: (json['sgst'] as num?)?.toDouble(),
      schemeId: json['schemeId'] as int?,
      parentItemId: json['parentItemId'] as int?,
      complimentaryItems: json['complimentaryItems'] != null ? List<dynamic>.from(json['complimentaryItems']) : null,
      appliedSchemes: json['appliedSchemes'],
      boxId: json['boxId'] as String?,
      batchNumber: json['batchNumber'] as String?,
      subscriptionOrderId: json['subscriptionOrderId'] as int?,
      currencyType: json['currencyType'] as String?,
            
      );

  factory Sku.fromJsonForOrderDetail(Map<String, dynamic> json) => Sku(
        id: json["id"],
        skuId: json["skuId"] ?? json["id"],
        sellingPrice: json["sellingPrice"],
        brand: json["brand"],
        type: json["type"],
        unit: Unit.fromJson(json["unit"]),
        quantity: json["quantity"],
        mrp: json["mrp"] == null ? null : json["mrp"].toDouble(),
        itemStatus: json["itemStatus"] ?? "ACTIVE",
        remarks: json["remarks"],
        measurement: json["measurement"],
        discountType: json["discountType"]??"lumpsum",
        images:
            List<ImageC>.from(json["images"].map((x) => ImageC.fromJson(x))),
        displayName: json["displayName"],
        totalAmount:
            json["totalAmount"] == null ? null : json["totalAmount"].toDouble(),
        thirdPartySku: json["thirdPartySku"],
        discountPercent: json["discountPercent"] == null
            ? null
            : json["discountPercent"].toDouble(),
        discountValue: json["discountValue"]==null?0.0 : json["discountValue"] ,
        gst: json["gst"] ?? 0.0,
        size: json["size"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "brand": brand,
        "skuId": skuId,
        "displayName": displayName,
        "type": type,
        "availability": availability ?? true,
        "showMrp": showMrp ?? true,
        "mrp": mrp,
        "igst":igst??0.0,
        "sellingPrice": sellingPrice,
        "images": images == null
            ? []
            : List<dynamic>.from(images!.map((x) => x.toJson())),
        "unit": unit == null ? null : unit!.toJson(),
        "measurement": measurement,
        "description": description == null ? null : description,
        // "thirdPartySku": thirdPartySku == null ? null : thirdPartySku,
        // "length": length == null ? null : length,
        // "width": width == null ? null : width,
        // "height": height == null ? null : height,
        // "weight": weight == null ? null : weight,
        "moq": moq ?? 1,
        "discountType":"lumpsum",
         "gst": gst == null ? null : gst,
        // "hsnSacCode": hsnSacCode == null ? null : hsnSacCode,
        "includedInMrp": includedInMrp ?? true,
        "discountPercent": discountPercent??0.0,
         "discountValue": discountValue??0.0,
        

        // "variant": variant == null ? null : variant!.toJson(),
        // "skuVariants": skuVariants == null
        //     ? null
        //     : List<dynamic>.from(skuVariants!.map((x) => x.toJson())),
        "isVisible": isVisible ?? true,
        // "tags": tags == null ? null : tags,
        "trackInventory": trackInventory ?? false,
        "availableStock": availableStock ?? 0,
        // "valid": valid ?? true,
        "quantity": quantity,
        "totalAmount": totalAmount,
           'orderItemStatus': orderItemStatus,
      'cgst': cgst,
      'sgst': sgst,
      'schemeId': schemeId,
      'parentItemId': parentItemId,
      'complimentaryItems': complimentaryItems,
      'appliedSchemes': appliedSchemes,
      'boxId': boxId,
      'batchNumber': batchNumber,
      'subscriptionOrderId': subscriptionOrderId,
      'currencyType': currencyType,
      };
  Map<String, dynamic> toJsonFororderDetail() => {
        "id": id,
        "skuId": skuId,
        "sellingPrice": sellingPrice,
        "brand": brand,
        "type": type,
        "discountType":discountType??"lumpsum",
        "unit": unit == null ? null : unit!.toJson(),
        "quantity": quantity,
        "mrp": mrp,
        "itemStatus": itemStatus ?? "ACTIVE",
        "remarks": remarks,
        "measurement": measurement,
        "images": images == null
            ? []
            : List<dynamic>.from(images!.map((x) => x.toJson())),
        "displayName": displayName,
        "totalAmount": totalAmount,
        "thirdPartySku": thirdPartySku,
        "discountPercent": discountPercent,
        "discountValue": discountValue ?? 0,
        "gst": gst ?? 0,
        "size": size ?? "0",

//newvalues
     'orderItemStatus': orderItemStatus,
      'cgst': cgst,
      'sgst': sgst,
      'schemeId': schemeId,
      'parentItemId': parentItemId,
      'complimentaryItems': complimentaryItems,
      'appliedSchemes': appliedSchemes,
      'boxId': boxId,
      'batchNumber': batchNumber,
      'subscriptionOrderId': subscriptionOrderId,
      'currencyType': currencyType,
      };
}

class ImageC {
  ImageC({
    this.status,
    this.messages,
    this.id,
    this.imageUrl,
    this.imageText,
  });

  String? status;
  List<dynamic>? messages;
  int? id;
  String? imageUrl;
  String? imageText;

  factory ImageC.fromJson(Map<String, dynamic> json) => ImageC(
        status: json["status"],
        messages: [],
        id: json["id"],
        imageUrl: json["imageUrl"],
        imageText: json["imageText"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "id": id,
        "imageUrl": imageUrl,
        "imageText": imageText,
      };
}

class Variant {
  Variant({
    required this.status,
    required this.messages,
    required this.id,
    required this.variantColumn1,
    required this.variantColumn2,
    required this.variantType,
  });

  String status;
  List<dynamic> messages;
  int id;
  String variantColumn1;
  dynamic variantColumn2;
  VariantType variantType;

  factory Variant.fromJson(Map<String, dynamic> json) => Variant(
        status: json["status"],
        messages: [],
        id: json["id"],
        variantColumn1: json["variantColumn1"],
        variantColumn2: json["variantColumn2"],
        variantType: VariantType.fromJson(json["variantType"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "id": id,
        "variantColumn1": variantColumn1,
        "variantColumn2": variantColumn2,
        "variantType": variantType.toJson(),
      };
}

class VariantType {
  VariantType({
    required this.status,
    required this.messages,
    required this.id,
    required this.name,
    required this.columnCount,
    required this.columnName1,
    required this.columnName2,
  });

  String status;
  List<dynamic> messages;
  int id;
  String name;
  int columnCount;
  String columnName1;
  dynamic columnName2;

  factory VariantType.fromJson(Map<String, dynamic> json) => VariantType(
        status: json["status"],
        messages: [],
        id: json["id"],
        name: json["name"],
        columnCount: json["columnCount"],
        columnName1: json["columnName1"],
        columnName2: json["columnName2"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "id": id,
        "name": name,
        "columnCount": columnCount,
        "columnName1": columnName1,
        "columnName2": columnName2,
      };
}
