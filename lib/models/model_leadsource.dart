class LeadSource {
  LeadSource({
    this.status,
    this.messages,
    this.id,
  required this.sourceName,
  });

  String? status;
  List<dynamic>? messages;
  int? id;
  String? sourceName;

  factory LeadSource.fromJson(Map<String, dynamic> json) => LeadSource(
        status: json["status"],
        messages: [],
        id: json["id"],
        sourceName: json["sourceName"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "id": id,
        "sourceName": sourceName,
      };
}
