// // To parse this JSON data, do
// //
// //     final taskModel = taskModelFromJson(jsonString);

// import 'dart:convert';
// import 'package:leads_manager/models/model_merchant_profile.dart';

// TaskModel taskModelFromJson(String str) => TaskModel.fromJson(json.decode(str));

// String taskModelToJson(TaskModel data) => json.encode(data.toJson());

// class TaskModel {
//   TaskModel({
//     this.id,
//     this.clientGroupId,
//     this.description,
//     this.assignedTo,
//     this.assignedBy,
//     this.taskStatus,
//     this.name,
//     this.images,
//     this.priorityId,
//     this.documents,
//     this.startTime,
//     this.lastTime,
//     this.endTime,
//   });

//   dynamic id;
//   dynamic clientGroupId;
//   String? description;
//   dynamic  assignedTo;
//   dynamic assignedBy;
//   TaskStatus? taskStatus;
//   String? name;
//   Images? images;
//   dynamic priorityId;
//   Documents? documents;
//   DateTime? startTime;
//   String? lastTime;
//   DateTime? endTime;

//   factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
//         id: json["id"],
//         clientGroupId: json["clientGroupId"],
//         description: json["description"],
//         assignedTo: json["assignedTo"] == null
//             ? null
//             : User.fromJson(json["assignedTo"]),
//         assignedBy: json["assignedBy"],
//         taskStatus: json["taskStatus"] == null
//             ? null
//             : TaskStatus.fromJson(json["taskStatus"]),
//         name: json["name"],
//         images: json["images"] == null ? null : Images.fromJson(json["images"]),
//         priorityId: json["priorityId"],
//         documents: json["documents"] == null
//             ? null
//             : Documents.fromJson(json["documents"]),
//         startTime: json["startTime"] == null
//             ? null
//             : DateTime.parse(json["startTime"]),
//         lastTime: json["lastTime"],
//         endTime:
//             json["endTime"] == null ? null : DateTime.parse(json["endTime"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "clientGroupId": clientGroupId,
//         "description": description,
//         "assignedTo": assignedTo == null ? null : assignedTo!,
//         "assignedBy": assignedBy,
//         "taskStatus":
//             taskStatus == null ? TaskStatus().toJson() : taskStatus,
//         "name": name,
//         "images": images == null ? Images().toJson() : images!.toJson(),
//         "priorityId": priorityId,
//         "documents":
//             documents == null ? Documents().toJson() : documents!.toJson(),
//         "startTime": startTime == null ? null : startTime!.toIso8601String(),
//         "lastTime": lastTime,
//         "endTime": endTime == null ? null : endTime!.toIso8601String(),
//       };
// }

// class Documents {
//   Documents({
//     this.documents,
//   });

//   List<dynamic>? documents;

//   factory Documents.fromJson(Map<String, dynamic> json) => Documents(
//         documents: json["documents"] == null
//             ? null
//             : List<dynamic>.from(json["documents"].map((x) => x)),
//       );

//   Map<String, dynamic> toJson() => {
//         "documents": documents == null
//             ? null
//             : List<dynamic>.from(documents!.map((x) => x)),
//       };
// }

// class Images {
//   Images({
//     this.images,
//   });

//   List<dynamic>? images;

//   factory Images.fromJson(Map<String, dynamic> json) => Images(
//         images: json["images"] == null
//             ? null
//             : List<dynamic>.from(json["images"].map((x) => x)),
//       );

//   Map<String, dynamic> toJson() => {
//         "images":
//             images == null ? null : List<dynamic>.from(images!.map((x) => x)),
//       };
// }

// class TaskStatus {
//   TaskStatus({
//     this.id,
//     this.name,
//   });

//   dynamic id;
//   dynamic name;

//   factory TaskStatus.fromJson(Map<String, dynamic> json) => TaskStatus(
//         id: json["id"],
//         name: json["name"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "name": name,
//       };
// }
