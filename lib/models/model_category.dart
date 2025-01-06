import 'dart:convert';

Category categoryFromJson(String str) => Category.fromJson(json.decode(str));

String categoryToJson(Category data) => json.encode(data.toJson());

class Category {
  Category({
    required this.status,
    required this.messages,
    required this.skuCategorySequence,
    required this.skuTypes,
  });

  String status;
  List<dynamic> messages;
  dynamic skuCategorySequence;
  List<String> skuTypes;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        status: json["status"],
        messages: [],
        skuCategorySequence: json["skuCategorySequence"],
        skuTypes: List<String>.from(json["skuTypes"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": List<dynamic>.from(messages.map((x) => x)),
        "skuCategorySequence": skuCategorySequence,
        "skuTypes": List<dynamic>.from(skuTypes.map((x) => x)),
      };
}
