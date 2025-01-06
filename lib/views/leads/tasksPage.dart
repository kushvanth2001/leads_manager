
import 'dart:convert';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:leads_manager/constants/styleConstants.dart';
import 'package:leads_manager/domainvariables.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:leads_manager/models/model_Merchants.dart';
import 'package:leads_manager/models/model_Users.dart';
import 'package:leads_manager/models/model_taskpage.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/utils/snapPeUI.dart';
import 'package:leads_manager/views/leads/taskDetails.dart';
import 'package:leads_manager/views/leads/tasksbyLead.dart';


class TasksPage extends StatefulWidget {
  const TasksPage({Key? key}) : super(key: key);

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  DateTime selectedDate = DateTime.now();
  List<Widget> cards = [];
  List<Task> _tasks = [];
  List<dynamic> _selectedDates = [];
  TextEditingController _textcontroller = TextEditingController();
  DateTime? startTime = DateTime.now().subtract(Duration(days: 7));
  DateTime? endtime = DateTime.now().add(Duration(days: 7));
  List<TaskStatus> _taskStatuses = [];
  List<User> users = [];
  String selectedAssignedto = "";
  String selectedAssignedby = '';
  String selectedStatus='';


  @override
  void initState() {
    super.initState();
    // fetchTasks();

   SnapPeNetworks(). fetchTaskStatuses().then((taskStatuses) {
      if (mounted) {
        setState(() {
          _taskStatuses = taskStatuses;
        });
      }
    });

    fetchAllTasks();
    _textcontroller.text =
        "${DateFormat('MMMM d, y').format(startTime!)} - ${DateFormat('MMMM d, y').format(endtime!)}";
    setdata();
  }

  setdata() async {
    var s = await SnapPeNetworks().getUsers();
    if (s != null) {
      setState(() {
        print(usersModelFromJson(s).users);
        users = usersModelFromJson(s).users ?? [];
      });
      print("userrrrr");
    } else {
      print("siszero");
    }
  }

  Future<void> fetchAllTasks() async {
    try {
      String clientGroupName =
          await SharedPrefsHelper().getClientGroupName() ?? "";
      String userId = await SharedPrefsHelper().getMerchantUserId();

      final response = await NetworkHelper().request(RequestType.get,
          Uri.parse(getUrl(startTime, endtime, clientGroupName)),
          requestBody: "");
      print(selectedDate.millisecondsSinceEpoch ~/ 1000);
      if (response != null && response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> tasksList = jsonResponse["tasks"];

        final List<Task> tasks =
            tasksList.map((json) => Task.fromJson(json)).toList();
        print(". $tasks .");
        setState(() {
          _tasks = tasks;
        });

        setState(() {});
      } else {
        print('Failed to load tasks');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: SnapPeUI().appBarText("Tasks", kBigFontSize),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskDetailsPage(task: Task(), isNewTask: true)),
              ).then((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TasksPage()),
                );
              });
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),

          InkWell(
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: TextFormField(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.calendar_month_outlined,
                      color: Colors.blue,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4.0))),
                    fillColor: Colors.grey.shade300,
                    filled: true),
                controller: _textcontroller,
                enabled: false,
              ),
            ),
           onTap: () async {
  var k = await showCalendarDatePicker2Dialog(
    context: context,
    config: CalendarDatePicker2WithActionButtonsConfig(
      calendarType: CalendarDatePicker2Type.range,
      currentDate: DateTime.now(),
    ),
    dialogSize: const Size(325, 400),
    value: [DateTime.now(), DateTime(2050)],
    borderRadius: BorderRadius.circular(15),
  );

  if (k != null && k.isNotEmpty) {
    DateTime? startDate = k[0];
    DateTime? endDate = k.length == 2 ? k[1] : null;

    if (startDate != null) {
      // If the end date is the same as the start date, set endTime to 23:59
      if (endDate != null && startDate == endDate) {
        endDate = startDate.add(Duration(hours: 23, minutes: 59));
      }

      setState(() {
        startTime = startDate;
        endtime = endDate;
      });

      // Format the displayed text
      _textcontroller.text = endDate == null
          ? DateFormat('MMMM d, y').format(startTime!)
          : "${DateFormat('MMMM d, y').format(startTime!)} - ${DateFormat('MMMM d, y').format(endtime!)}";

      print("Selected Start: ${startTime?.toIso8601String()}");
      print("Selected End: ${endtime?.toIso8601String()}");
    }
  }

  // Fetch tasks based on the selected date range
  await fetchAllTasks();
  print(k);
},
          ),
