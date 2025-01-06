class CallStatus {
 final int? id;
 final String statusName;
 final bool? isActive;
 final String? status;
 final List<dynamic>? messages;
 final DateTime? lastModifiedTime;
 final String? lastModifiedBy;

 CallStatus({
  this.id,
  required this.statusName,
  this.isActive,
 this.status,
  this.messages,
 this.lastModifiedTime,
 this.lastModifiedBy,
 });

 factory CallStatus.fromJson(Map<String, dynamic> json) {
 return CallStatus(
 id: json['id'],
 statusName: json['statusName'],
 isActive: json['isActive'],
 status: json['status'],
 messages: json['messages'],
 lastModifiedTime: json['lastModifiedTime'] != null
 ? DateTime.parse(json['lastModifiedTime'])
 : null,
 lastModifiedBy: json['lastModifiedBy'],
 );
 }
 
 Map<String, dynamic> toJson() {
 return {
 'id': id,
 'statusName': statusName,
 'isActive': isActive,
 'status': status,
 'messages': messages,
 'lastModifiedTime': lastModifiedTime?.toIso8601String(),
 'lastModifiedBy': lastModifiedBy,
 };
 }
}
