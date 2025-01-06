// To parse this JSON data, do
//
//     final orderModel = orderModelFromJson(jsonString);

import 'dart:convert';

import 'model_catalogue.dart';

OrderModel orderModelFromJson(String str) =>
    OrderModel.fromJson(json.decode(str));

Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderModelToJson(OrderModel data) => json.encode(data.toJson());

String ordersToJson(List<Order> orders) =>
    json.encode({"orders": List<dynamic>.from(orders.map((x) => x.toJson()))});

class OrderModel {
  OrderModel({
    this.status,
    this.messages,
    this.orders,
    this.pages,
    this.totalRecords,
  });

  String? status;
  List<dynamic>? messages;
  List<Order>? orders;
  dynamic pages;
  dynamic totalRecords;

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        status: json["status"],
        messages: [],
        orders: json["orders"] == null
            ? []
            : List<Order>.from(json["orders"].map((x) => Order.fromJson(x))),
        pages: json["pages"],
        totalRecords: json["totalRecords"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "orders": List<dynamic>.from(orders!.map((x) => x.toJson())),
        "pages": pages,
        "totalRecords": totalRecords,
      };
}

class Order {
  Order({
    this.status,
    this.messages,
    this.id,
    this.orderStatus,
    this.remarks,
    this.amountPaid,
    this.discount,
    this.discountValue,
    this.orderAmount,
    this.selectedDeliveryBucketId,
    this.originalAmount,
    this.paymentStatus,
    this.paymentType,
    this.pinCode,
    this.firstName,
    this.middleName,
    this.lastName,
    this.customerName,
    this.customerNumber,
    this.merchantName,
    this.clientGroupId,
    this.flatNo,
    this.community,
    this.userId,
    this.applicationNo,
    this.applicationName,
    this.city,
    this.lastModifiedTime,
    this.createdOn,
    this.houseNo,
    this.deliveryTime,
    this.orderDetails,
    this.promotion,
    this.shipment,
    this.pricelist,
    this.coupon,
    this.deliveryCharges,
    this.previousBalance,
    this.referredBy,
    this.lastUpdatedBy,
    this.isPickup,
    this.merchantRemarks,
    this.addressLine1,
    this.addressType,
    this.alternativeEmailAddress,
    this.alternativeNo1,
    this.communityName,
    this.countryCode,
    this.guid,
    this.latitude,
    this.longitude,
    this.parentCustomerId,
    this.password,
    this.phoneNo,
    this.pincode,
    this.primaryEmailAddress,
    this.token,
    this.upiId,
     this.igst,
    this.userName,
    this.validTill,


    //newvalues
        this.roundOff,
    this.pendingAmount,
    this.thirdPartyOrderId,
    this.clientWalletId,
    this.createdByName,
    this.cgstOnDeliveryCharges,
    this.sgstOnDeliveryCharges,
    this.igstOnDeliveryCharges,
    this.packingCharges,
    this.cgstOnPackingCharges,
    this.sgstOnPackingCharges,
    this.igstOnPackingCharges,
    this.billingAddress,
    this.address,
    this.organizationName,
    this.task,
    this.firstOrder,
    this.latitudeValue,
    this.longitudeValue,
    this.mapLocation,
    this.linkedGodownId,
    this.merchantsOrderId,
    this.comments,
    this.termsCond,
    this.paymentTypeId,
    this.additionalCharges,
    this.customColumns,
   
  });

  String? status;
  List<dynamic>? messages;
  int? id;
  String? orderStatus;
  String? remarks;
  double? igst;
  double? amountPaid;
  double? orderAmount;
  dynamic selectedDeliveryBucketId;
  double? originalAmount;
  String? paymentStatus;
  dynamic paymentType;
  int? pinCode;
  String? firstName;
  String? middleName;
  String? lastName;
  String? customerName;
  String? customerNumber;
  String? merchantName;
  int? clientGroupId;
  String? flatNo;
  String? community;
  int? userId;
  String? applicationNo;
  String? applicationName;
  String? city;
  String? lastModifiedTime;
  String? createdOn;
  String? houseNo;
  String? deliveryTime;
  List<Sku>? orderDetails;
  Promotion? promotion;
  dynamic shipment;
  dynamic pricelist;
  dynamic coupon;
  double? deliveryCharges;
  dynamic previousBalance;
  dynamic referredBy;
  String? lastUpdatedBy;
  bool? isPickup;
  String? merchantRemarks;

