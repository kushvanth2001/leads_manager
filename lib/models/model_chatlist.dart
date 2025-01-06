import 'package:get/get.dart';

class ChatList {
  var uniqueId = ''.obs;
  var customerNo = ''.obs;
  var businessNo = ''.obs;
  var customerName = ''.obs;
  var lastTs = 0.obs;
  var leadId = ''.obs;
  var multiTenantContext = ''.obs;
  var previewMessage = ''.obs;
  var status = ''.obs;
  var messageCount = 0.obs;

  ChatList({
    String? uniqueId,
    required String customerNo,
    required String? businessNo,
    required String? customerName,
    required int lastTs,
    String? leadId,
    required String? multiTenantContext,
    required String? previewMessage,
    required String? status,
    required int messageCount,
  }) {
    this.uniqueId.value = uniqueId ?? '';
    this.customerNo.value = customerNo;
    this.businessNo.value = businessNo ?? '';
    this.customerName.value = customerName ?? '';
    this.lastTs.value = lastTs;
    this.leadId.value = leadId ?? '';
    this.multiTenantContext.value = multiTenantContext ?? '';
    this.previewMessage.value = previewMessage ?? '';
    this.status.value = status ?? '';
    this.messageCount.value = messageCount;
  }

  // Factory constructor to create an instance from JSON
  factory ChatList.fromJson(Map<String, dynamic> json) {
    return ChatList(
      uniqueId: json['uniqueId'],
      customerNo: json['customer_no'] ?? '',
      businessNo: json['business_no'] ?? '',
      customerName: json['customer_name'] ?? '',
      lastTs: json['last_ts'] ?? 0,
      leadId: json['lead_id'],
      multiTenantContext: json['multi_tenant_context'] ?? '',
      previewMessage: json['preview_message'] ?? '',
      status: json['status'] ?? '',
      messageCount: json['messagecount'] ?? 0,
    );
  }
}