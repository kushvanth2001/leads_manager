import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:leads_manager/constants/styleConstants.dart';
import 'package:leads_manager/helper/Filepickerhelper.dart';
import 'package:leads_manager/models/model_CreateNote.dart';
import 'package:leads_manager/models/model_LeadNotes.dart';
import 'package:leads_manager/models/model_leadDetails.dart';
import 'package:leads_manager/utils/snapPeUI.dart';
import 'package:leads_manager/views/leads/leadDetails/notesWidget.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/views/leads/leadsScreen.dart';
import '../../../Controller/leadDetails_controller.dart';
import '../../../Controller/leads_controller.dart';
import '../../../constants/colorsConstants.dart';
import 'package:leads_manager/models/model_lead.dart' as model_lead;
import '../../../models/model_lead.dart';

class LeadNotesScreen extends StatefulWidget {
  final int? leadId;
  final LeadController? leadController;
  final model_lead.Lead? lead;
  final VoidCallback? onBack;
  const LeadNotesScreen(
      {Key? key, this.leadId, this.leadController, this.lead, this.onBack})
      : super(key: key);

  @override
  State<LeadNotesScreen> createState() => _LeadNotesScreenState(leadController);
}

class _LeadNotesScreenState extends State<LeadNotesScreen> {
  late LeadController? leadController;
  _LeadNotesScreenState(LeadController? leadController) {
    this.leadController = leadController;
  }

  bool showLoading = true;

  @override
  void initState() {
    super.initState();
    setdata();
  }

  setdata() async {}

  TextEditingController textController = TextEditingController();

  late model_lead.Lead lead = new model_lead.Lead();

  @override
  Widget build(BuildContext context) {
    final LeadDetailsController controller =
        LeadDetailsController(widget.leadId);

    bool dataLoaded = false;

    // This function is called when the data has finished loading from the API
    void onDataLoaded() {
      setState(() {
        dataLoaded = true;
      });
    }

void openCreateNoteDialog(BuildContext context, TextEditingController textController) {
  var attachments = [];
  

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text("Create Note"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: kPrimaryColor),
                      ),
                    ),
                    maxLines: 10,
                    keyboardType: TextInputType.multiline,
                  ),
                  attachments.isNotEmpty
                      ? Container(
                          height: 200,
                          width: 200, // Adjust the height as needed
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: attachments.length,
                            itemBuilder: (context, index) {
                              return Container(
                                height: 100,
                                width: 100,
                                child: FileUploadingManger.buildAttachmentWidget(attachments[index], context,(value){
                                     
                                     if(value!=null){
                                     setState(() {
              
                        attachments.removeAt(index);
                      });}
                                },maxlines: 2),);
                            },
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            actions: [
                 IconButton(
                onPressed: () async {
                  var k = await FileUploadingManger.uploadFiles();
                  if (k != null) {
                    setState(() {
                      attachments .addAll( k);
                    });
                  }
                },
                icon: Icon(Icons.attachment, color: Colors.black),
              ),
              TextButton(
                onPressed: () {
                  textController.text='';
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    if(textController.text!='' || attachments.isNotEmpty ){
                    await leadController?.createNote(
                      widget.leadId,
                      textController.text,
                      documnets: attachments
                    );}else{
 Fluttertoast.showToast(msg: "Either Message or Attachments need to be Filled");

                    }
                  } catch (e) {
                    print('Unable to parse task id: $e');
                  }
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => super.widget,
                    ),
                  );
                },
                child: Text("Save"),
              ),
           
            ],
          );
        },
      );
    },
  );
}

