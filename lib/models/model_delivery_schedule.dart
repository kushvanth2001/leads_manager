// To parse this JSON data, do
//
//     final deliveryModel = deliveryModelFromJson(jsonString);

import 'dart:convert';

DeliveryModel deliveryModelFromJson(String str) =>
    DeliveryModel.fromJson(json.decode(str));

String deliveryModelToJson(DeliveryModel data) => json.encode(data.toJson());

class DeliveryModel {
  DeliveryModel({
    this.status,
    this.messages,
    this.deliveryOptions,
  });

  String? status;
  List<dynamic>? messages;
  List<DeliveryOption>? deliveryOptions;

  factory DeliveryModel.fromJson(Map<String, dynamic> json) => DeliveryModel(
        status: json["status"],
        messages: [],
        deliveryOptions: List<DeliveryOption>.from(
            json["deliveryOptions"].map((x) => DeliveryOption.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "deliveryOptions": deliveryOptions == null
            ? []
            : List<dynamic>.from(deliveryOptions!.map((x) => x.toJson())),
      };
}

class DeliveryOption {
  DeliveryOption({
    this.id,
    this.deliveryOption,
    this.openingTime,
    this.closingTime,
  });

  int? id;
  String? deliveryOption;
  dynamic openingTime;
  dynamic closingTime;

  factory DeliveryOption.fromJson(Map<String, dynamic> json) => DeliveryOption(
        id: json["id"],
        deliveryOption: json["deliveryOption"],
        openingTime: json["openingTime"],
        closingTime: json["closingTime"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "deliveryOption": deliveryOption,
        "openingTime": openingTime,
        "closingTime": closingTime,
      };
}
