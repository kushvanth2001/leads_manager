import 'dart:convert';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:leads_manager/domainvariables.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:leads_manager/models/model_Merchants.dart';
import 'package:leads_manager/models/model_leadDetails.dart';
import 'package:leads_manager/models/model_taskpage.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';


class TaskDetailsPage extends StatefulWidget {
  final Task task;
  final bool isNewTask;

  const TaskDetailsPage({super.key, required this.task, required this.isNewTask});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late Task _task;
List<TaskType> tasktypes=[];
List<User> _users=[];
List<TaskStatus> _taskStatuses = [];
List<PriorityId> priorites=[];
TextEditingController starttimecontroller=TextEditingController();
TextEditingController endtimecontroller=TextEditingController();
 final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
bool  isLoading=true;
  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _task.startTime==null?_task.startTime=DateTime.now().toIso8601String():null;
       _task.endTime==null?_task.endTime=DateTime.now().toIso8601String():null;
starttimecontroller.text='${DateFormat('dd-MMM-yyyy').format(DateTime.parse( _task.startTime!))}, ${DateFormat('h:mma').format(DateTime.parse( _task.startTime!)).toLowerCase()}'; 
endtimecontroller.text='${DateFormat('dd-MMM-yyyy').format(DateTime.parse( _task.endTime!))}, ${DateFormat('h:mma').format(DateTime.parse( _task.endTime!)).toLowerCase()}';
  SnapPeNetworks(). fetchTaskTypes().then((result) {
     setState(() {
       tasktypes=result;
     });
    })
    .catchError((error) {
      // This block is executed if the Future completes with an error.
      // 'error' is the exception or error thrown.
    });
      SnapPeNetworks(). fetchPriorities().then((result) {
     setState(() {
       priorites=result;
       
     });
    })
    .catchError((error) {
      // This block is executed if the Future completes with an error.
      // 'error' is the exception or error thrown.
    });
    SnapPeNetworks().fetchTaskStatuses().then((taskStatuses) {
      if (mounted) {
        setState(() {
          _taskStatuses = taskStatuses;
        });
      }
    });
    SnapPeNetworks().  fetchUsers().then((users) {
      if (mounted) {
        setState(() {
          _users = users;
        });
      }
    });
  }
  Future<void> addTask(Task task) async {
  
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    final response = await NetworkHelper().request(
      RequestType.post,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/task'),
      requestBody: jsonEncode(task.toJson()),
    );

    if (response?.statusCode == 200) {
      print('Task added successfully');
    } else {
      print('Failed to add task');
    }
  }
    Future<void> editTask(Task task,String id) async {
  
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    final response = await NetworkHelper().request(
      RequestType.put,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/task/$id'),
      requestBody: jsonEncode(task.toJson()),
    );

    if (response?.statusCode == 200) {
      print('Task added successfully');
    } else {
      print('Failed to add task');
    }
  }
  
    Future<void> _pickDateTime(TextEditingController controller,bool isstart) async {
    DateTime? pickedDateTime = await showOmniDateTimePicker(
      context: context,
      initialDate: isstart?DateTime.parse(_task.startTime!):DateTime.parse( _task.endTime!),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDateTime != null) {
      setState(() {
      
        controller.text ='${DateFormat('dd-MMM-yyyy').format(pickedDateTime)}, ${DateFormat('h:mma').format(pickedDateTime).toLowerCase()}'; 
        isstart?_task.startTime=pickedDateTime.toIso8601String():_task.endTime=pickedDateTime.toIso8601String();

        if(!isstart){
          _task.lastTime=DateFormat('HH:mm:ss').format(pickedDateTime);
        }
          print(controller.text);
        print(_task.endTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Task Details'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
             Container(
  margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
  child: TextFormField(
    initialValue: _task.name,
    decoration: overallborderstyle("Enter Name", null, null),
    onChanged: (value) {
      setState(() {
        _task.name = value;
      });
    },
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: (value) {
      print(value);
      print(_task.name);
      if (value == null || value.isEmpty || value == "") {
        print("in above returning the value");
        return 'Please enter a name';
      }
      print("in above null the value");
      return null;
    },
  ),
),

          
             !tasktypes.isEmpty? Container(
                 margin: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
                child: DropDownTextField(
                   clearOption: false,
                  initialValue:widget.isNewTask? "Task":_task.tasktype?.name,
                  textFieldDecoration: overallborderstyle("Task Type",null,null),
                  dropDownList:  tasktypes.map((types) {
                                      return DropDownValueModel(
                                        value: types,
                                        name: types.name??"",
                                      );}).toList(),
                    
                  
                  onChanged: (value) {
                    setState(() {
                      _task.tasktype = value.value;
                    });
                  },
                ),
              ):Container(),
              Container(
                 margin: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 10),
                child: TextFormField(
                  initialValue: _task.description,
                  decoration:overallborderstyle("Description",null,null),
                  maxLines: 3,
                  onChanged: (value) {
                    setState(() {
                      _task.description = value;
                    });
                  },
                ),
              ),
             !_users.isEmpty?  Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 10),
                                  child: DropDownTextField(
                                  
                                    clearOption: false,
                                    textFieldDecoration:
                                        overallborderstyle("Assign To", null, null),
                                    initialValue:_task.assignedTo?.firstName,
                                    
                                    dropDownList: _users.map((user) {
                                      return DropDownValueModel(
                                        value: user,
                                        name: user.firstName ?? "",
                                      );
                                    }).toList(),
                                    onChanged: (selectedUserId) {
                                  _task.assignedTo =
                                          
                                              selectedUserId.value;
                                    
                                    },
                                  ),
                                ):Container(),
             !_taskStatuses.isEmpty? Container(
                  margin: EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 10),
                child: DropDownTextField(
                   clearOption: false,
                  initialValue: _task.taskstatus?.name,
                  textFieldDecoration:  overallborderstyle("Status", null, null),
                  dropDownList:_taskStatuses.map((status) {
                                        return DropDownValueModel(
                                          value: status,
                                          name: status.name??"",
                                        );}).toList(),
                      
                  onChanged: (value) {
                    setState(() {
                      _task.taskstatus = value.value;
                    });
                  },
                ),
              ):Container(),
            ! priorites.isEmpty ?Container(
                  margin: EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 10),
                child: DropDownTextField(
                   clearOption: false,
                  initialValue: _task.priorityId?.name,
                  textFieldDecoration:   overallborderstyle("Priority", null, null),
                  dropDownList:priorites.map((status) {
                                        return DropDownValueModel(
                                          value: status,
                                          name: status.name??"",
                                        );}).toList(),
                  onChanged: (value) {
                    setState(() {
                      _task.priorityId= value.value;
                    });
                  },
                ),
              ):Container(),
                Container(
                    margin: EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 10),
                  child: TextFormField(
                    controller: starttimecontroller,
                    readOnly: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: (value) {
      print("in validator of end date");
      DateTime startDate = DateTime.parse(_task.startTime ?? "");
      DateTime endDate = DateTime.parse(_task.endTime ?? "");
      if (startDate.isAfter(endDate)) {
        return 'End Date must be after Start Date';
      }
      return null;
    },
                    decoration: overallborderstyle( 'Start Date',null,null),
                    onTap: () async {
                      
                                    await _pickDateTime(starttimecontroller,true );
                    },
                  ),
                ),
             Container(
  margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
  child: TextFormField(
    readOnly: true,
    controller: endtimecontroller,
    decoration: overallborderstyle('End Date', null, null),
    onTap: () async {
      await _pickDateTime(endtimecontroller, false);
    },
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: (value) {
      print("in validator of end date");
      DateTime startDate = DateTime.parse(_task.startTime ?? "");
      DateTime endDate = DateTime.parse(_task.endTime ?? "");
      if (startDate.isAfter(endDate)) {
        return 'End Date must be after Start Date';
      }
      return null;
    },
  ),
),
                
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async{
                if(_task.name==null|| _task.name==''){
                  Fluttertoast.showToast(msg: "Name is Need to Create the Task");
                }else if(DateTime.parse(_task.startTime ?? "").isAfter(DateTime.parse(_task.endTime ?? ""))){
  Fluttertoast.showToast(msg: "End Date must Be Greater than the Start Date");
                }
                
                
                else{
                        
           widget.isNewTask?await  addTask(_task):await editTask(_task, _task.id??"0");
             Get.back();
          
                }
                        
                      
                },
                child: Text(widget.isNewTask? 'Save Task':"Edit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

  overallborderstyle(hinttext, IconData? prefixIcon, IconData? suffixIcon) {
    return InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        focusColor: Colors.purple,
        hintStyle: TextStyle(color: Colors.black45),
        border: OutlineInputBorder(gapPadding: 10
            // Adjust the value as needed
            ),
        label: Text(hinttext),
        hintText: hinttext,
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: Colors.blue.shade200,
              )
            : null,
        suffixIcon: suffixIcon != null
            ? Icon(
                suffixIcon,
                color: Colors.blue,
              )
            : null);
  }