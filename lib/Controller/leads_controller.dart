import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:leads_manager/models/model_callstatus.dart';
import 'package:leads_manager/models/model_lead.dart';
import 'package:leads_manager/models/model_tag.dart';
import 'package:leads_manager/models/model_taskpage.dart' hide Documents;
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/utils/snapPeUI.dart';
import 'package:leads_manager/views/leads/leadsWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/model_CreateNote.dart'; //hide Documents;
import '../models/model_FollowUp.dart' hide Documents;
import '../models/model_LeadStatus.dart';
import '../models/model_Merchants.dart';

import '../models/model_Users.dart';

class LeadController extends GetxController {
  Rx<LeadModel> leadModel = LeadModel().obs;
  RxList<Lead> leads=<Lead>[].obs;
  RxBool tagsUpdated = false.obs;
  RxList<Tag> tags = <Tag>[].obs;
  Map<int, Tag> tagsMap = {};
  RxList<Tag> selectedTags = <Tag>[].obs;
  RxList<Tag> selectedAssignTags = <Tag>[].obs;

RxBool isloading =true.obs;
  RxList<User> assignedTo = <User>[].obs;
  RxList<User> selectedAssignedTo = <User>[].obs;

  RxList<User> assignedBy = <User>[].obs;
  RxList<User> selectedAssignedBy = <User>[].obs;

  RxList<AllLeadsStatus> leadStatus = <AllLeadsStatus>[].obs;
  RxList<AllLeadsStatus> selectedLeadStatus = <AllLeadsStatus>[].obs;
  RxList<String> scources=<String>[].obs;
  RxList<String> selectedSources = <String>[].obs;
  RxList<String> selectedDates = <String>[].obs;
  Rx<String> selectedPeriod="last30Days".obs;
  Rx<String> selectedSortFilter="lastModifiedTime&sortOrder=DESC".obs;
 Rx<String?> selectedLastmodifedFrom = Rx<String?>(null);
Rx<String?> selectedLastmodifedTo = Rx<String?>(null);

static Rx<String> lastcalledLead=''.obs ;
  Rx<double> scrolloffset=0.0.obs;
  Rx<int> inlightlead=0.obs;
    Rx<bool> fecthingdata=false.obs;
  bool onceexecutor=true;
   Rx<bool> ondargstart=false.obs;
   RxList<Lead> leadpouch=<Lead>[].obs;
   
Rx<Map<String, List<Map<String, dynamic>>>> phonenumberdiologuevalues = Rx<Map<String, List<Map<String, dynamic>>>>({});
   Map<String, String> periodFilters = {
    "All": "all",
    "Today": "today",
    "Yesterday": "yesterday",
    "Last 7 Days": "lastWeek",
    "Last 30 Days": "last30Days",
    "Current Month": "currentMonth",
    "Last Month": "lastMonth",
    "Current Year": "currentYear",
    "Last Year": "lastYear"
  };
  RxList<String> featureKeys = [
    "Tags",
    "AssignedTo",
    "Status",
    "AssignedBy",
    "Source",
    "Date",
    "Period",
    "LastActivity"
  ].obs; // "Organization Name", "Email", "Source"
  Rx<String> selectedFeatureKey = "Tags".obs; //Default selected
static RxDouble disableopquicty=1.0.obs;
  ScrollController scrollController = ScrollController();

  int currentPage = 0, size = 10, totalRecords = 0, pages = 0;
  String nameormobilenumber="";
 // TaskModel taskModel = TaskModel();

 

  @override
  void onInit() {
    super.onInit();
    
    
     
  
    print("0calllist");

  
  }
  LeadController() {
 
    loadData();
    scrollListener();
    
     getDataFromSharedPreferences();
     
  //scrolltoid();

  }

  void refreshController() {
    LeadController().refresh(); // Refresh the controller
  }
getDataFromSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  
  int? leadId = prefs.getInt('leadid');

  if (leadId != null) {
  
    inlightlead.value=leadId;
    
  }



}
 
  scrollListener() async {
     scrollController.addListener(() {
if(scrollController.offset<=0){
  disableopquicty.value=1;
}else{
  disableopquicty.value=0;
}

    double threshold = scrollController.position.maxScrollExtent * 0.75;

    if (scrollController.position.pixels >= threshold) {
      if(fecthingdata.value==false){
      if (currentPage != pages && leadModel.value.leads!.length != totalRecords) {
        getFilteredLeads(page: ++currentPage,isfrompageincrement: true);
      } else {
    // SnapPeUI().toastWarning(message: "No More Record.");
      }}
    }
  });

}

  loadData({bool forcedReload = false}) async {

    if (forcedReload) {
      await getFromNetwork();
    } else {
       await getFromNetwork();
      //await getFromDB();
    }
  
      // await getFromNetwork();

  }

