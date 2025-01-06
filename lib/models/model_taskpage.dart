import 'package:leads_manager/models/model_Merchants.dart';
import 'package:leads_manager/models/model_assignedTo.dart';
import 'package:leads_manager/models/model_leadDetails.dart';

import 'package:leads_manager/models/model_priority.dart';
import 'package:leads_manager/models/model_taskstatus.dart';
import 'package:leads_manager/models/model_tasktype.dart';

class Task {
   String? id;
   String? name;
  String? description;
   User? assignedBy;
   User? assignedTo;
  TaskStatus? taskstatus;
  TaskType? tasktype;
   String? startTime;
   String? endTime;
   int? leadId;
   String? area;
   String? reportedClientGroupId;
   int? clientGroupId;
   bool? isActive;
   bool? remindCustomer;
   String? reminderMessage;
   String? parentTaskId;
   String? orderId;
   int? customerId;
   String? customerName;
   String? customerMobileNumber;
   String? areaCommunity;
   String? customerAddress;
   String? lastTime;
   
String? merchantName;
PriorityId? priorityId;
  Documents? documents;
  Images? images;


  Task({
    this.id,
    this.name,
     this.description,
this.assignedBy,
    this.assignedTo,
    this.taskstatus,
    this.tasktype,
  this.startTime,
   this.endTime,
     this.leadId,
  this.merchantName,
    this.area,
    this.reportedClientGroupId,
    this.clientGroupId,
    this.isActive,
    this.remindCustomer,
    this.reminderMessage,
    this.parentTaskId,
    this.orderId,
    this.customerId,
    this.customerName,
    this.customerMobileNumber,
    this.areaCommunity,
    this.customerAddress,
    this.lastTime,
    
    this.priorityId,
    this.documents,
    this.images,
    
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'leadid': leadId??null,
      'assignedBy': assignedBy?.toJson(),
      'assignedTo': assignedTo?.toJson(),
      'taskType': tasktype?.toJson(),
      'taskStatus':taskstatus!=null? taskstatus?.toJson():{"id": null, "name": null, "clientGroupId": null, "isActive": null},
      'startTime': startTime,
      'endTime': endTime,
      'leadId': leadId,
      'area': area,
       'merchantName':merchantName,
      'reportedClientGroupId': reportedClientGroupId,
      'clientGroupId': clientGroupId,
      'isActive': isActive,
      'remindCustomer': remindCustomer,
      'reminderMessage': reminderMessage,
      'parentTaskId': parentTaskId,
      'orderId': orderId,
      'customerId': customerId,
      'customerName': customerName,
      'customerMobileNumber': customerMobileNumber,
      'areaCommunity': areaCommunity,
      'customerAddress': customerAddress,
      'lastTime': lastTime,
       "priorityId": priorityId?.toJson(),
        "documents": documents?.toJson(),
        "images": images?.toJson(),
      
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString() ,
      name: json['name'] ,
      description: json['description'] ,
  merchantName: json["merchantName"],
      assignedBy: User.fromJson(json['assignedBy'] ?? {}),
      assignedTo: User.fromJson(json['assignedTo'] ?? {}),
      tasktype: TaskType.fromJson(json['taskType']),
      taskstatus:json['taskStatus']!=null? TaskStatus.fromJson(json['taskStatus']):null,
      startTime: json['startTime'] ,
      endTime: json['endTime'],
      leadId:json['leadId']!=null?  json['leadId']:null ,
      area: json['area'] ,
      reportedClientGroupId: json['reportedClientGroupId'],
      clientGroupId: json['clientGroupId'] ,
      isActive: json['isActive'] ?? true,
      remindCustomer: json['remindCustomer'],
      reminderMessage: json['reminderMessage'],
      parentTaskId: json['parentTaskId']!=null?json['parentTaskId'].toString():null ,
      orderId: json['orderId'],
      customerId: json['customerId'],
      customerName: json['customerName'] ,
      customerMobileNumber: json['customerMobileNumber'] ,
      areaCommunity: json['areaCommunity'] ,
      customerAddress: json['customerAddress'] ,
      lastTime: json['lastTime'] ,
           priorityId: json["priorityId"] != null
            ? PriorityId.fromJson(json["priorityId"])
            : null,
        documents: json["documents"] != null
            ? Documents.fromJson(json["documents"])
            : null,
        images: json["images"] != null
            ? Images.fromJson(json["images"])
            : null,
      
    );
  }
}



class TaskType {
  String status;
  List<dynamic> messages;
  int id;
  String name;
  bool isActive;
  int? clientGroupId;

