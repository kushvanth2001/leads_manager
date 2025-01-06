import 'dart:convert';

CreateNote createNoteFromJson(String str) =>
    CreateNote.fromJson(json.decode(str));

String createNoteToJson(CreateNote data) => json.encode(data.toJson());

class CreateNote {
  CreateNote({
    this.status,
    this.isActive,
    this.createdBy,
    this.documents,
    this.remarks,
  });

  String? status;
  bool? isActive;
  String? createdBy;
  Documents? documents;
  String? remarks;

  factory CreateNote.fromJson(Map<String, dynamic> json) => CreateNote(
        status: json["status"],
        isActive: json["isActive"],
        createdBy: json["createdBy"],
        documents: json["documents"] == null
            ? null
            : Documents.fromJson(json["documents"]),
        remarks: json["remarks"],
      );

  Map<String, dynamic> toJson() => {
        "status": status??= "OK",
        "isActive": isActive??= true,
        "createdBy": createdBy,
        "documents": documents == null ? Documents() : documents!.toJson(),
        "remarks": remarks,
      };
}

class Documents {
  List<Document>? documents;

  Documents({this.documents});

  factory Documents.fromJson(Map<String, dynamic> json) => Documents(
    documents: json["documents"] == null ? [] : List<Document>.from(json["documents"].map((x) => Document.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "documents": documents == null ? [] : List<dynamic>.from(documents!.map((x) => x.toJson())),
  };
}

class Document {
  final int? id;
  final String? fileLink;
  final String? description;
  final String? fileData;
  final String? createdOn;
  final String? downloadLink;

  Document({
    this.id,
    this.fileLink,
    this.description,
    this.fileData,
    this.createdOn,
    this.downloadLink,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      fileLink: json['fileLink'],
      description: json['description'],
      fileData: json['fileData'],
      createdOn: json['createdOn'],
      downloadLink: json['downloadLink'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileLink': fileLink,
      'description': description,
      'fileData': fileData,
      'createdOn': createdOn,
      'downloadLink': downloadLink,
    };
  }
}





// import 'dart:convert';

// CreateNote createNoteFromJson(String str) =>
//     CreateNote.fromJson(json.decode(str));

// String createNoteToJson(CreateNote data) => json.encode(data.toJson());

// class CreateNote {
//   CreateNote({
//     this.id,
//     this.status,
//     this.leadId,
//     this.isActive,
//     this.remarks,
//     this.createdOn,
//     this.createdBy,
//     this.actualDealValue,
//     this.potentialDealValue,
//     this.documents,
//     this.type,
//     this.taskId,
//     this.opportunityId,
//   });

//   int? id;
//   String? status;
//   int? leadId;
//   bool? isActive;
//   String? remarks;
//   String? createdOn;
//   String? createdBy;
//   dynamic actualDealValue;
//   dynamic potentialDealValue;
//   Documents? documents;
//   dynamic type;
//   dynamic taskId;
//   dynamic opportunityId;

//   factory CreateNote.fromJson(Map<String, dynamic> json) => CreateNote(
//         id: json["id"],
//         status: json["status"],
//         leadId: json["leadId"],
//         isActive: json["isActive"],
//         remarks: json["remarks"],
//         createdOn: json["createdOn"],
//         createdBy: json["createdBy"],
//         actualDealValue: json["actualDealValue"],
//         potentialDealValue: json["potentialDealValue"],
//         documents: json["documents"] == null
//             ? null
//             : Documents.fromJson(json["documents"]),
//         type: json["type"],
//         taskId: json["taskId"],
//         opportunityId: json["opportunityId"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "status": status,
//         "leadId": leadId,
//         "isActive": isActive,
//         "remarks": remarks,
//         "createdOn": createdOn,
//         "createdBy": createdBy,
//         "actualDealValue": actualDealValue,
//         "potentialDealValue": potentialDealValue,
//         "documents": documents == null ? null : documents!.toJson(),
//         "type": type,
//         "taskId": taskId,
//         "opportunityId": opportunityId,
//       };
// }

// class Documents {
//   Documents({
//     this.documents,
//     this.totalRecords,
//     this.pages,
//   });

//   List<dynamic>? documents;
//   dynamic? totalRecords;
//   dynamic? pages;

//   factory Documents.fromJson(Map<String, dynamic> json) => Documents(
//         documents: json["documents"] == null
//             ? null
//             : List<dynamic>.from(json["documents"].map((x) => x)),
//         totalRecords: json["totalRecords"],
//         pages: json["pages"],
//       );

//   Map<String, dynamic> toJson() => {
//         "documents": documents == null
//             ? null
//             : List<dynamic>.from(documents!.map((x) => x)),
//         "totalRecords": totalRecords,
//         "pages": pages,
//       };
// }
