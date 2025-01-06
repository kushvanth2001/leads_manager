import 'dart:convert';

CreateTaskNote createTaskNoteFromJson(String str) =>
    CreateTaskNote.fromJson(json.decode(str));

String createTaskNoteToJson(CreateTaskNote data) => json.encode(data.toJson());

class CreateTaskNote {
  CreateTaskNote({
    this.id,
    this.action,
    this.createdBy,
    this.documents,
    this.remarks,
  });

  String? id;
  String? action;
  String? createdBy;
  Documents? documents;
  String? remarks;

  factory CreateTaskNote.fromJson(Map<String, dynamic> json) => CreateTaskNote(
        id: json["id"],
        action: json["isActive"],
        createdBy: json["createdBy"],
        documents: json["documents"] == null
            ? null
            : Documents.fromJson(json["documents"]),
        remarks: json["remarks"],
      );

  Map<String, dynamic> toJson() => {
        "id": id ??= null,
        "action": action ??= null,
        "createdBy": createdBy,
        "documents": documents == null ? Documents() : documents!.toJson(),
        "remarks": remarks,
      };
}

class Documents {
  Documents({
    this.documents,
  });

  List<dynamic>? documents;

  factory Documents.fromJson(Map<String, dynamic> json) => Documents(
        documents: json["documents"] == null
            ? []
            : List<dynamic>.from(json["documents"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "documents": documents == null
            ? []
            : List<dynamic>.from(documents!.map((x) => x)),
      };
}
