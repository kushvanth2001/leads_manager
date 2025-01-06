import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leads_manager/models/model_tag.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:leads_manager/constants/colorsConstants.dart';
import 'package:leads_manager/constants/networkConstants.dart';
import 'package:leads_manager/constants/styleConstants.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/models/model_Merchants.dart';
import 'package:leads_manager/models/model_chat.dart';
import 'package:leads_manager/Controller/leads_controller.dart';
import 'package:leads_manager/models/model_lead.dart';
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:leads_manager/views/chat/chatDetailsScreen.dart';
import 'package:leads_manager/views/leads/leadDetails/appController.dart';
import 'package:leads_manager/views/leads/leadNotesScreen.dart';
import 'package:leads_manager/views/leads/leadsWidget.dart';
import 'package:leads_manager/views/leads/quickResponse/QuickPage.dart';
import 'package:url_launcher/url_launcher.dart';


class SharedFunctions {
  final LeadController leadController;
  final Lead lead;
  final List<ChatModel>? chatModels;
  final VoidCallback? onBack;
  final String? firstAppName;
  final String? liveAgentUserName;
  SharedFunctions({
    required this.leadController,
    required this.lead,
    this.chatModels,
    this.onBack,
    this.firstAppName,
    required this.liveAgentUserName,
  });

  var assignedTags;
  void openAssignTagsDialog(BuildContext context) async {
    leadController.selectedAssignTags.value.clear();
    await showDialog(
      context: context,
      builder: (ctx) {
        return FutureBuilder(
          future: leadController.getAssignTags(lead.id!),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            return Obx(
              () => MultiSelectDialog(
                searchable: true,
                separateSelectedItems: true,
                unselectedColor: Colors.grey.withOpacity(0.1),
                listType: MultiSelectListType.CHIP,
                items: leadController.tags
                    .map((e) => MultiSelectItem(e, e.name!))
                    .toList(),
                initialValue: leadController.selectedAssignTags.value,
                onConfirm: (List<Tag> values) async {
                  print("Values length = ${values.length}");
                  leadController.selectedAssignTags.value.clear();
                  print(
                      "selectedAssignTags length = ${leadController.selectedAssignTags.value.length}");
                  leadController.selectedAssignTags.addAll(values);
                  print(
                      "=> selectedAssignTags length = ${leadController.selectedAssignTags.value.length}");
                  assignedTags = values;
                  addTags(lead.id, assignedTags);
                  await leadController.loadData(forcedReload: true);
                  // Get.find<AppController>().updateTags();
                  // Update the value of the tagsUpdated property to trigger a rebuild
                  // tagsUpdated.value = true;
                  // updateTags.call();
              
                  print(
                      "onTagsUpdated before n/n/n/n/n/n//n/n//nn \n\n\n\\nn\\n\n\n\\n\\n\n\n\n\n\n\\n\\n\n\n");
                  leadController.tagsUpdated.value = true;
                  print(
                      "leadController.tagsUpdated.value :${leadController.tagsUpdated.value}");
                },
              ),
            );
          },
        );
      },
    );
  }

  //Function 2

  
  Future<void> btnWhatsapp() async {
    var url = NetworkConstants.getWhatsappUrl(
        "${lead.mobileNumber}".removeAllWhitespace.replaceAll("+", ""));
    if (await canLaunch(url)) {
      await launch(url, enableJavaScript: true, enableDomStorage: true);
    }
  }

  pressCallButton() async {
    var url = "tel:+${lead.mobileNumber !=null? lead.mobileNumber!:""}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
// String onextraString(String k){

// if(k.contains('+033')){
// return k.substring(3);
// }
// else if(k.contains('033')){
// return k.substring(2);
// }else{
//   return k;
// }

// }
  // openFollowUpDialog(TextEditingController txtFollowUpName,
  //     TextEditingController txtDescription, TextEditingController txtDateTime) {
  //   return Get.defaultDialog(
  //     title: "Add Follow Up",
  //     content: Column(
  //       children: [
  //         DateTimePicker(
  //           controller: txtDateTime,
  //           type: DateTimePickerType.dateTime,
  //           dateMask: 'd MMM, yyyy - HH:mm',
  //           firstDate: DateTime(2000),
  //           lastDate: DateTime(2100),
  //           icon: Icon(Icons.event),
  //           dateLabelText: 'Date',
  //           timeLabelText: "Hour",
  //           onChanged: (val) {
  //             print(val);
  //           },
  //         ),
  //         SizedBox(height: 10),
  //         TextField(
  //           controller: txtFollowUpName,
  //           decoration: InputDecoration(
  //               labelText: 'Follow Up Name',
  //               enabledBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(10.0),
  //                   borderSide: BorderSide(color: kPrimaryColor))),
  //         ),
  //         SizedBox(height: 10),
  //         TextField(
  //           controller: txtDescription,
  //           decoration: InputDecoration(
  //               labelText: 'Description',
  //               border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(10.0),
  //                   borderSide: BorderSide(color: kPrimaryColor))),
  //           maxLines: 3,
  //           maxLength: 30,
  //           keyboardType: TextInputType.multiline,
  //         ),
  //         SizedBox(height: 10),
  //         assignedByDDL(),
  //         SizedBox(height: 10),
  //       ],
  //     ),
  //     textConfirm: "Add",
  //     confirmTextColor: Colors.white,
  //     onConfirm: () async {
  //       leadController.addFollowUp(lead.id, txtFollowUpName.text,
  //           txtDescription.text, txtDateTime.text);
  //       Get.back();
  //     },
  //     onCancel: () {},
  //   );
  // }
  

  assignedByDDL() {
    //task changes
    // return CustomSearchableDropDown(
    //   items: leadController.assignedTo.value,
    //   label: 'Select AssignedTo',
    //   initialIndex: 0,
    //   decoration: BoxDecoration(
    //       color: Colors.white,
    //       borderRadius: BorderRadius.circular(15),
    //       border: Border.all()),
    //   prefixIcon: Padding(
    //     padding: const EdgeInsets.all(0.0),
    //     child: Icon(Icons.search),
    //   ),
    //   dropDownMenuItems: leadController.assignedTo.value.map((user) {
    //     return "${user.firstName} ${user.lastName}";
    //   }).toList(),
    //   onChanged: (user) {
    //     if (user != null) {
    //       leadController.taskModel.assignedTo = user;
    //     } else {
    //       leadController.taskModel.assignedTo = null;
    //     }
    //   },
    // );
  }

  //Function 3

  List<Widget> buildTags(
    BuildContext context,
    textController,
    txtFollowUpName,
    txtDescription,
    txtDateTime,
  ) {
    List<Widget> tagsList = [];

    if (lead.tagsDto != null && lead.tagsDto!.tags!.length != 0) {
      int len = lead.tagsDto!.tags!.length;
      for (int i = 0; i < len; i++) {
        tagsList.add(
          Container(
              child: Chip(
            label: Text(
              "${lead.tagsDto!.tags![i].name ?? ""}",
              style: TextStyle(color: Colors.white, fontSize: kSmallFontSize),
            ),
            backgroundColor: lead.tagsDto?.tags![i].color == null
                ? Colors.grey
                : HexColor(lead.tagsDto!.tags![i].color!),
          )),
        );
      }
    }
    tagsList.add(
      IconButton(
        icon: Icon(
          Icons.add_circle_outline_outlined,
          color: Colors.black,
        ),
        onPressed: () {
          openAssignTagsDialog(context);
        },
      ),
    );
    // tagsList.add(popUpMenu(textController, txtFollowUpName, txtDescription, txtDateTime));

    return tagsList;
  }
}
