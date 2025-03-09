import 'dart:convert';
import 'dart:core';

import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:leads_manager/models/model_chatlist.dart';
import 'package:leads_manager/models/model_leadDetails.dart' as detailsmodel;
import 'package:leads_manager/models/model_tag.dart';
import 'package:leads_manager/models/model_taskpage.dart';
import 'package:leads_manager/views/chat/Indetailchatscreen.dart';
import 'package:leads_manager/views/leads/customerconverter.dart';
import 'package:leads_manager/views/leads/quotationcreator.dart';
import 'package:leads_manager/views/leads/taskDetails.dart';
import 'package:leads_manager/views/leads/tasksbyLead.dart';
import 'package:leads_manager/views/opportunity/addopportunity.dart' as oppr;
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:leads_manager/Controller/chat_controller.dart';
import 'package:leads_manager/constants/colorsConstants.dart';
import 'package:leads_manager/constants/networkConstants.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:leads_manager/models/model_CreateNote.dart';
import 'package:leads_manager/models/model_Merchants.dart';
import 'package:leads_manager/models/model_application.dart';
import 'package:leads_manager/models/model_callstatus.dart';
import 'package:leads_manager/models/model_chat.dart';
import 'package:leads_manager/models/model_lead.dart';
import 'package:leads_manager/models/model_tags.dart';
import 'package:leads_manager/utils/SharedFunctions.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/views/chat/chatDetailsScreen.dart';
import 'package:leads_manager/views/leads/callLogsScreen.dart';
import 'package:leads_manager/views/leads/leadDetails/leadDetails.dart';
import 'package:leads_manager/views/leads/leadNotesScreen.dart';
import 'package:leads_manager/views/leads/quickResponse/QuickPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Controller/leads_controller.dart';
import '../../Controller/theme_contoller.dart';
import '../../constants/styleConstants.dart';
import '../../domainvariables.dart';

class LeadWidget extends StatefulWidget {
  final VoidCallback onBack;
  final Lead lead;
  final int index;

  final AssignedTo? assignedTo;
  final LeadController leadController;
  final String? firstAppName;
  final String? liveAgentUserName;
  final Color? color;
  bool isNewleadd;
  final bool? reducewidth;
  final List<ChatModel>? chatModels;
  LeadWidget({
    Key? key,
    required this.onBack,
    this.firstAppName,
    required this.liveAgentUserName,
    required this.index,
    required this.lead,
    required this.leadController,
    this.assignedTo,
    required this.isNewleadd,
    
    this.reducewidth,
    this.chatModels,
    this.color,
  }) : super(key: key);

  @override
  State<LeadWidget> createState() => _LeadWidgetState();
}

class _LeadWidgetState extends State<LeadWidget> {
    bool conversationPrivillage=  true;
    bool calllogsPrivillage= true;
  List<dynamic> _template = [];
  LeadController leadController = Get.find<LeadController>();
  late final SharedFunctions sharedFunctions;
  // Define a MethodChannel with a unique name
  // Invoke the getCallInfo method in the platform-specific code
  Future<Map<String, dynamic>?> getCallInfo(String phoneNumber) async {
    try {
      final result = (await platform.invokeMethod<Map<dynamic, dynamic>>(
              'getCallInfo', phoneNumber))
          ?.map((key, value) => MapEntry(key.toString(), value));

      return result;
    } on PlatformException catch (e) {
      // Handle the exception
      return null;
    }
  }

  Future<void> _getTemplates() async {
    var clientdGroupName = await SharedPrefsHelper().getClientGroupName();
    final userselectedApplicationName =
        SharedPrefsHelper().getUserSelectedChatbot(clientdGroupName ?? "");
    try {
      final templates = await getTemplates(userselectedApplicationName);
      if (mounted) {
        setState(() {
          _template = templates;
        });
      }
    } catch (e) {
      // Handle the error here
      print(e);
      // _selectedApplicationName = firstAppName;
    }
  }


 // ThemeController themeController = Get.find<ThemeController>();
  Lead _lead = Lead();
  
  @override
  void initState() {
    super.initState();
    setState(() {
      _lead = widget.lead;
    });

    sharedFunctions = SharedFunctions(
      liveAgentUserName: widget.liveAgentUserName,
      leadController: widget.leadController,
      lead: widget.lead,
      chatModels: widget.chatModels,
      firstAppName: widget.firstAppName,
    );
    // print("${widget.firstAppName} in leadswidget \n\n\\n\n\\n\\n\n\\n\n");

// Fetch the list of call status objects and update the state

  initAsync();
    // setdata();
  }

// setdata()async{
//     _getTemplates();
// }

initAsync()async{
 conversationPrivillage=await SharedPrefsHelper().getviewCommnuicationsPrivillage();
   calllogsPrivillage=await SharedPrefsHelper().getviewcallLogsPrivillage() ;
}
  bool _isExpanded = false;
  final GlobalKey _tooltipKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();