void openEditNoteDialog(BuildContext context, TextEditingController textController, LeadAction leadaction) {
  var attachments = leadaction.documents?.documents?.map((e) {
    return e.fileLink;
  }).toList() ?? [];
  var newattachments = [];
  bool isptag = false;
  final RegExp exp = RegExp(r'<p>(.*?)<\/p>', caseSensitive: false, dotAll: true);
  final match = exp.firstMatch(textController.text);
  if (match != null && match.groupCount > 0) {
    textController.text = match.group(1) ?? '';
    isptag = true;
  }
  print('attachmentlen${attachments.length}');
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text("Edit Note"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: kPrimaryColor),
                      ),
                    ),
                    maxLines: 10,
                    keyboardType: TextInputType.multiline,
                  ),
                  attachments.length + newattachments.length != 0
                      ? Container(
                          height: 200,
                          width: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: attachments.length + newattachments.length,
                            itemBuilder: (context, index) {
                              return Container(
                                height: 100,
                                width: 100,
                                child: FileUploadingManger.buildAttachmentWidget(
                                  index < attachments.length
                                      ? attachments[index] ?? ''
                                      : newattachments[index - attachments.length] ?? '',
                                  context,
                                  (value) {
                                    if (value != null) {
                                      setState(() {
                                        if (attachments.contains(value)) {
                                          attachments.remove(value);
                                        } else {
                                          newattachments.remove(value);
                                        }
                                      });
                                    }
                                  },
                                  candelete: false,
                                  maxlines: 2,
                                ),
                              );
                            },
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  var k = await FileUploadingManger.uploadFiles();
                  print('attachmentklen${attachments.length}');
                  if (k != null) {
                    setState(() {
                      for (var file in k) {
                        if (!attachments.contains(file) && !newattachments.contains(file)) {
                          newattachments.add(file); // Add only unique attachments
                          print('attachmentlen${attachments.length}');
                        }
                      }
                    });
                  }
                },
                icon: Icon(Icons.attachment, color: Colors.black),
              ),
              TextButton(
                onPressed: () {
                  textController.text = '';
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (textController.text != '' || attachments.length + newattachments.length != 0) {
                    leadaction.remarks = isptag ? "<p>${textController.text}</p>" : textController.text;
                    leadaction.documents?.documents =  newattachments.map((e) {
                      return Document(fileLink: e);
                    }).toList();
                    try {
                      await leadController?.editNote(leadaction.toJson());
                    } catch (e) {
                      print('Unable to parse task id: $e');
                    }
                    Get.back();
                    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                    controller.loadData(widget.leadId);
                    textController.text = '';
                  } else {
                    Fluttertoast.showToast(msg: "Either Message or Attachments need to be Filled");
                  }
                },
                child: Text("Edit"),
              ),
            ],
          );
        },
      );
    },
  );
}



//     openEditNoteDialog(
//         TextEditingController textController, Map<String, dynamic> json) {
//       bool isptag = false;
//       final RegExp exp =
//           RegExp(r'<p>(.*?)<\/p>', caseSensitive: false, dotAll: true);
//       final match = exp.firstMatch(textController.text);
//       if (match != null && match.groupCount > 0) {
//         textController.text = match.group(1) ?? '';
//         isptag = true;
//       }

//       return Get.defaultDialog(
//         title: "Edit Note",
//         content: Column(
//           children: [
//             TextField(
//               controller: textController,
//               decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                       borderSide: BorderSide(color: kPrimaryColor))),
//               maxLines: 10,
//               // maxLength: 200,
//               keyboardType: TextInputType.multiline,
//             )
//           ],
//         ),
//         textConfirm: "Edit",
//         confirmTextColor: Colors.white,
//         onConfirm: () async {
//           json["remarks"] =
//               isptag ? "<p>${textController.text}</p>" : textController.text;
//           await leadController?.editNote(json);
//           Get.back();
//           if (Navigator.of(context).canPop()) Navigator.of(context).pop();
//           controller.loadData(widget.leadId);
//           // Navigator.pushReplacement(context,
//           //     MaterialPageRoute(builder: (BuildContext context) => super.widget));
//           textController.text='';
//         },
//         onCancel: () {
//           Get.back();
// //  if(Navigator.of(context).canPop())
// //         Navigator.of(context).pop();
// textController.text='';
//         },
//       );
//     }

    buildNotes() {
      if (controller.leadNotesModel.value.leadActions != null &&
          controller.leadNotesModel.value.leadActions!.length != 0) {
        return Expanded(
          child: ListView.builder(
            // reverse: true,
            padding: const EdgeInsets.all(20.0),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: controller.leadNotesModel.value.leadActions!.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(Icons.edit),
                              onTap: () {
                                TextEditingController tcontroller =
                                    TextEditingController(
                                        text: controller.leadNotesModel.value
                                            .leadActions![index].remarks);

                                openEditNoteDialog(context,
                                    tcontroller,
                                    controller.leadNotesModel.value
                                        .leadActions![index]
                                        );
                              },
                              title: Text("Edit"),
                            ),
                            ListTile(
                              leading: Icon(Icons.delete),
                              onTap: () async {
                                await leadController?.deleteNote(
                                    controller.leadNotesModel.value
                                        .leadActions![index].id,
                                    controller.leadNotesModel.value
                                        .leadActions![index]
                                        .toJson());
                                await controller.loadData(widget.leadId);
                                Navigator.pop(context);
                              },
                              title: Text("Delete"),
                              
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
                child: NoteWidget(
                    leadAction:
                        controller.leadNotesModel.value.leadActions![index]),
              );
            },
          ),
        );
      } else {
        return SnapPeUI().noDataFoundImage(msg: "Empty Notes !");
      }
    }

    return WillPopScope(
      onWillPop: () async {
        if (widget.onBack != null) {
          widget.onBack!();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: SnapPeUI().appBarText("Notes", kBigFontSize),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                openCreateNoteDialog(context,textController,);
              },
            ),
          ],
        ),
        body: Column(children: [
          Obx(
            () => buildNotes(),
          ),
        ]),
      ),
    );
  }
}
