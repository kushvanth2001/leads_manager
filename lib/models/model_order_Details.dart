// import 'package:leads_manager/models/model_catalogue.dart';
// import 'package:leads_manager/models/model_unit.dart';

// class OrderDetail {
//   OrderDetail({
//     this.id,
//     this.skuId,
//     this.sellingPrice,
//     this.brand,
//     this.type,
//     this.unit,
//     this.quantity,
//     this.mrp,
//     this.itemStatus,
//     this.remarks,
//     this.measurement,
//     this.images,
//     this.displayName,
//     this.totalAmount,
//     this.thirdPartySku,
//     this.discountPercent,
//     this.discountValue,
//     this.gst,
//     this.size,
//   });

//   int? id;
//   int? skuId;
//   int? sellingPrice;
//   String? brand;
//   dynamic type;
//   Unit? unit;
//   int? quantity;
//   int? mrp;
//   String? itemStatus;
//   dynamic remarks;
//   String? measurement;
//   List<ImageC>? images;
//   String? displayName;
//   double? totalAmount;
//   dynamic thirdPartySku;
//   dynamic discountPercent;
//   dynamic discountValue;
//   dynamic gst;
//   dynamic size;

//   factory OrderDetail.fromJson(Map<String, dynamic> json) => OrderDetail(
//         id: json["id"],
//         skuId: json["skuId"],
//         sellingPrice: json["sellingPrice"],
//         brand: json["brand"],
//         type: json["type"],
//         unit: Unit.fromJson(json["unit"]),
//         quantity: json["quantity"],
//         mrp: json["mrp"],
//         itemStatus: json["itemStatus"],
//         remarks: json["remarks"],
//         measurement: json["measurement"],
//         images: List<ImageC>.from(json["images"].map((x) => ImageC.fromJson(x))),
//         displayName: json["displayName"],
//         totalAmount: json["totalAmount"],
//         thirdPartySku: json["thirdPartySku"],
//         discountPercent: json["discountPercent"],
//         discountValue: json["discountValue"],
//         gst: json["gst"],
//         size: json["size"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "skuId": skuId,
//         "sellingPrice": sellingPrice,
//         "brand": brand,
//         "type": type,
//         "unit": unit == null ? null : unit!.toJson(),
//         "quantity": quantity,
//         "mrp": mrp,
//         "itemStatus": itemStatus,
//         "remarks": remarks,
//         "measurement": measurement,
//         "images": images == null
//             ? null
//             : List<dynamic>.from(images!.map((x) => x.toJson())),
//         "displayName": displayName,
//         "totalAmount": totalAmount,
//         "thirdPartySku": thirdPartySku,
//         "discountPercent": discountPercent,
//         "discountValue": discountValue,
//         "gst": gst,
//         "size": size,
//       };
// }
