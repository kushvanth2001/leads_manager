// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

TransactionModel transactionFromJson(String str) =>
    TransactionModel.fromJson(json.decode(str));

String transactionToJson(TransactionModel data) => json.encode(data.toJson());

class TransactionModel {
  TransactionModel({
    this.status,
    this.messages,
    this.totalRecords,
    this.pages,
    this.enduserTransactions,
    this.transactions,
  });

  String? status;
  List<dynamic>? messages;
  int? totalRecords;
  int? pages;
  List<EnduserTransaction>? enduserTransactions;
  List<dynamic>? transactions;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        status: json["status"],
        messages: List<dynamic>.from(json["messages"].map((x) => x)),
        totalRecords: json["totalRecords"],
        pages: json["pages"],
        enduserTransactions: List<EnduserTransaction>.from(
            json["enduserTransactions"]
                .map((x) => EnduserTransaction.fromJson(x))),
        transactions: List<dynamic>.from(json["transactions"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "totalRecords": totalRecords,
        "pages": pages,
        "enduserTransactions": enduserTransactions == null
            ? []
            : List<dynamic>.from(enduserTransactions!.map((x) => x.toJson())),
        "transactions": transactions == null
            ? []
            : List<dynamic>.from(transactions!.map((x) => x)),
      };
}

class EnduserTransaction {
  EnduserTransaction({
    this.status,
    this.messages,
    this.id,
    this.orderId,
    this.customerName,
    this.upiPhoneNo,
    this.whatsappNo,
    this.creditAmount,
    this.debitAmount,
    this.debit,
    this.customerReference,
    this.customerBankId,
    this.fromUpi,
    this.toUpi,
    this.transactionStatus,
    this.transactionTime,
    this.remarks,
    this.paymentTransId,
    this.gateway,
    this.matched,
  });

  String? status;
  List<dynamic>? messages;
  int? id;
  String? orderId;
  String? customerName;
  dynamic upiPhoneNo;
  dynamic whatsappNo;
  dynamic creditAmount;
  dynamic debitAmount;
  dynamic debit;
  String? customerReference;
  String? customerBankId;
  dynamic fromUpi;
  dynamic toUpi;
  dynamic transactionStatus;
  DateTime? transactionTime;
  String? remarks;
  int? paymentTransId;
  String? gateway;
  bool? matched;

  factory EnduserTransaction.fromJson(Map<String, dynamic> json) =>
      EnduserTransaction(
        status: json["status"],
        messages: List<dynamic>.from(json["messages"].map((x) => x)),
        id: json["id"],
        orderId: json["orderId"],
        customerName: json["customerName"],
        upiPhoneNo: json["upiPhoneNo"],
        whatsappNo: json["whatsappNo"],
        creditAmount: json["creditAmount"],
        debitAmount: json["debitAmount"],
        debit: json["debit"],
        customerReference: json["customerReference"],
        customerBankId: json["customerBankId"],
        fromUpi: json["fromUPI"],
        toUpi: json["toUPI"],
        transactionStatus: json["transactionStatus"],
        transactionTime: DateTime.parse(json["transactionTime"]),
        remarks: json["remarks"],
        paymentTransId: json["paymentTransId"],
        gateway: json["gateway"],
        matched: json["matched"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "id": id,
        "orderId": orderId,
        "customerName": customerName,
        "upiPhoneNo": upiPhoneNo,
        "whatsappNo": whatsappNo,
        "creditAmount": creditAmount,
        "debitAmount": debitAmount,
        "debit": debit,
        "customerReference": customerReference,
        "customerBankId": customerBankId,
        "fromUPI": fromUpi,
        "toUPI": toUpi,
        "transactionStatus": transactionStatus,
        "transactionTime": transactionTime, //!.toIso8601String()
        "remarks": remarks,
        "paymentTransId": paymentTransId,
        "gateway": gateway,
        "matched": matched,
      };
}