  TaskType({
    required this.status,
    required this.messages,
    required this.id,
    required this.name,
    required this.isActive,
    this.clientGroupId,
  });

  // Convert a Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'messages': messages,
      'id': id,
      'name': name,
      'isActive': isActive,
      'clientGroupId': clientGroupId,
    };
  }

  // Create a Dart object from JSON
  factory TaskType.fromJson(Map<String, dynamic> json) {
    return TaskType(
      status: json['status'] ?? '',
      messages: List<dynamic>.from(json['messages'] ?? []),
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      isActive: json['isActive'] ?? false,
      clientGroupId: json['clientGroupId'],
    );
  }
}



class TaskStatus {
  int id;
  String name;
  int? clientGroupId;
  bool? isPredefineRemoved;
  bool? isSameLevelAsPrevious;
  int? parentStatusId;
  int? parentStatusSequence;
  int? sequenceOrder;
  int? subSequence;
  bool? makeMeChildOfAbove;

  TaskStatus({
    required this.id,
    required this.name,
    this.clientGroupId,
    this.isPredefineRemoved,
    this.isSameLevelAsPrevious,
    this.parentStatusId,
    this.parentStatusSequence,
    this.sequenceOrder,
    this.subSequence,
    this.makeMeChildOfAbove,
  });

  // Convert TaskStatus to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'clientGroupId': clientGroupId,
      'isPredefineRemoved': isPredefineRemoved,
      'isSameLevelAsPrevious': isSameLevelAsPrevious,
      'parentStatusId': parentStatusId,
      'parentStatusSequence': parentStatusSequence,
      'sequenceOrder': sequenceOrder,
      'subSequence': subSequence,
      'makeMeChildOfAbove': makeMeChildOfAbove,
    };
  }

  // Create TaskStatus from JSON
  factory TaskStatus.fromJson(Map<String, dynamic> json) {
    return TaskStatus(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      clientGroupId: json['clientGroupId'],
      isPredefineRemoved: json['isPredefineRemoved'],
      isSameLevelAsPrevious: json['isSameLevelAsPrevious'],
      parentStatusId: json['parentStatusId'],
      parentStatusSequence: json['parentStatusSequence'],
      sequenceOrder: json['sequenceOrder'],
      subSequence: json['subSequence'],
      makeMeChildOfAbove: json['makeMeChildOfAbove'],
    );
  }
}

// class PriorityId {
//   String? status;
//   List<dynamic>? messages;
//   int? id;
//   String? lastModifiedTime;
//   String? lastModifiedBy;
//   bool? isActive;
//   String? name;

//   PriorityId({
//     this.status,
//     this.messages,
//     this.id,
//     this.lastModifiedTime,
//     this.lastModifiedBy,
//     this.isActive,
//     this.name,
//   });

//   factory PriorityId.fromJson(Map<String, dynamic> json) => PriorityId(
//         status: json["status"] == null ? null : json["status"],
//         messages: json["messages"] == null
//             ? null
//             : List<dynamic>.from(json["messages"].map((x) => x)),
//         id: json["id"] == null ? null : json["id"],
//         lastModifiedTime:
//             json["lastModifiedTime"] == null ? null : json["lastModifiedTime"],
//         lastModifiedBy:
//             json["lastModifiedBy"] == null ? null : json["lastModifiedBy"],
//         isActive: json["isActive"] == null ? null : json["isActive"],
//         name: json["name"] == null ? null : json["name"],
//       );

//   Map<String, dynamic> toJson() => {
//         "status": status == null ? null : status,
//         "messages":
//             messages == null ? null : List<dynamic>.from(messages!.map((x) => x)),
//         "id": id == null ? null : id,
//         "lastModifiedTime": lastModifiedTime == null ? null : lastModifiedTime,
//         "lastModifiedBy": lastModifiedBy == null ? null : lastModifiedBy,
//         "isActive": isActive == null ? null : isActive,
//         "name": name == null ? null : name,
//       };
// }

class Documents {
  Documents({
    this.documents,
  });

  List<dynamic>? documents;

  factory Documents.fromJson(Map<String, dynamic> json) => Documents(
        documents: json["documents"] == null
            ? null
            : List<dynamic>.from(json["documents"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "documents": documents == null
            ? {"documents":[]}
            : List<dynamic>.from(documents!.map((x) => x)),
      };
}

class Images {
  Images({
    this.images,
  });

  List<dynamic>? images;

  factory Images.fromJson(Map<String, dynamic> json) => Images(
        images: json["images"] == null
            ? null
            : List<dynamic>.from(json["images"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "images":
            images == null ? {"images":[]} : List<dynamic>.from(images!.map((x) => x)),
      };
}