    // var leadController=widget.leadController;

    DateTime parsedDate = DateTime.parse(_lead.createdOn.toString());
    String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
    return Obx(
      () => GestureDetector(
        onTap: () async {
          setState(() {
            _isExpanded = !_isExpanded;
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();
          widget.leadController.inlightlead.value = _lead.id ?? 0;
          widget.leadController.scrolloffset.value =
              widget.leadController.scrollController.offset;
          prefs.setInt('leadid', _lead.id ?? 0);
        },
        child: LongPressDraggable<Lead>(
          onDragStarted: (){
print(" ${leadController.ondargstart.value}");
            leadController.ondargstart.value=true;
          },
          
          onDragCompleted: (){
                 leadController.ondargstart.value=false;
                 print(" ${leadController.ondargstart.value}");
          },
  onDraggableCanceled: (velocity, offset) {
    leadController.ondargstart.value = false;
    print("Drag canceled");
  },
           data: _lead,
      feedback: Material(
        child: Container(
          height: 100,
          width:MediaQuery.of(context).size.width,
          child: LeadWidget(
            index:widget.index,
            onBack:(){},
            liveAgentUserName:widget.liveAgentUserName,
            lead: _lead,
            leadController: leadController,
            isNewleadd: widget.isNewleadd,
          
            firstAppName: widget.firstAppName,
            chatModels: widget.chatModels,
          ),
        ),
      ),
      childWhenDragging: Container(height: 90,width:MediaQuery.of(context).size.width,color: Colors.black26,), // 
          child: Card(
            color: widget.leadController.inlightlead.value == _lead.id
                ? Colors.blue.shade200
                :  Colors.white,
            
            elevation: 4,
            child: AnimatedSize(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: Column(
                mainAxisSize: MainAxisSize
                    .min, // Ensures the column takes only the necessary space
                children: [
                  ListTile(
                    leading: InkWell(
                      onDoubleTap: () async{
                       SharedPreferences prefs = await SharedPreferences.getInstance();
          widget.leadController.inlightlead.value = _lead.id ?? 0;
          widget.leadController.scrolloffset.value =
              widget.leadController.scrollController.offset;
          prefs.setInt('leadid', _lead.id ?? 0);
                            print(widget.leadController.scrolloffset);
              
                            Get.to(LeadDetails(
                              lead: _lead,
                              isNewLead: false,
                              dynamicCallback: (k){
                                setState(() {
                                  if(k!=null){
                                   _lead=k;}
                                });
                               
                              },
                            ));
                          },
                      onTap: () {
                        final dynamic tooltip = _tooltipKey.currentState;
                        tooltip.ensureTooltipVisible();
                      },
                      child: Tooltip(
                        key: _tooltipKey,
                        message:
                            "${_lead.customerName}\n ${_lead.mobileNumber}\n ${_lead.leadStatus?.statusName}\n${DateFormat('h:mm -dd MMM yyyy').format(
                          (_lead.createdOn ?? DateTime.now()).add(Duration(hours: 5,minutes: 30)),
                        )}",
                        child: Stack(
                          children: [
                            Container(
                              height: 14,
                              width: 10,
                              color: Colors.green.shade300,
                            ),
                          Obx(()=>  CircleAvatar(
                                child:LeadController.lastcalledLead.value== _lead.id.toString()?Image.asset('assets/icon/telephone2.png',fit: BoxFit.cover,) :Text((_lead.customerName ??
                                                _lead.mobileNumber ??
                                                "00")
                                            .length >=
                                        1
                                    ? (_lead.customerName ??
                                            _lead.mobileNumber ??
                                            "00")
                                        .substring(0, 1)
                                    : "0")),),
                            Positioned(
                                bottom: 0,
                                left: -50,
                                right: -50,
                                child: Container(
                                    height: 14,
                                    width: 14,
                                    color: Colors.purple.shade200,
                                    child: Center(
                                      child: Text(DateFormat('EEE').format(
                                        (_lead.createdOn ?? DateTime.now()).add(Duration(hours: 5,minutes: 30))
                                      )),
                                    ))),
                        
                        

                          ],
                        ),
                      ),
                    ),
                    title: Wrap(
                      children: [
                        GestureDetector(
                          onTap: () async {
                       SharedPreferences prefs = await SharedPreferences.getInstance();
          widget.leadController.inlightlead.value = _lead.id ?? 0;
          widget.leadController.scrolloffset.value =
              widget.leadController.scrollController.offset;
          prefs.setInt('leadid', _lead.id ?? 0);
                      
            
                            Get.to(LeadDetails(
                              lead: _lead,
                              isNewLead: false,
                              dynamicCallback: (k){
                                setState(() {
                                   _lead=k;
                                });
                               
                              },
                            ));
                          },
                          child: Text(
                            "${ validateString( decodeText( _lead.customerName))  ??validateString( _lead.mobileNumber) ??validateString( _lead.email)?? "-"}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: kMediumFontSize,
                              decoration: TextDecoration.underline
                            ),
                          ),
                        ),
                      
                        Text("")
                      ],
                    ),
                    trailing: Column(
                    
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [


  

 



                      _lead.assignedBy != null?
                          Text(
                            "${ validateString( _lead.assignedBy?.firstName) ?? "-"} ${validateString( _lead.assignedBy?.lastName) ?? "-"}",
                            overflow: TextOverflow.ellipsis,
                          ):Text("-"),
                        Icon(Icons.arrow_downward,
                            size: 10, color: Colors.blue),
                      _lead.assignedTo != null?                          Text(
                             "${ validateString( _lead.assignedTo?.firstName) ?? "-"} ${validateString( _lead.assignedTo?.lastName) ?? "-"}",
                            overflow: TextOverflow.ellipsis,
                          ):Text("-"),
                        
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          _lead.mobileNumber != null && _lead.mobileNumber!=''?
                          Text(
                            "${ _lead.mobileNumber}",
                            overflow: TextOverflow.ellipsis,
                         style: TextStyle(fontSize: 11,color: Colors.grey), ):Text("-"),
                           Text(
  style: TextStyle(fontSize: 12),
  DateFormat('@dd-MMM-yy').format(
    (_lead.createdOn ?? DateTime.now()).add(Duration(hours: 5,minutes: 30)),
  ),
),
                 _lead.leadStatus?.statusName!=null &&_lead.leadStatus?.statusName!=''?Wrap(direction: Axis.horizontal,
                 children: [
Text('${_lead.leadStatus?.statusName}',style:const TextStyle(fontSize: 11,color: Colors.grey),  overflow: TextOverflow.ellipsis,)
                 ],) :Container(),    
                        Wrap(
                   direction: Axis.horizontal,
                          children: [
                           
                        
                         _lead.followUpDate!=null? Icon(
                                                size: 13,
                          Icons.access_alarm,
                          color: Colors.purple.shade200,
                                              ):Container(),
                                     
                                          _lead.followUpDate!=null?    Text(
                          "${   _lead.followUpDate!.split("T")[0]}",
                          style: TextStyle(color: Colors.black,fontSize: 11),
                                              ):Container(),
                        

                          ],
                        ),
                             Wrap(
                   direction: Axis.horizontal,
                          children: [
                           
                        
                         _lead.organizationName!=null && _lead.organizationName!=''? Icon(
                                                size: 13,
                          Icons.business,
                          color: Colors.purple.shade200,
                                              ):Container(),
                                     
                                          _lead.organizationName!=null && _lead.organizationName!=''?    Text(
                          "${   _lead.organizationName}",
                          style: TextStyle(color: Colors.black,fontSize: 11),
                                              ):Container(),
                        

                          ],
                        ),


                      ],
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: _isExpanded ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 900),
                    child: _isExpanded
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: actionMenuItems(_lead,context,calllogsPrivillage: calllogsPrivillage,conversationPrivillage: conversationPrivillage),
                          )
                        : Container(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildTags(
    textController,
    txtFollowUpName,
    txtDescription,
    txtDateTime,
  ) {
    List<Widget> tagsList = [];

    if (_lead.tagsDto != null && _lead.tagsDto!.tags!.length != 0) {
      int len = _lead.tagsDto!.tags!.length;
      for (int i = 0; i < len; i++) {
        tagsList.add(
          Container(
              child: Chip(
            label: Text(
              "${_lead.tagsDto!.tags![i].name ?? ""}",
              style: TextStyle(color: Colors.white, fontSize: kSmallFontSize),
            ),
            backgroundColor: _lead.tagsDto?.tags![i].color == null
                ? Colors.grey
                : HexColor(_lead.tagsDto!.tags![i].color!),
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

  void conversations(BuildContext context) {
    // Navigator.push(context, MaterialPageRoute(builder: (context) {
    //   return Scaffold(
    //     appBar: AppBar(
    //       title: Container(
    //         decoration: BoxDecoration(
    //           color: Colors.white,
    //           borderRadius: BorderRadius.circular(10),
    //           border: Border.all(
    //             width: 1,
    //           ),
    //         ),
    //         child: DropdownButton<String>(
    //           value: _selectedApplicationName,
    //           icon: const Icon(Icons.arrow_drop_down),
    //           onChanged: (value) {
    //             setState(() {
    //               _selectedApplicationName = value;
    //             });
    //           },
    //           items: _applicationNames.map((appName) {
    //             return DropdownMenuItem<String>(
    //               value: appName,
    //               child: Text(appName!),
    //             );
    //           }).toList(),
    //         ),
    //       ),
    //     ),
    //     body: ListView.builder(
    //       itemCount: 5,
    //       itemBuilder: (BuildContext context, int index) {
    //         return ListTile(
    //           title: Text("Hey"),
    //           // subtitle: Text("Hi"),
    //           trailing: Text("HI"),
    //           onTap: () {
    //             // navigate to conversation detail page
    //           },
    //         );
    //       },
    //     ),
    //   );
    // }));
  }

  Widget iconText(Icon iconWidget, Text textWidget) {
    return Row(
      children: [iconWidget, SizedBox(width: 5), textWidget],
    );
  }

  openCreateNoteDialog(TextEditingController textController) {
    return Get.defaultDialog(
      title: "Create Note",
      content: Column(
        children: [
          TextField(
            controller: textController,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: kPrimaryColor))),
            maxLines: 10,
            maxLength: 200,
            keyboardType: TextInputType.multiline,
          )
        ],
      ),
      textConfirm: "Save",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        widget.leadController.createNote(_lead.id, textController.text);
        Get.back();
      },
      onCancel: () {},
    );
  }

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
  //         // assignedByDDL(),
  //         AssignedToDialog(leadController: widget.leadController),
  //         SizedBox(height: 10),
  //       ],
  //     ),
  //     textConfirm: "Add",
  //     confirmTextColor: Colors.white,
  //     onConfirm: () async {
  //       widget.leadController.addFollowUp(_lead.id, txtFollowUpName.text,
  //           txtDescription.text, txtDateTime.text);
  //       Get.back();
  //     },
  //     onCancel: () {},
  //   );
  // }

  // String _selectedItem = 'Select AssignedTo';

  // assignedByDDL() {
  //   var items = widget.leadController.assignedTo.value
  //       .map<DropdownMenuItem<String>>((user) {
  //     return DropdownMenuItem<String>(
  //       value: "${user.firstName} ${user.lastName}",
  //       child: Text("${user.firstName} ${user.lastName}"),
  //     );
  //   }).toList();

  //   // Add 'Select AssignedTo' item to the list
  //   items.insert(
  //       0,
  //       DropdownMenuItem<String>(
  //         value: 'Select AssignedTo',
  //         child: Text('Select AssignedTo'),
  //       ));

  //   return DropdownButton<String>(
  //     value: _selectedItem,
  //     icon: Icon(Icons.arrow_downward),
  //     iconSize: 24,
  //     elevation: 16,
  //     style: TextStyle(color: Colors.deepPurple),
  //     underline: Container(
  //       height: 2,
  //       color: Colors.deepPurpleAccent,
  //     ),
  //     onChanged: (String? newValue) {
  //       if (newValue != null && newValue != 'Select AssignedTo') {
  //         setState(() {
  //           _selectedItem = newValue;
  //           widget.leadController.taskModel.assignedTo =
  //               widget.leadController.assignedTo.value.firstWhere(
  //                   (user) => "${user.firstName} ${user.lastName}" == newValue);
  //         });
  //       }
  //     },
  //     items: items,
  //   );
  // }

  String _selectedItem = 'Select AssignedTo';

  assignedByDDL() {
    //Task Cahnges
    // return CustomSearchableDropDown(
    //   initialValue: [widget.leadController.assignedTo.value[0]],
    //   items: widget.leadController.assignedTo.value,
    //   label: "$_selectedItem",
    //   initialIndex: 0,
    //   decoration: BoxDecoration(
    //       color: Colors.white,
    //       borderRadius: BorderRadius.circular(15),
    //       border: Border.all()),
    //   prefixIcon: Padding(
    //     padding: const EdgeInsets.all(0.0),
    //     child: Icon(Icons.search),
    //   ),
    //   dropDownMenuItems: widget.leadController.assignedTo.value.map((user) {
    //     print("namecheck${user.firstName} ${user.lastName}");
    //     return "${user.firstName} ${user.lastName}";
    //   }).toList(),
    //   onChanged: (user) {
    //     if (user != null) {
    //       widget.leadController.taskModel.assignedTo = user;
    //       print("${user.firstName} ${user.lastName}");
    //       setState(() {
    //         _selectedItem = "${user.firstName} ${user.lastName}";
    //       });
    //     } else {
    //       widget.leadController.taskModel.assignedTo = null;
    //       setState(() {
    //         _selectedItem = 'Select AssignedTo';
    //       });
    //     }
    //   },
    // );
  }

  var assignedTags;
  void openAssignTagsDialog(BuildContext context) async {
    widget.leadController.selectedAssignTags.value.clear();
    await showDialog(
      context: context,
      builder: (ctx) {
        return FutureBuilder(
          future: widget.leadController.getAssignTags(_lead.id!),
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
                items: widget.leadController.tags
                    .map((e) => MultiSelectItem(e, e.name!))
                    .toList(),
                initialValue: widget.leadController.selectedAssignTags.value,
                onConfirm: (List<Tag> values) {
                  print("Values length = ${values.length}");
                  widget.leadController.selectedAssignTags.value.clear();
                  print(
                      "selectedAssignTags length = ${widget.leadController.selectedAssignTags.value.length}");
                  widget.leadController.selectedAssignTags.addAll(values);
                  print(
                      "=> selectedAssignTags length = ${widget.leadController.selectedAssignTags.value.length}");
                  assignedTags = values;
                  addTags(_lead.id, assignedTags);
                  widget.leadController.loadData(forcedReload: true);
                },
              ),
            );
          },
        );
      },
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    try {
      hexColor = hexColor.toUpperCase().replaceAll("#", "");
      if (hexColor.length == 6) {
        hexColor = "FF" + hexColor;
      }
      return int.parse(hexColor, radix: 16);
    } catch (ex) {
      print("Error Tags color code is String - $hexColor");
      return int.parse("FFF44336", radix: 16); //Default Color Red
    }
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

Future<void> addTags(leadid, List<Tag> assignedTags) async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  List<Map<String, dynamic>> tagsData = assignedTags.map((tag) {
    return {
      "status": "OK",
      "messages": [],
      "id": tag.id,
      "name": tag.name,
      "type": "lead",
      "clientGroupId": "",
      "color": tag.color,
      "description": tag.description,
      "isLeadTag": null,
      "createdOn": "",
    };
  }).toList();

  // Create the request data
  Map<String, dynamic> requestData = {"tags": tagsData};
  final response = await NetworkHelper().request(
      RequestType.put,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/tag/$leadid'),
      requestBody: jsonEncode(requestData));

  if (response != null && response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load data');
  }
}
class AssignedToDropdown extends StatefulWidget {
  final User? initalvalue;
  final void Function(dynamic selectedUser) onItemSelected;

  const AssignedToDropdown({super.key, this.initalvalue, required this.onItemSelected});

  @override
  State<AssignedToDropdown> createState() => _AssignedToDropdownState();
}

class _AssignedToDropdownState extends State<AssignedToDropdown> {
  LeadController leadcontroller=Get.find<LeadController>();

  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    List<User>  users =[];
if (leadcontroller.assignedTo.value != null && leadcontroller.assignedTo.value.isNotEmpty) {
  // If assignedTo value is not null and not empty, use it
    users = leadcontroller.assignedTo.value;
} else {
  // Otherwise, fetch users from SnapPeNetworks
  users= await SnapPeNetworks().fetchUsers();
}
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CircularProgressIndicator() // Show loader until users are fetched
        : Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 3),
            child: DropDownTextField(
              clearOption: false,
              textFieldDecoration: overallborderstyle("Assign To", null, null),
              initialValue: getFullName(widget.initalvalue),
        // Set initial value from the passed User
              dropDownList: _users.map((user) {
                return DropDownValueModel(
                  value: user,
                  name: getFullName(user)??"",
                );
              }).toList(),
              onChanged: (selectedUser) {
                widget.onItemSelected(selectedUser.value);
              },
            ),
          );
  }
}
String? getFullName(User? user) {
  if (user == null) {
    return null;
  }

  String firstName = user.firstName ?? "";
  String lastName = user.lastName ?? "";

  if (firstName.isEmpty && lastName.isEmpty) {
    return null;
  }

  return "$firstName $lastName".trim();
}

void openWhatsApp(String text) async {
  var whatsappUrl = "whatsapp://send?text=$text";
  if (await canLaunch(whatsappUrl)) {
    await launch(whatsappUrl);
  } else {
    // Handle the case when WhatsApp is not installed
    Fluttertoast.showToast(msg: "install whatsapp to send the Message");
  }
}

Future<void> btnWhatsapp(String number) async {
  const String phoneNumber =
      "1234567890"; // Replace with the desired phone number

  // final AndroidIntent intent = AndroidIntent(
  //   action: 'action_view',

  //   package: 'com.whatsapp', // Package name for WhatsApp Business
  //   flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
  // );

  // await intent.launch();

  var url = NetworkConstants.getWhatsappUrl(
      "${number}".removeAllWhitespace.replaceAll("+", ""));
  if (await canLaunch(url)) {
    await launch(url, enableJavaScript: true, enableDomStorage: true);
  }
}

pressCallButton(String mobilenumber) async {
  var url = "tel:+${mobilenumber != null ? mobilenumber : ""}";
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

List<Widget> buildTagsbydto(tagsDto) {
  List<Widget> tagsList = [];

  if (tagsDto != null && tagsDto!.tags!.length != 0) {
    int len = tagsDto!.tags!.length;
    for (int i = 0; i < len; i++) {
      tagsList.add(
        Container(
            child: Chip(
          label: Text(
            "${tagsDto!.tags![i].name ?? ""}",
            style: TextStyle(color: Colors.white, fontSize: kSmallFontSize),
          ),
          backgroundColor: tagsDto?.tags![i].color == null
              ? Colors.grey
              : HexColor(tagsDto!.tags![i].color!),
        )),
      );
    }
  }

  // tagsList.add(popUpMenu(textController, txtFollowUpName, txtDescription, txtDateTime));

  return tagsList;
}
void openAssignTagsDialogWithCallback({
  required BuildContext context,
  required List<Tag>? initialTags, // Initial selected tags
  required Function(List<Tag> selectedTags) onTagsUpdated, // Callback when tags are updated
}) async {
  // Show dialog
  await showDialog(
    context: context,
    builder: (ctx) {
      return FutureBuilder<List<Tag>>(
        // Fetch all available tags and convert them into List<Tag>
        future: SnapPeNetworks().getLeadTags().then((response) {
          List<dynamic> jsonResponse = jsonDecode(response??"")["tags"];
          return jsonResponse.map((data) =>Tag.fromJson(data)).toList();
        }),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator()); // Show a loading indicator until data is loaded
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading tags')); // Show error message in case of failure
          }

          // Once data is loaded, show the MultiSelectDialog
          return MultiSelectDialog<Tag>(
            searchable: true,
            separateSelectedItems: true,
            unselectedColor: Colors.grey.withOpacity(0.1),
            listType: MultiSelectListType.CHIP,
            items: snapshot.data!
                .map((tag) => MultiSelectItem<Tag>(tag, tag.name ?? ''))
                .toList(),

            // Set the initial values to the selected tags
            initialValue: initialTags??[],

            onConfirm: (List<Tag> selectedValues) {
              print("Selected Values: ${selectedValues.length}");

              // Callback with the updated tags
              onTagsUpdated(selectedValues);
            },
          );
        },
      );
    },
  );
}



//  void openAssignTagsDialog(Lead _lead,BuildContext context) async {
//   LeadController leadController=Get.find<LeadController>();
// leadController.selectedAssignTags.value.clear();
//   await showDialog(
//     context: context,
//     builder: (ctx) {
//       return FutureBuilder(
//         future: leadController.getAssignTags(_lead.id!),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Container();
//           }
//           return Obx(
//             () => MultiSelectDialog(
//               searchable: true,
//               separateSelectedItems: true,
//               unselectedColor: Colors.grey.withOpacity(0.1),
//               listType: MultiSelectListType.CHIP,
//               items: leadController.tags
//                   .map((e) => MultiSelectItem(e, e.name!))
//                   .toList(),
//               initialValue: leadController.selectedAssignTags.value,
//               onConfirm: (List<Tag> values) {
//                 print("Values length = ${values.length}");
//               leadController.selectedAssignTags.value.clear();
//                 print(
//                     "selectedAssignTags length = ${leadController.selectedAssignTags.value.length}");
//               leadController.selectedAssignTags.addAll(values);
//                 print(
//                     "=> selectedAssignTags length = ${leadController.selectedAssignTags.value.length}");
//                 assignedTags = values;
//                 addTags(_lead.id, assignedTags);
//               leadController.loadData(forcedReload: true);
//               },
//             ),
//           );
//         },
//       );
//     },
//   );
// }

void openFollowUpDialog(Lead _lead, BuildContext context) async {
  TextEditingController txteditingdate=TextEditingController();
  String txtFollowUpName =_lead.customerName!=null?"Follow up for Lead:${ _lead.customerName}":"" ;
  String txtDescription =_lead.mobileNumber!=null? 'Contact:${_lead.mobileNumber}':"";
  DateTime txtDateTime = DateTime.now();
  String liveAgentUserName = await SharedPrefsHelper().getMerchantName();
txteditingdate.text=DateFormat('dd-MM-yyyy, h:mm a').format(DateTime.now());
  LeadController leadController = Get.find<LeadController>();
  TextEditingController remindercontroller=TextEditingController();
User? assignedTo = _lead.assignedTo != null ? User.fromJson(_lead.assignedTo!.toJson()) : null;
var ischecked=false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Add Follow Up"),
        content: Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15, horizontal: 2),
                  child: TextFormField(
                    controller: txteditingdate,
                    readOnly: true,
                    decoration: overallborderstyle('Date and Time', null, null),
                    onTap: () async {
                      DateTime? pickedDateTime = await showOmniDateTimePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDateTime != null) {
                        txtDateTime = pickedDateTime;
                       txteditingdate.text=DateFormat('dd-MM-yyyy, h:mm a').format(pickedDateTime);
                       print(txteditingdate.text); 
                      }
                    },
                  ),
                ),
                SizedBox(height: 4),
                TextFormField(
                  initialValue: txtFollowUpName,
                  decoration: overallborderstyle('Follow Up Name', null, null),
                  onChanged: (value) {
                    txtFollowUpName = value;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  initialValue: txtDescription,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: kPrimaryColor),
                    ),
                  ),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  onChanged: (value) {
                    txtDescription = value;
                  },
                ),
                SizedBox(height: 5),
                AssignedToDropdown(
                  initalvalue: assignedTo,
                  onItemSelected: (value){
assignedTo=value;
                },),
                SizedBox(height: 5),
StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
            
              return Column(
                children: [
                  Row(
                    children: <Widget>[
                      Checkbox(
                        value: ischecked,
                        onChanged: (bool? value) {
                          setState(() {
                            ischecked = value ?? false;
                          });
                        },
                      ),
                      Text('Notify Customer'),
                  
                  
                    ],
                  ),

 ischecked? TextFormField(
                  controller: remindercontroller,
                  decoration: InputDecoration(
                    labelText: 'Reminder Text',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: kPrimaryColor),
                    ),
                  ),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  onChanged: (value) {
                    txtDescription = value;
                  },
                ):Container(),

                ],
              );
            },
          ),
        
                SizedBox(height: 5),
               
              ],
            ),
          ),
        ),
        actions: [ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: EdgeInsets.all(6.0),
                        ),
                        onPressed: () async {
                          print("${liveAgentUserName} id");
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "      Cancel      ",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      
                      
                       ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                            255, 23, 151, 255), // Background color
                        foregroundColor: Colors.white, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: EdgeInsets.all(6.0),
                      ),
                      onPressed: () async {
                        if (assignedTo != null) {

if( ischecked){

  if(remindercontroller.text!=''){   leadController.addFollowUp(_lead, txtFollowUpName,
                              txtDescription, txtDateTime, assignedTo!,context,notifycustomer: ischecked,remindertext: remindercontroller.text);
                              Get.back();
                              }
                              else{
                                 Fluttertoast.showToast(
msg: "You need to add a Reminder Text to Customer");
                              }
                         
}else{
                          leadController.addFollowUp(_lead, txtFollowUpName,
                              txtDescription, txtDateTime, assignedTo!,context,notifycustomer: ischecked);
                         Get.back();}
                        } else {
                          Fluttertoast.showToast(
                              msg: "Add a Assigned To Value");
                        }
                      },
                      child: Text("  Add Follow Up  ",
                          style: TextStyle(color: Colors.white)),
                    ),
                   
                      
                      
                      ],
      );
    },
  );
}

