// To parse this JSON data, do
//
//     final uploadImage = uploadImageFromJson(jsonString);

import 'dart:convert';

UploadImage uploadImageFromJson(String str) =>
    UploadImage.fromJson(json.decode(str));

String uploadImageToJson(UploadImage data) => json.encode(data.toJson());

class UploadImage {
  UploadImage({
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

  factory UploadImage.fromJson(Map<String, dynamic> json) => UploadImage(
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
