// To parse this JSON data, do
//
//     final chatModel = chatModelFromJson(jsonString);

import 'dart:convert';
List<ChatModel> chatModelFromJson(String str) =>
    List<ChatModel>.from(json.decode(str).map((x) => ChatModel.fromJson(x)));

String chatModelToJson(List<ChatModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChatModel {
  ChatModel({
    this.id,
    this.businessNo,
    this.customerName,
    this.customerNo,
    this.lastTs,
    this.leadId,
    this.messages,
    this.preview_message,
    this.multiTenantContext,
    this.overrideStatus,
  });

  Id? id;
  String? businessNo;
  dynamic customerName;
  dynamic customerNo;
  dynamic lastTs;
  dynamic leadId;
  List<Message>? messages;
  String? preview_message;
  dynamic multiTenantContext;
  OverrideStatus? overrideStatus;
// factory ChatModel.fromJson(Map<String, dynamic> json) {
//   return ChatModel(
//     id: json["_id"] != null ? Id.fromJson(json["_id"]) : Id(customerNo: 'dummyCustomerId'),
//     businessNo: json["business_no"] ?? 'dummyBusinessNo',
//     customerName: json["customer_name"] ?? 'dummyCustomerName',
//     customerNo: json["customer_no"] ?? 'dummyCustomerNo',
//     lastTs: json["last_ts"] ?? 1707565628,
//     leadId: json["lead_id"] ?? 'dummyLeadId',
//     messages: json["messages"] == null
//         ? []
//         : List<Message>.from(
//             json["messages"].map((x) => Message.fromJson(x))),
//     multiTenantContext: json["multi_tenant_context"] ?? 'dummyMultiTenantContext',
//     preview_message: json["preview_message"] ?? 'dummyPreviewMessage',
//     overrideStatus: json["override_status"] == null
//         ? OverrideStatus(agentOverride: 0, overrideTime: 'dummyOverrideTime') // Provide default values for OverrideStatus
//         : OverrideStatus.fromJson(json["override_status"]),
//   );
// }

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
       id: json["_id"] != null ? Id.fromJson(json["_id"]) : Id(customerNo: json["customer_no"]??""), // id: Id.fromJson(json["_id"]),
        businessNo: json["business_no"]??"",
        customerName: json["customer_name"]??"",
        customerNo: json["customer_no"],
        lastTs: json["last_ts"],
        leadId: json["lead_id"],
        messages: json["messages"] == null
            ? []
            : List<Message>.from(
                json["messages"].map((x) => Message.fromJson(x))),
        multiTenantContext: json["multi_tenant_context"],
        preview_message: json["preview_message"],
        overrideStatus: json["override_status"] == null
            ? null
            : OverrideStatus.fromJson(json["override_status"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id == null ? null : id!.toJson(),
        "business_no": businessNo,
        "customer_name": customerName,
        "customer_no": customerNo,
        "last_ts": lastTs,
        "lead_id": leadId,
        "messages": messages == null
            ? []
            : List<dynamic>.from(messages!.map((x) => x.toJson())),
        "multi_tenant_context": multiTenantContext,
        "override_status":
            overrideStatus == null ? null : overrideStatus!.toJson(),
      };
}

class Id {
  Id({
    this.customerNo,
  });

  dynamic customerNo;

  factory Id.fromJson(Map<String, dynamic> json) => Id(
        customerNo: json["customer_no"],
      );

  Map<String, dynamic> toJson() => {
        "customer_no": customerNo,
      };
}

class Message {
  Message({
    this.agent,
    this.direction,
    this.fileUrl,
    this.message,
    this.timestamp,
    this.type,
    this.status,
    this.messageid
  });

  String? agent;
  String? direction;
  String? fileUrl;
  String? message;
  dynamic timestamp;
  String? type;
  String? status;
String? messageid;
  factory Message.fromJson(Map<String, dynamic> json) => Message(
        agent: json["agent"],
        direction: json["direction"],
        fileUrl: json["file_url"],
        message: json["message"],
        timestamp: json["timestamp"],
        type: json["type"],
        messageid: json[" message_id"],
        status: json["status"],
        
      );

  Map<String, dynamic> toJson() => {
        "agent": agent,
        "direction": direction,
        "file_url": fileUrl,
        "message": message,
        "timestamp": timestamp,
        "type": type,
    "message_id":messageid,
    "status":status
      };
}

class OverrideStatus {
  OverrideStatus({
    this.agentOverride,
    this.clientGroup,
    this.liveAgentUserId,
    this.overrideTime,
  });

  int? agentOverride;
  dynamic clientGroup;
  dynamic liveAgentUserId;
  dynamic overrideTime;

  factory OverrideStatus.fromJson(Map<String, dynamic> json) => OverrideStatus(
        agentOverride: json["agent_override"],
        clientGroup: json["client_group"],
        liveAgentUserId: json["live_agent_user_id"],
        overrideTime: json["override_time"],
      );

  Map<String, dynamic> toJson() => {
        "agent_override": agentOverride,
        "client_group": clientGroup,
        "live_agent_user_id": liveAgentUserId,
        "override_time": overrideTime,
      };
}