//   Future<void> getFromDB() async {
//     isloading.value=true;
//     String? leads = await SharedPrefsHelper().getLeads();
//     String? leadTags = await SharedPrefsHelper().getLeadTags();
//     String? usersJSON = await SharedPrefsHelper().getUsers();
//     String? leadStatusJSON = await SharedPrefsHelper().getLeadStatus();
//  //   print("userjson $usersJSON");
//     if (leads != null &&
//         leadTags != null &&
//         usersJSON != null &&
//         leadStatusJSON != null) {
//       leadModel.value = leadModelFromJson(leads);
//       totalRecords = leadModel.value.totalRecords ?? 0;
//       pages = leadModel.value.pages ?? 0;
//    //   print("Pages - $pages  TotalRecords - $totalRecords");
//       tags.value = tagsDtoFromJson(leadTags).tags ?? [];
//       createTagMap();
//       assignedTo.value = usersModelFromJson(usersJSON).users ?? [];
//       assignedBy.value = usersModelFromJson(usersJSON).users ?? [];
//       leadStatus.value =
//           leadStatusModelFromJson(leadStatusJSON).allLeadsStatus ?? [];
//     } else {
//       await getFromNetwork();
//     }
//     isloading.value=false;
//   }

  Future<void> getFromNetwork() async {
 
    if (selectedTags.length == 0 && selectedAssignedTo.length == 0) {
      print("1");
     await getFilteredLeads();
    } else {
    await  getFilteredLeads();
    }
    //getFilteredLeads();
    getTags();
   // print(" getTags(); called ");
    getUsers();
    getLeadStatus();
    getLeadSources();
  
  }

  Future<void> getFilteredLeads({int page = 0,bool isfrompageincrement=false}) async {
 var nameOrMobile=nameormobilenumber ;
    fecthingdata.value=true;
   
    currentPage = page;
  //  print("Page - $page, CurrentPage - $currentPage");
print("-1");
    List<String> tagNameList = selectedAssignTags .value.map((e) => e.name!).toList();
    List<int> assignedToUserIdList =selectedAssignedTo.value.map((e) => e.userId!).toList();
    List<int> assignedByUserIdList =selectedAssignedBy.value.map((e) => e.id!).toList();
    List<String> status = selectedLeadStatus.map((e) => e.statusName!).toList();
    List<String> selectedSourcess = selectedSources.value;
    List<String> selectedDatess = selectedDates.value;

 print("__t${tagNameList}");
    print("-1.1");
    String? leadsJSON = await SnapPeNetworks().filterLeads(page, size,
        nameOrMobile: nameOrMobile,
        tags: tagNameList,
        assignedTo: assignedToUserIdList,
        assignedBy: assignedByUserIdList,
        selectedSources: selectedSourcess,
        selectedDatess: selectedDatess,
lastmodifedfrom: selectedLastmodifedFrom.value,
lastmodifiedto: selectedLastmodifedTo.value,
        leadStatus: status,selectedPeriod: selectedPeriod.value,isfrompageincrement: isfrompageincrement,sortfilter: selectedSortFilter.value);
        print("-2");
    if (leadsJSON != null) {
      if (page != 0) {
        print("-3");
        leadModelFromJson(leadsJSON).leads!.forEach((e) {
          leadModel.update((value) {
            value?.leads?.add(e);
          });
        });
        leadModel.value.leads!=null?leads.value=leadModel.value.leads!:2-4;
        
      } else {
        print("-4");
        leadModel.value = leadModelFromJson(leadsJSON);
        leadModel.value.leads!=null?leads.value=leadModel.value.leads!:2-4;
        totalRecords = leadModel.value.totalRecords ?? 0;
        pages = leadModel.value.pages ?? 0;
        SharedPrefsHelper().setLeads(leadsJSON);
      }
    }
    print("-5");
    fecthingdata.value=false;
  }

  void getTags() async {
    print("3");
    String? leadTagsJSON = await SnapPeNetworks().getLeadTags();
    if (leadTagsJSON != null) {
      tags.value = tagsDtoFromJson(leadTagsJSON).tags ?? [];
      createTagMap();
      SharedPrefsHelper().setLeadTags(leadTagsJSON);
    }
  }

  createTagMap() {
    tagsMap = {};
    for (Tag tag in tags.value) {
      tagsMap[tag.id!] = tag;
    }
  }

  Future<List<Tag>> getAssignTags(int leadId) async {
    print("4");
    String? leadTagsJSON = await SnapPeNetworks().getAssignTags(leadId);
    if (leadTagsJSON != null) {
      List<Tag> list = tagsDtoFromJson(leadTagsJSON).tags ?? [];

      for (Tag tag in list) {
        if (tagsMap.containsKey(tag.id)) {
          selectedAssignTags.value.add(tagsMap[tag.id]!);
        }
      }
    }
    return selectedAssignTags.value;
  }

  updateAssignTag(int leadId) async {
     print("5");
    String? leadTagsJSON = await SnapPeNetworks()
        .updateAssignTags(leadId, TagsDto(tags: selectedAssignTags));
    if (leadTagsJSON != null) {
      selectedAssignTags.value = tagsDtoFromJson(leadTagsJSON).tags ?? [];

    //  print("selectedAssignTags length = ${selectedAssignTags.value.length}");
    }
  }

  void getUsers() async {
     print("6");
    String? usersJSON = await SnapPeNetworks().getUsers();
    if (usersJSON != null) {
      assignedTo.value = usersModelFromJson(usersJSON).users ?? [];
      assignedBy.value=usersModelFromJson(usersJSON).users ?? [];
      SharedPrefsHelper().setUsers(usersJSON);
    }
  }

  void getLeadStatus() async {
     print("7");
    String? leadStatusJSON = await SnapPeNetworks().getLeadStatus();
    if (leadStatusJSON != null) {
      leadStatus.value =
          leadStatusModelFromJson(leadStatusJSON).allLeadsStatus ?? [];
      SharedPrefsHelper().setLeadStatus(leadStatusJSON);
    }
  }
  void getLeadSources() async {
     print("8");
    List<String> sourcess =await SnapPeNetworks().fetchLeadSourcess();
if(sourcess!=null && !(sourcess.isEmpty)){

scources.value=sourcess;
}
  }

  void clearFilter() {
    selectedTags.clear();
    selectedAssignedTo.clear();
    selectedAssignedBy.clear();
    selectedSources.clear();
    selectedLeadStatus.clear();
    selectedDates.clear();
    selectedPeriod.value ="all";
    selectedSortFilter.value="lastModifiedTime&sortOrder=DESC";
    selectedLastmodifedFrom.value=null;
    selectedLastmodifedTo.value=null;
  }

  void addFollowUp(Lead leadId, String followUpName, String description,
      DateTime time,User? assignedto,BuildContext context,{bool notifycustomer=false,String remindertext =''}) async {
    Task task=Task();
    task.name = followUpName;
    task.description = description; 
task.reminderMessage=remindertext!=''?remindertext:null;
task.assignedTo=assignedto;
print("fromfunc"+assignedto.toString());
    task.remindCustomer=notifycustomer;
    DateTime utcDT = DateTime.utc(time.year, time.month, time.day,time.hour,time.minute);
    String lastTime = "${time.hour}:${time.minute}:00";

    task.startTime = utcDT.toIso8601String();
    task.endTime = utcDT.toIso8601String();
    task.lastTime = lastTime;
    task.customerName=leadId.customerName;
    task.customerMobileNumber=leadId.mobileNumber;
    


   String? res = await SnapPeNetworks().createTask(leadId.id, task);

    if (res != null) {
      var task;
     Task followtask = Task.fromJson(jsonDecode( res));
 print("resultis notnull");
   FollowUpModel followUpModel = FollowUpModel(AssignedTo:assignedto! );
      followUpModel.taskId =followtask.id!=null?int.tryParse( followtask.id??"0"):0;
      followUpModel.status = "OK";
      followUpModel.leadId = leadId.id;
      followUpModel.isActive = true;
      followUpModel.reminderMessage=remindertext;
      followUpModel.remarks = "Follow Up Added Successfully";
followUpModel.startTime=time.toIso8601String();
followUpModel.endTime=time.toIso8601String();
followUpModel.remindcusomer=notifycustomer;

      await SnapPeNetworks().addFollowUp(leadId.id, followUpModel);
    }
    else{
      print("resultisnull");
    }
  }

  Future<void> createNote(int? id, String text,{ List<dynamic> documnets=const []} ) async {
    {
  List<Document> docList = documnets.map((e) => Document(fileLink: e)).toList();
  Documents documents = Documents(documents: docList);
    await SnapPeNetworks()
        .createLeadNotes(id, CreateNote(remarks: "<p>$text</p>",documents:documents ));
  }}
    Future<void> editNote(Map<String,dynamic> json) async {
      print('attachmentlen${json['documents']['documents'].length}');
    await SnapPeNetworks().editLeadNotes( json);
  }
   Future<void> deleteNote(int? id, Map<String,dynamic> json) async {
    await SnapPeNetworks()
        .deleteLeadNotes(id!,json);
  }
}

