import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart'; // Assuming you're using GetX for state management
import 'package:leads_manager/constants/styleConstants.dart';
import 'package:leads_manager/models/model_lead.dart';
import 'package:leads_manager/models/model_taskpage.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/views/leads/leadDetails/leadDetails.dart';
import 'package:leads_manager/views/leads/leadsWidget.dart';
import 'package:leads_manager/views/leads/taskDetails.dart';
import 'package:permission_handler/permission_handler.dart';

class TasksByLead extends StatefulWidget {
  final Lead lead;

  const TasksByLead({Key? key, required this.lead}) : super(key: key);

  @override
  _TasksByLeadState createState() => _TasksByLeadState();
}

class _TasksByLeadState extends State<TasksByLead> with SingleTickerProviderStateMixin {
  late Future<List<Task>?> _tasksFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Two tabs: Tasks and Follow-up
    _tabController.addListener(_handleTabChange);
    _tasksFuture = _fetchTasksByLead(widget.lead.id ?? 0); // Default to fetching regular tasks
  }

  void _handleTabChange() {
    if (_tabController.index == 0) {
      // Tab index 0 is for regular tasks
      setState(() {
        _tasksFuture = _fetchTasksByLead(widget.lead.id ?? 0);
      });
    } else if (_tabController.index == 1) {
      // Tab index 1 is for follow-up tasks
      setState(() {
        _tasksFuture = _fetchFollowTasksByLead(widget.lead.id ?? 0);
      });
    }
  }

  Future<List<Task>?> _fetchTasksByLead(int leadId) async {
    try {
      return await SnapPeNetworks().getTaskByLead(leadId: leadId);
    } catch (e) {
      return null;
    }
  }

  Future<List<Task>?> _fetchFollowTasksByLead(int leadId) async {
    try {
      return await SnapPeNetworks().getfollowuptasksforLead(leadId.toString());
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks for Lead ${widget.lead.customerName ?? widget.lead.mobileNumber ?? ""}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Tasks'),
            Tab(text: 'Follow-up'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTasksTab(),
          _buildFollowUpTab(),
        ],
      ),
    );
  }

  Widget _buildTasksTab() {
    return _buildTaskList();
  }

  Widget _buildFollowUpTab() {
    return _buildTaskList();
  }

  Widget _buildTaskList() {
    return FutureBuilder<List<Task>?>( 
      future: _tasksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('An error occurred: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(child: Text('No tasks found.'));
        } else {
          List<Task> tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Slidable(
                startActionPane: ActionPane(
                  motion: ScrollMotion(),
                  children: <Widget>[
                    SlidableAction(
                      onPressed: (context) async {
                        Get.to(TaskDetailsPage(task: task, isNewTask: false));
                      },
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      label: "Edit",
                    ),
                  ],
                ),
                endActionPane: ActionPane(
                  motion: ScrollMotion(),
                  children: <Widget>[
                    SlidableAction(
                      onPressed: (context) async {
                        // Delete functionality
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: Taskcard(task: task),
              );
            },
          );
        }
      },
    );
  }
}



class Taskcard extends StatelessWidget {
  Task task;
   Taskcard({super.key,required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8,right: 8,top: 3),
      child: Card(
        elevation: 4,
        child: InkWell(
            onTap: ()async{
              print("tasskkid${task.leadId} ");
           Lead lead  =await SnapPeNetworks().getSingleLead(task.leadId.toString());
              (task.leadId!=null&&task.leadId!="") ?Get.to(()=>LeadDetails(lead:lead, isNewLead: false)):Fluttertoast.showToast(msg: "This Task dosent Associated With any Lead");
              
            },
          child: ListTile(
            
            tileColor:getStatusColor(task.taskstatus?.name?.toString() .toLowerCase()??''),
            title:
          
          Tooltip(
            message:"${ validateString(task.name)  ?? "-"}" ,
            child: Wrap(
                          children: [
                            Text(
                              "${ validateString(task.name)  ?? "-"}",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: kMediumFontSize,
                            
                              ),
                            ),
                          
                            Text("")
                          ],
                        ),
          ),
          
                
                subtitle:   Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Tooltip(
                              message:"${ validateString(task.description)  ?? "-"}", 
                              child: Wrap(
                              children: [
                                Text(
                                  "${ validateString(task.description)  ?? "-"}",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: kMediumFontSize,
                                    color: Colors.grey
                                  ),
                                ),
                              
                                Text("")
                              ],
                            ),
                    ),
                task.taskstatus?.name!=null? Text("${task.taskstatus?.name}"):Container(),
           task.customerMobileNumber!=null?   Text("${task.customerMobileNumber}"):Container(),
                 task.endTime !=null?   Text("${task.endTime!.split("T")[0]}"):Container(),

  task.customerMobileNumber!=null&&  task.customerMobileNumber!='' && task.customerMobileNumber!.length !=1? IconButton(
                                      onPressed: () async {
                                        if (await Permission.phone
                                            .request()
                                            .isGranted) {
                                          // Permission was granted
  
                                          pressCallButton(
                                      task.customerMobileNumber ?? "");
  
                                      
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
                                      color: Colors.blue):Container(),


                  ],
                ),
                
                
                
               
                isThreeLine: true,
                
                trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        
                          task.assignedBy != null?
                              Text(
                                "${ validateString( task.assignedBy?.firstName) ?? "-"} ${validateString( task.assignedBy?.lastName) ?? "-"}",
                                overflow: TextOverflow.ellipsis,
                              ):Text("-"),
                            Icon(Icons.arrow_downward,
                                size: 10, color: Colors.blue),
                          task.assignedTo != null?                          Text(
                                 "${ validateString( task.assignedTo?.firstName) ?? "-"} ${validateString( task.assignedTo?.lastName) ?? "-"}",
                                overflow: TextOverflow.ellipsis,
                              ):Text("-")
                          ],
                        ),
                ),
        ),),
    );
  }
}

Color getStatusColor(String status) {
   switch (status.toLowerCase()) { 
    case 'resolved': return Colors.green.shade200; 
    case 'completed':return Colors.green.shade200;
    case 'in progress': return Colors.yellow.shade200; 
    case 'cancelled': return Colors.red.shade200;
    case 'created': return Colors.blue.shade200; 
    case 'paused': return Colors.orange.shade200; 
    default: return Colors.white;
     } }