//
          users.length != 0
              ? Container(
                padding: EdgeInsets.all(8),
                height: 60,
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                  child: Row(
                                
                    children: [
                      Center(
                          child: Text(
                        "Assigned To: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      )),
                      SizedBox(
                        width: 200,
                        child: DropDownTextField(
                          
                            initialValue: 'All',
                            clearOption: false,
                            textFieldDecoration: overallborderstyle(null, null, null),
                            onChanged: (k) {
                              selectedAssignedto = k.value;
                              fetchAllTasks();
                            },
                            dropDownList: [
                              ...users
                                  .map((e) => DropDownValueModel(
                                      value: e.id != null
                                          ? e?.userId.toString()
                                          : "",
                                      name: e?.fullName ?? ""))
                                  .toList(),
                              DropDownValueModel(name: 'All', value: '')
                            ]),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(Icons.arrow_circle_right),
                      SizedBox(
                        width: 40,
                      ),
                      Center(
                          child: Text(
                        "Assigned By: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      )),
                      SizedBox(
                        width: 200,
                        child: DropDownTextField(
                            initialValue: 'All',
                            clearOption: false,
                            textFieldDecoration: overallborderstyle(null, null, null),
                            onChanged: (k) {
                              selectedAssignedby = k.value;
                              fetchAllTasks();
                            },
                            dropDownList: [
                              ...users
                                  .map((e) => DropDownValueModel(
                                      value: e.id != null
                                          ? e.userId.toString()
                                          : "",
                                      name: e.fullName ?? ""))
                                  .toList(),
                              DropDownValueModel(name: 'All', value: '')
                            ]),
                      ),
                                
                       Icon(Icons.arrow_circle_right),
                      SizedBox(
                        width: 40,
                      ),
                      Center(
                          child: Text(
                        "Status: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      )),
                      SizedBox(
                        width: 200,
                        child: 
                        
                        DropDownTextField(
                            initialValue: 'All',
                            clearOption: false,
                            textFieldDecoration: overallborderstyle(null, null, null),
                            onChanged: (k) {
                              setState(() {
                                        selectedStatus= k.value.toString();
                              fetchAllTasks();
                              });
                                
                      
                            },
                            dropDownList: [
                              ...  _taskStatuses
                                  .map((e) => DropDownValueModel(
                                      value: e.name != null
                                          ? e.name.toString().toLowerCase()
                                          : "",
                                      name: e.name ?? ""))
                                  .toList(),
                              DropDownValueModel(name: 'All', value: '')
                            ]),
                      ),
                    ],
                  ),
                ),
              )
              : Container(),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Divider(color: Colors.grey, height: 1.0, thickness: 1)),
          Expanded(
            child: _tasks.isEmpty
                ? SnapPeUI().noDataFoundImage2(msg: "You have no Tasks !!")
              

                : 
          ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Slidable(
                            startActionPane: ActionPane(
                              motion: ScrollMotion(),
                              children: <Widget>[
                                SlidableAction(
                                  onPressed: (context) async {
                                Get.to(TaskDetailsPage(task: task,isNewTask: false,))?.then((value) async{
              // Perform operation after coming back to this page
             await fetchAllTasks();
            });
                                  },
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                
                                  label: "Edit"
                                ),
                              ],
                            ),
                            endActionPane: ActionPane(
                              motion: ScrollMotion(),
                              children: <Widget>[
                                SlidableAction(
                                  onPressed: (context) async{
                                    int id=int.tryParse(task.id??'0')??0;
                                  await SnapPeNetworks(). deleteTask(id);
                                 fetchAllTasks(); 
                                  },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                              ],
                            ),
                            
                            child: 
                
                
                
                Taskcard(task: task));
              },
            ),
          
      )],
      ),
    );
  }
    String getUrl(
      DateTime? startdate, DateTime? enddate, String clientGroupName) {
    String startMicroseconds = startdate != null
        ? (startdate.millisecondsSinceEpoch ~/ 1000)
            .toString() // Using integer division to convert milliseconds to seconds
        : '';

    String endMicroseconds = enddate != null
        ? (enddate.millisecondsSinceEpoch ~/ 1000)
            .toString() // Using integer division to convert milliseconds to seconds
        : (startdate!.add(Duration(hours: 20)).millisecondsSinceEpoch ~/ 1000)
            .toString(); // Default end time if enddate is null

    return "https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/task-filter?endFrom=$startMicroseconds&endTo=$endMicroseconds&page=0&size=2000&sortBy=createdOn&sortOrder=DESC" +
        '${selectedAssignedby == "" ? "" : "&assignedBy=${int.tryParse(selectedAssignedby)}"}' +
        '${selectedAssignedto == "" ? "" : "&assignedTo=${int.tryParse(selectedAssignedto)}"}'+
        
         '${selectedStatus == "" ? "" : "&status=${selectedStatus}"}'
        ; //  "https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/task-filter?createdOnFrom=$startMicroseconds&createdOnTo=$endMicroseconds&page=0&size=20&sortBy=createdOn&sortOrder=DESC";
  }
}