  String? addressLine1;
  String? addressType;
  dynamic alternativeEmailAddress;
  dynamic alternativeNo1;
  String? communityName;
  dynamic countryCode;
  String? guid;
  dynamic latitude;
  dynamic longitude;
  dynamic parentCustomerId;
  dynamic password;
  String? phoneNo;
  dynamic pincode;
  dynamic primaryEmailAddress;
  dynamic token;
  dynamic upiId;
  dynamic userName;
   int? discountValue;
  double? discount;
  String? validTill;

  //newvalues
double? roundOff;
  double? pendingAmount;
  String? thirdPartyOrderId;
  dynamic clientWalletId;
  String? createdByName;
  double? cgstOnDeliveryCharges;
  double? sgstOnDeliveryCharges;
  double? igstOnDeliveryCharges;
  double? packingCharges;
  double? cgstOnPackingCharges;
  double? sgstOnPackingCharges;
  double? igstOnPackingCharges;
  dynamic billingAddress;
  dynamic address;
  String? organizationName;
  dynamic task;
  dynamic firstOrder;
  dynamic latitudeValue;
  dynamic longitudeValue;
  dynamic mapLocation;
  dynamic linkedGodownId;
  dynamic merchantsOrderId;
  String? comments;
  String? termsCond;
  int? paymentTypeId;
  dynamic additionalCharges;
  List<dynamic>? customColumns;
  factory Order.fromJson(Map<String, dynamic> json) => Order(
        status: json["status"],
        messages: [],
        id: json["id"],
        orderStatus: json["orderStatus"],
        remarks: json["remarks"] == null ? null : json["remarks"],
        amountPaid: json["amountPaid"],
        orderAmount: json["orderAmount"]*1.0,
            validTill: json["validTill"]??null,
            igst: json['igst']??0.0,
        selectedDeliveryBucketId: json["selectedDeliveryBucketId"],
        originalAmount:
            json["originalAmount"] == null ? null : json["originalAmount"]*1.0,
        paymentStatus:
            json["paymentStatus"] == null ? null : json["paymentStatus"],
        paymentType: json["paymentType"],
        pinCode: json["pinCode"],
        firstName: json["firstName"],
        middleName: json["middleName"],
        lastName: json["lastName"],
              discountValue  : json["discountValue"]==null?0:int.tryParse( json["discountValue"].toString()),
    discount :json["discount"]??0.0,
        customerName: json["customerName"],
        customerNumber: json["customerNumber"],
        merchantName: json["merchantName"],
        clientGroupId: json["clientGroupId"],
        flatNo: json["flatNo"],
        community: json["community"],
        userId: json["userId"],
        applicationNo:
            json["applicationNo"] == null ? null : json["applicationNo"],
        applicationName:
            json["applicationName"] == null ? null : json["applicationName"],
        city: json["city"],
        lastModifiedTime: json["lastModifiedTime"],
        createdOn: json["createdOn"],
        houseNo: json["houseNo"],
        deliveryTime: json["deliveryTime"],
        orderDetails: json["orderDetails"] == null
            ? null
            : List<Sku>.from(json["orderDetails"].map((x) => Sku.fromJson(x))),
        promotion: json["promotion"] == null
            ? null
            : Promotion.fromJson(json["promotion"]),
        shipment: json["shipment"],
        pricelist: json["pricelist"],
        coupon: json["coupon"],
        deliveryCharges:
            json["deliveryCharges"] == null ? null : json["deliveryCharges"],
        previousBalance: json["previousBalance"],
        referredBy: json["referredBy"],
        lastUpdatedBy:
            json["lastUpdatedBy"] == null ? null : json["lastUpdatedBy"],
        isPickup: json["isPickup"] == null ? null : json["isPickup"],
        merchantRemarks:
            json["merchantRemarks"] == null ? null : json["merchantRemarks"],
        addressLine1: json["addressLine1"],
        addressType: json["addressType"],
        alternativeEmailAddress: json["alternativeEmailAddress"],
        alternativeNo1: json["alternativeNo1"],
        communityName: json["communityName"],
        countryCode: json["countryCode"],
        guid: json["guid"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        parentCustomerId: json["parentCustomerId"],
        password: json["password"],
        phoneNo: json["phoneNo"],
        pincode: json["pincode"],
        primaryEmailAddress: json["primaryEmailAddress"],
        token: json["token"],
        upiId: json["upiId"],
        userName: json["userName"],
        //new value 
          roundOff: json['roundOff'] as double?,
      pendingAmount: json['pendingAmount'] as double?,
      thirdPartyOrderId: json['thirdPartyOrderId'] as String?,
      clientWalletId: json['clientWalletId'],
      createdByName: json['createdByName'] as String?,
      cgstOnDeliveryCharges: json['cgstOnDeliveryCharges'] as double?,
      sgstOnDeliveryCharges: json['sgstOnDeliveryCharges'] as double?,
      igstOnDeliveryCharges: json['igstOnDeliveryCharges'] as double?,
      packingCharges: json['packingCharges'] as double?,
      cgstOnPackingCharges: json['cgstOnPackingCharges'] as double?,
      sgstOnPackingCharges: json['sgstOnPackingCharges'] as double?,
      igstOnPackingCharges: json['igstOnPackingCharges'] as double?,
      billingAddress: json['billingAddress'],
      address: json['address'],
      organizationName: json['organizationName'] as String?,
      task: json['task'],
      firstOrder: json['firstOrder'],
      latitudeValue: json['latitudeValue'],
      longitudeValue: json['longitudeValue'],
      mapLocation: json['mapLocation'],
      linkedGodownId: json['linkedGodownId'],
      merchantsOrderId: json['merchantsOrderId'],
      comments: json['comments'] as String?,
      termsCond: json['termsCond'] as String?,
      paymentTypeId: json['paymentTypeId'] as int?,
      additionalCharges: json['additionalCharges'],
      customColumns: json['customColumns'] as List<dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "id": id,
        "orderStatus": orderStatus,
        "remarks": remarks == null ? null : remarks,
        "amountPaid": amountPaid,
            "validTill":validTill,
          "discountValue":discountValue,
    "discount": discount,
        "orderAmount": orderAmount,
        "selectedDeliveryBucketId": selectedDeliveryBucketId,
        "originalAmount": originalAmount == null ? null : originalAmount,
        "paymentStatus": paymentStatus == null ? null : paymentStatus,
        "paymentType": paymentType,
        "pinCode": pinCode,
        "firstName": firstName,
        "middleName": middleName,
        "lastName": lastName,
        "customerName": customerName,
        "customerNumber": customerNumber,
        "merchantName": merchantName,
        "clientGroupId": clientGroupId,
        "igst":igst??0.0,
        "flatNo": flatNo,
        "community": community,
        "userId": userId,
        "applicationNo": applicationNo == null ? null : applicationNo,
        "applicationName": applicationName == null ? null : applicationName,
        "city": city,
        "lastModifiedTime": lastModifiedTime,
        "createdOn": createdOn,
        "houseNo": houseNo,
        "deliveryTime": deliveryTime,
        "orderDetails": orderDetails == null
            ? null
            : List<dynamic>.from(orderDetails!.map((x) => x.toJson())),
        "promotion": promotion == null ? null : promotion!.toJson(),
        "shipment": shipment,
        "pricelist": pricelist,
        "coupon": coupon,
        "deliveryCharges": deliveryCharges == null ? null : deliveryCharges,
        "previousBalance": previousBalance,
        "referredBy": referredBy,
        "lastUpdatedBy": lastUpdatedBy == null ? null : lastUpdatedBy,
        "isPickup": isPickup == null ? null : isPickup,
        "merchantRemarks": merchantRemarks == null ? null : merchantRemarks,
        "addressLine1": addressLine1,
        "addressType": addressType,
        "alternativeEmailAddress": alternativeEmailAddress,
        "alternativeNo1": alternativeNo1,
        "communityName": communityName,
        "countryCode": countryCode,
        "guid": guid,
        "latitude": latitude,
        "longitude": longitude,
        "parentCustomerId": parentCustomerId,
        "password": password,
        "phoneNo": phoneNo,
        "pincode": pincode,
        "primaryEmailAddress": primaryEmailAddress,
        "token": token,
        "upiId": upiId,
        "userName": userName,

        //new value
         'roundOff': roundOff,
      'pendingAmount': pendingAmount,
      'thirdPartyOrderId': thirdPartyOrderId,
      'clientWalletId': clientWalletId,
      'createdByName': createdByName,
      'cgstOnDeliveryCharges': cgstOnDeliveryCharges,
      'sgstOnDeliveryCharges': sgstOnDeliveryCharges,
      'igstOnDeliveryCharges': igstOnDeliveryCharges,
      'packingCharges': packingCharges,
      'cgstOnPackingCharges': cgstOnPackingCharges,
      'sgstOnPackingCharges': sgstOnPackingCharges,
      'igstOnPackingCharges': igstOnPackingCharges,
      'billingAddress': billingAddress,
      'address': address,
      'organizationName': organizationName,
      'task': task,
      'firstOrder': firstOrder,
      'latitudeValue': latitudeValue,
      'longitudeValue': longitudeValue,
      'mapLocation': mapLocation,
      'linkedGodownId': linkedGodownId,
      'merchantsOrderId': merchantsOrderId,
      'comments': comments,
      'termsCond': termsCond,
      'paymentTypeId': paymentTypeId,
      'additionalCharges': additionalCharges,
      'customColumns': customColumns,
      };
}

class Promotion {
  Promotion({
    this.status,
    this.messages,
    this.id,
    this.name,
    this.basisThresholdValue,
    this.maximumDiscount,
    this.discountType,
    this.basisPromoCode,
    this.promoText,
    this.lumpsumValue,
    this.percentageValue,
    this.isAvailable,
    this.isVisible,
    this.promotionBasis,
  });