actionMenuItems(Lead _lead,BuildContext context,{bool conversationPrivillage=true,bool calllogsPrivillage=true}){
  LeadController leadController=Get.find<LeadController>();
  
return  SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                   calllogsPrivillage? IconButton(
                                       iconSize: 19,
                                        onPressed: () {
                                         Get.to(()=>CallLogsScreen(
                                                      leadId: _lead.id,
                                                      leadController: leadController,
                                                      onBack: () {}));
                                        },
                                        icon: Image.asset(
                                          'assets/icon/telephone2.png',width: 37,height: 37,
                                        )):Container(),
                                  IconButton(
                                    iconSize: 19,
                                      icon: Image.asset("assets/icon/send.png",width: 28,height: 28,),
                                      color: Colors.blue,
                                      onPressed: () {
                                        Get.to(
                                          QuickResponsePage(_lead.customerName,
                                             _lead.mobileNumber,
                                              onBack: (){},
                                              leadController:
                                                  leadController),
                                        );
                                      }),
                                  IconButton(
                                      onPressed: () {
                                        
  
                                        // openCreateNoteDialog(textController);
  
                                        Get.to(LeadNotesScreen(
                                            leadId: _lead.id,
                                            leadController: leadController,
                                            onBack: (){}));
                                      },
                                      icon: Image.asset("assets/icon/note.png",height: 28,width: 28),
                                      color: Colors.blue),



                                    //    IconButton(
                                    // iconSize: 19,
                                    //   icon: Image.asset("assets/icon/task.png",width: 28,height: 28,),
                                    //   color: Colors.blue,
                                    //   onPressed: () {
                                    //  Get.to(TasksByLead(lead: _lead));
                                    //   }),



                                  IconButton(
                                      onPressed: () {
                                      
  
                                        openFollowUpDialog(
                                          _lead,context);
                                      },
                                      icon: Image.asset("assets/icon/follow-up.png",height: 28,width: 28),
                                      color: Colors.blue),
                                  IconButton(
                                      onPressed: () async {
                                        if (await Permission.phone
                                            .request()
                                            .isGranted) {
                                          // Permission was granted
  
                                          pressCallButton(
                                              _lead.mobileNumber ?? "");
  
                                      
                                        } else {
                                          // Permission was denied
  
                                          Get.defaultDialog (
                                           title: "Permission required",
                                            content: AlertDialog(
                                           
                                              content: Text(
                                                  "This app needs access to call logs to function properly."),
                                              actions: [
                                                TextButton(
                                                  child: Text("Grant permission"),
                                                  onPressed: () async {
                                                  
                                                    openAppSettings();
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text("Cancel"),
                                                  onPressed: () =>
                                                      Get.back()
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                      icon: Image.asset("assets/icon/telephone.png",height: 28,width: 28,),
                                      color: Colors.blue),
                                  IconButton(
                                    color: Colors.blue,
                                      onPressed: () {
                                      
  
                                        btnWhatsapp(_lead.mobileNumber ?? "");
                                      },
                                      icon: Image.asset("assets/icon/whatsappIcon.png",height: 28,width: 28,)),
                             conversationPrivillage?     IconButton(
                                      onPressed: () async{

                                        if(_lead.mobileNumber!=null || _lead.mobileNumber==''){



          Get.to(() =>Indetailchatscreen(chatinfo: ChatList(customerNo: _lead.mobileNumber??'', businessNo: null, customerName: null, lastTs: DateTime.now().microsecondsSinceEpoch, multiTenantContext: null, previewMessage: null, status: null, messageCount: 0)));
  //                                       final chatModel =
  //                                           ChatController.newRequestList?.firstWhereOrNull(
  //                                         (chat) =>
  //                                             chat.customerNo ==
  //                                             _lead.mobileNumber,
  //                                       );
  //                                       Get.back();
  //  var k= await SharedPrefsHelper().getFristappName()??"";
  //                                       if (chatModel != null) {
                                        
  //                                         Get.to(ChatDetailsScreen(
  //                                           firstAppName:k,
  //                                           chatModel: chatModel,
  //                                           isOther: false,
  //                                           leadController: leadController,
  //                                           isFromLeadsScreen: true,
  //                                         ));
  //                                       } else {
  //                                         ChatModel newChatModel = ChatModel(
  //                                           id: Id(
  //                                               customerNo: _lead.mobileNumber),
  //                                           businessNo: "",
  //                                           customerName: _lead.customerName,
  //                                           customerNo: _lead.mobileNumber,
  //                                           lastTs: DateTime.now()
  //                                               .toUtc()
  //                                               .toIso8601String(),
  //                                           messages: [],
  //                                           multiTenantContext: 'context',
  //                                           overrideStatus:
  //                                               OverrideStatus(agentOverride: 1),
  //                                         );
  //                                         print(
  //                                             "${DateTime.now().toUtc().toIso8601String()} is lastTs");
  //                                         Get.to(ChatDetailsScreen(
  //                                           firstAppName: k,
  //                                           chatModel: newChatModel,
  //                                           isOther: false,
  //                                           leadController: leadController,
  //                                           isFromLeadsScreen: true,
  //                                         ));
  //                                       }
                                        
                                        }else{

                                        Fluttertoast.showToast(msg: "The Number is Not there to open the ChatScreen");
                                        }
                                      },
                                      icon: Image.asset("assets/icon/chat.png",height: 28,width: 28,),
                                      color: Colors.blue):Container(),
  
  
                                       Tooltip(
                                        message: "Create quotation",
                                         child: IconButton(
                                          color: Colors.blue,
                                                                               onPressed: () {
                                          if(Get.context!=null){
                                             CustomerConvertor().showComplaintDialog(
                                                           Get.context!,
                                                           _lead.pincode,
                                                           _lead.mobileNumber,
                                                           _lead.customerName,
                                                           _lead.email,
                                                           _lead.organizationName,
                                                           _lead.id.toString(),
                                                         );
                                                 }         },
                                                                               icon: Image.asset("assets/icon/quotation.png",height: 30,width: 30,)),
                                       ),
  
                                       IconButton(
                                      onPressed: () async{
                                        if(_lead.mobileNumber!=null &&_lead.mobileNumber!=""){
                                      await triggerBot(_lead.id ?? 0);}else{
                                        Fluttertoast.showToast(msg: "There is no Mobile Number to trigger the Bot");
                                      }
                                      },
                                      icon:Image.asset("assets/icon/robot.png",height: 28,width: 28,)),
                               
                               
                               IconButton(onPressed: ()async{
  if(_lead.mobileNumber!=null &&_lead.mobileNumber!=""){
Get.to(()=>oppr. AddOpportunityScreen(editedData: {
  'leadid':_lead.id,
  "mobileNumber":_lead.mobileNumber,
  "customerName":_lead.customerName
  
},));}
else{
Fluttertoast.showToast(msg: "Can Not Create Opportunitie without Mobile Number");

}
        }, icon: Icon(Icons.call_split))
                                ],
                              ),
);


}


String? decodeText(String? unreadableText) {
  try {
    if(unreadableText!=null){
    return utf8.decode(unreadableText.runes.toList());}else{
      return unreadableText;
    }
  } catch (e) {
    return unreadableText;
  }
}


String? validateString(String? input) {
  if (input != null && input.isNotEmpty) {
    return input;
  }
  return null;
}
class CopyAlertDialog extends StatelessWidget {
  final String data;

  CopyAlertDialog({required this.data});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Copy to Clipboard'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(data),
          SizedBox(height: 20),
     
        ],
      ),
      actions: [
             ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: data));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Copied to Clipboard!')),
              );
            },
            child: Text('Copy'),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }
}