// String getStatusName(List<TaskStatus> dataList, int id) {
//   for (var item in dataList) {
//     if (item.id == id) {
//       return item.name; // Assuming 'status' is the key for the status name
//     }
//   }
//   return 'Status not found';
// }

// // Function to get ID by status name
// int getIdByStatus(List<TaskStatus> dataList, String status) {
//   for (var item in dataList) {
//     if (item.name == status) {
//       // Assuming 'status' is the key for the status name
//       return item.id;
//     }
//   }
//   return -1; // Return -1 if status not found
// }

// Future<Map<String, dynamic>> fetchTaskById(String taskId) async {
//   final String clientGroupName =
//       await SharedPrefsHelper().getClientGroupName() ?? "";

//   try {
//     final response = await NetworkHelper().request(
//       RequestType.get, // Use PUT request for updating
//       Uri.parse(
//           'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/task/$taskId'), // Assuming task id is used in the URL for updating
//     );

//     if (response!.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       return data;
//     } else {
//       print('Failed to fetch task. Status code: ${response.statusCode}');
//       return {};
//     }
//   } catch (e) {
//     print('Error fetching task: $e');
//     return {};
//   }
// }

// Future<void> editTask(Map<String, dynamic> s, String id) async {
//   try {
//     String clientGroupName =
//         await SharedPrefsHelper().getClientGroupName() ?? "";
//     final response = await NetworkHelper().request(
//         RequestType.put, // Use PUT request for updating
//         Uri.parse(
//             'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/task/$id'), // Assuming task id is used in the URL for updating
//         requestBody: jsonEncode(s));
//     print(s);
//     if (true) {
//       print('Task updated successfully');
//     } else {
//       print('Failed to update task');
//     }
//   } catch (e) {
//     print('Exception occurred while editing task: $e');
//   }
// }
  overallborderstyle(String? hinttext, IconData? prefixIcon, IconData? suffixIcon) {
    return InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        focusColor: Colors.purple,
        hintStyle: TextStyle(color: Colors.black45),
        border: OutlineInputBorder(gapPadding: 10
            // Adjust the value as needed
            ),
        label:hinttext!=null? Text(hinttext):null,
        hintText: hinttext!=null? hinttext:null,
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