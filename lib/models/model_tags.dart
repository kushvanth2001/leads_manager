class Tags {
  final String? status;
  final List<String>? messages;
  final int? id;
  final String? name;
  final String? type;
  final int? clientGroupId;
  final String? color;
  final String? description;
  final bool? isLeadTag;
  final DateTime? createdOn;

  Tags({
     this.status,
     this.messages,
     this.id,
     this.name,
     this.type,
     this.clientGroupId,
     this.color,
     this.description,
     this.isLeadTag,
     this.createdOn,
  });

  factory Tags.fromJson(Map<String, dynamic> json) {
    return Tags(
      status: json['status'],
      messages: [],
      id: json['id'],
      name: json['name'],
      type: json['type'],
      clientGroupId: json['clientGroupId'],
      color: json['color'],
      description: json['description'],
      isLeadTag: json['isLeadTag'],
      createdOn: DateTime.parse(json['createdOn']),
    );
  }
  Map<String, dynamic> toJson() => {
        'status': status,
        'messages': messages,
        'id': id,
        'name': name,
        'type': type,
        'clientGroupId': clientGroupId,
        'color': color,
        'description': description,
        'isLeadTag': isLeadTag,
        'createdOn': createdOn?.toIso8601String(),
      };
}