  String? status;
  List<String>? messages;
  int? id;
  String? name;
  int? basisThresholdValue;
  int? maximumDiscount;
  String? discountType;
  String? basisPromoCode;
  dynamic promoText;
  int? lumpsumValue;
  int? percentageValue;
  bool? isAvailable;
  bool? isVisible;
  PromotionBasis? promotionBasis;

  factory Promotion.fromJson(Map<String, dynamic> json) => Promotion(
        status: json["status"] == null ? null : json["status"],
        messages: json["messages"] == null
            ? null
            : List<String>.from(json["messages"].map((x) => x)),
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        basisThresholdValue: json["basisThresholdValue"] == null
            ? null
            : json["basisThresholdValue"],
        maximumDiscount:
            json["maximumDiscount"] == null ? null : json["maximumDiscount"],
        discountType:
            json["discountType"] == null ? null : json["discountType"],
        basisPromoCode:
            json["basisPromoCode"] == null ? null : json["basisPromoCode"],
        promoText: json["promoText"],
        lumpsumValue:
            json["lumpsumValue"] == null ? null : json["lumpsumValue"],
        percentageValue:
            json["percentageValue"] == null ? null : json["percentageValue"],
        isAvailable: json["isAvailable"] == null ? null : json["isAvailable"],
        isVisible: json["isVisible"] == null ? null : json["isVisible"],
        promotionBasis: json["promotionBasis"] == null
            ? null
            : PromotionBasis.fromJson(json["promotionBasis"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status == null ? null : status,
        "messages": messages == null
            ? null
            : List<String>.from(messages!.map((x) => x)),
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "basisThresholdValue":
            basisThresholdValue == null ? null : basisThresholdValue,
        "maximumDiscount": maximumDiscount == null ? null : maximumDiscount,
        "discountType": discountType == null ? null : discountType,
        "basisPromoCode": basisPromoCode == null ? null : basisPromoCode,
        "promoText": promoText,
        "lumpsumValue": lumpsumValue == null ? null : lumpsumValue,
        "percentageValue": percentageValue == null ? null : percentageValue,
        "isAvailable": isAvailable == null ? null : isAvailable,
        "isVisible": isVisible == null ? null : isVisible,
        "promotionBasis":
            promotionBasis == null ? null : promotionBasis!.toJson(),
      };
}

class PromotionBasis {
  PromotionBasis({
    this.status,
    this.messages,
    this.id,
    this.name,
    this.displayName,
    this.criteria,
  });

  String? status;
  List<String>? messages;
  int? id;
  String? name;
  String? displayName;
  String? criteria;

  factory PromotionBasis.fromJson(Map<String, dynamic> json) => PromotionBasis(
        status: json["status"] == null ? null : json["status"],
        messages: json["messages"] == null
            ? null
            : List<String>.from(json["messages"].map((x) => x)),
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        displayName: json["displayName"] == null ? null : json["displayName"],
        criteria: json["criteria"] == null ? null : json["criteria"],
      );

  Map<String, dynamic> toJson() => {
        "status": status == null ? null : status,
        "messages": messages == null
            ? null
            : List<String>.from(messages!.map((x) => x)),
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "displayName": displayName == null ? null : displayName,
        "criteria": criteria == null ? null : criteria,
      };
}
