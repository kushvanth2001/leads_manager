import 'dart:convert';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:leads_manager/models/model_tag.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/views/leads/FavrioteLeadCourosel.dart';
import 'package:leads_manager/views/leads/leadfilter.dart';
import 'package:leads_manager/views/leads/mybacklogs.dart';
import 'package:leads_manager/views/opportunity/opportunityscreen.dart';
import 'package:leads_manager/widgets/leadaccceptcontainer.dart';
import 'package:leads_manager/widgets/leadcard.dart';
import 'package:leads_manager/widgets/newdatetimepicker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:leads_manager/widgets/easyloadingwidget.dart';


import 'package:shared_preferences/shared_preferences.dart';
import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:leads_manager/Controller/chat_controller.dart';
import 'package:leads_manager/Controller/leads_controller.dart';
import 'package:leads_manager/constants/colorsConstants.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:leads_manager/utils/snapPeUI.dart';
import 'package:leads_manager/views/leads/leadDetails/leadDetails.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:leads_manager/views/leads/tasksPage.dart';
import '../../constants/styleConstants.dart';
import '../../domainvariables.dart';
import '../../models/model_LeadStatus.dart';
import '../../models/model_Merchants.dart';
import '../../models/model_Users.dart';
import '../../models/model_lead.dart';
import 'leadsWidget.dart';
import 'dart:async';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class LeadScreen extends StatefulWidget {
  final GlobalKey<LeadScreenState>? key;
  final String? firstAppName;

  LeadScreen({this.key, this.firstAppName});

  @override
  LeadScreenState createState() => LeadScreenState();
}

class LeadScreenState extends State<LeadScreen> with WidgetsBindingObserver {
  final LeadController leadController = Get.find<LeadController>();

  final TextEditingController textEditingController = TextEditingController();
   Timer? _debounce; 
  bool _isLoading = false;
  String? userId;
  
bool isjumping=false;
  String? liveAgentUserName;
  Future<void>? _loadingFuture;
  // List<String> sources = [
  //   "Email",
  //   "WhatsApp",
  //   "Facebook",
  //   "Google",
  //   "Network",
  //   "Referral",
  //   "Paid Campaign",
  //   "Pamphlets",
  //   "Newspaper",
  //   "Affilates",
  //   "Others"
  // ];
  List<String> sources = [];

  Future<void> reloadData() async {
    liveAgentUserName = await SharedPrefsHelper().getMerchantName();
    userId = await SharedPrefsHelper().getMerchantUserId();
    await leadController.loadData(forcedReload: true);
    String clientName = await SharedPrefsHelper().getClientName() ?? "";
    print("$clientName from leadsscreen");
  }

  @override
  void initState() {
    super.initState();
    reloadData();
 
    print("inside leadsscreen initstate");
    WidgetsBinding.instance!.addObserver(this);
    //   leadController.scrollController.addListener(() {
    // // Check if the previous scroll offset is less than the current scroll offset
    // setState(() {

    // });
//   if (leadController.scrollController.position.userScrollDirection == ScrollDirection.reverse) {
//     // User is scrolling down
//     setState(() {
//         isscrollingup=false;
//     });

//     print('Scrolling down');
//   } else {
//     setState(() {
//       isscrollingup=true;
//     });
//     print('Scrolling up');
//   }
// });sea
  }

  @override
  void dispose() {
    textEditingController.dispose();
    
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
 
  void _onSearchChanged(String value) async{
       if (_debounce?.isActive ?? false) _debounce?.cancel();

    // Set a new timer for 500 milliseconds
    _debounce = Timer(const Duration(milliseconds: 500), () async{
        
           if (value == "") {
             leadController.leadModel.value=LeadModel();
             leadController.currentPage=0;
             leadController.nameormobilenumber="";
      leadController.loadData(forcedReload: true);
    } else {
      leadController.leadModel.value=LeadModel();
      leadController.currentPage=0;
    leadController.nameormobilenumber=value;
     await leadController.getFilteredLeads(page: 0);
    }
        });
  
    // if (_debounce?.isActive ?? false) _debounce?.cancel();
    // _debounce = Timer(const Duration(milliseconds: 500), () {
    // if (value == "") {
    //   leadController.loadData(forcedReload: true);
    // } else {
    //   leadController.getFilteredLeads(nameOrMobile: value,page: 0);
    // }
    // });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Set _isLoading to true when the app is resumed
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      // Start a timer that will set _isLoading to false after 3 seconds
      Timer(Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
      if (textEditingController.text.isNotEmpty) {
        _onSearchChanged(textEditingController.text);
      } else {
        //@leadscroll
        //  reloadData();
      }
    }
  }

  bool _showNoLeadsMessage = false;
  _leads() {
    final leads = leadController.leadModel.value.leads;
    print("$leads from _leads leadsscreen");

    if (leadController.leadModel.value.leads == null ||
        leadController.leadModel.value.leads!.length == 0) {
      if (!_showNoLeadsMessage) {
        Future.delayed(Duration(seconds: 15), () {
          if (mounted) {
            setState(() {
              _showNoLeadsMessage = true;
            });
          }
        });
        return SnapPeUI().loading();
      } else {
        return FutureBuilder(
    future: Future.delayed(Duration(seconds: 3)),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container();
      } else {
        return SnapPeUI().noDataFoundImage();
      }
    },
  );
      }
    } else {
      print("${leadController.leadModel.value.leads}");
      bool isNewleadF = false;
      return Obx(() => Expanded(
              child: Column(children: [
            Expanded(
              child: Stack(

                children: [
                
                  ListView.builder(
                      controller: leadController.scrollController,
                      shrinkWrap: true,
                      itemCount:
                          leadController.leadModel.value.leads == null
                              ? 0
                              : leadController
                                  .leadModel.value.leads!.length,
                      itemBuilder: (context, index) {
                        var customer = leadController
                            .leadModel.value.leads![index].customer;
                        int? customerId = customer != null
                            ? customer['customerId']
                            : null;
                              
                        return Slidable(
                            startActionPane: ActionPane(
                              motion: ScrollMotion(),
                              children: <Widget>[
                                SlidableAction(
                                  onPressed: (context) async {
                                    final prefs =
                                        await SharedPreferences
                                            .getInstance();
                                    List<String>? phoneNumbers = prefs
                                        .getStringList('phoneNumbers');
                                    print(
                                        'Phone numbers in local storage: $phoneNumbers');
                                    if (customerId != null) {
                                      print("stratus is $customerId 1");
                                      return;
                                    } else {
                                      print("stratus is $customerId");
                                      String? mobileNumber =
                                          leadController
                                              .leadModel
                                              .value
                                              .leads![index]
                                              .mobileNumber;
                                      String? name = leadController
                                          .leadModel
                                          .value
                                          .leads![index]
                                          .customerName;
                                      String? email = leadController
                                          .leadModel
                                          .value
                                          .leads![index]
                                          .email;
                                      String? organizationName =
                                          leadController
                                              .leadModel
                                              .value
                                              .leads![index]
                                              .organizationName;
                                      String? leadId = leadController
                                          .leadModel
                                          .value
                                          .leads![index]
                                          .id
                                          .toString();
                              
                                      showComplaintDialog(
                                          context,
                                          mobileNumber,
                                          name,
                                          email,
                                          organizationName,
                                          leadId);
                                    }
                                  },
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                
                                  label: customerId != null
                                      ? "ALREADY A\n CUSTOMER"
                                      : 'CONVERT TO\n CUSTOMER',
                                ),
                              ],
                            ),
                            endActionPane: ActionPane(
                              motion: ScrollMotion(),
                              children: <Widget>[
                                SlidableAction(
                                  onPressed: (context) async{
                                   bool candelete=await SharedPrefsHelper().getcanDeleteLeadPrivillage();
                                   if(candelete){
                                    int? leadID = leadController
                                        .leadModel
                                        .value
                                        .leads![index]
                                        .id;
                                    // Your delete function goes here
                                    //https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/DivigoIndia/leads/9885378
                                  await  deleteLead(leadID);
                                   for (int i = 0;i < leadController.leadModel.value.leads!.length;
                  i++) {
                print(i);
        
                if (leadController.leadModel.value.leads![i].id ==
                   leadController
                            .leadModel.value.leads![index].id ) {
                  
                  print("lead found");
                  try {
                  leadController.leadModel.value.leads!.removeAt(index);
                  
                    //print( LeadController().leadModel.value.leads![i].leadStatus!.toJson());
                    //  print("lead json ${k.toJson()} 2");
                  } catch (e) {
                    print("<<$e");
                  }
                }


                  }
                  leadController.leadModel.value=LeadModel();
                  leadController.currentPage=0;
                                await   leadController.loadData(forcedReload: true);
                                                                    }else{

                                                                      Fluttertoast.showToast(msg: "Please enable the privilege to delete the Lead.");
                                                                    }
                                                                    
                                                                                                      },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                              ],
                            ),
                            
                            child: LeadWidget(
                                index: index,
                                onBack: () {
                                  if (textEditingController
                                          .text.isEmpty ||
                                      textEditingController.text ==
                                          "") {
                                    //@leadscroll
                                    //  leadController.loadData(forcedReload: true);
                                  } else {
                                    leadController.getFilteredLeads(
                                      );
                                  }
                                },
                                liveAgentUserName: liveAgentUserName,
                                lead: leadController
                                    .leadModel.value.leads![index],
                                leadController: leadController,
                                isNewleadd: isNewleadF,
                                
                                firstAppName: widget.firstAppName,
                                chatModels:
                                    ChatController.newRequestList
                                // assignedTo: assignedTo,
                                ));
                      }),
              
              
              leadController.ondargstart.value?  Positioned(
                    
                    bottom: 0,
                    child: FlameContainer(

                onAccept: (lead) {
                  print('Lead accepted: ${lead.id
                  }');
                },
              ),):Container()
                ],
              ),
            )
          ])));
    }
  }

  _buildBody(context) {
    print("reloadin");
    bool isNewleadT = true;
    return RefreshIndicator(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(1, 0, 1, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
          ClipRRect(
           borderRadius: BorderRadius.only(
      bottomRight: Radius.circular(12),
      bottomLeft: Radius.circular(12),
    ),
              child: ExpansionTile(
                
                collapsedBackgroundColor:Colors.blue.shade400 ,
                backgroundColor: Colors.blue.shade200,
                
                title: CupertinoSearchTextField(
                    controller: textEditingController,
                    placeholder: "Search Leads by Name or Mobile Number",
                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  
                  ),
                    style: TextStyle(fontSize: kMediumFontSize),
                  onSubmitted: (value)async{
                       if (value == "") {
             leadController.leadModel.value=LeadModel();
             leadController.currentPage=0;
             leadController.nameormobilenumber="";
      leadController.loadData(forcedReload: true);
    } else {
      leadController.leadModel.value=LeadModel();
      leadController.currentPage=0;
    leadController.nameormobilenumber=value;
     await leadController.getFilteredLeads(page: 0);
    }
                  },
                    onSuffixTap: () {
                       leadController.leadModel.value=LeadModel();
             leadController.currentPage=0;
             leadController.nameormobilenumber="";
      leadController.loadData(forcedReload: true);
      textEditingController.clear();
                    },
                
                    // onChanged: (value) {},
                    ),

                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [   TextButton.icon(
                                                icon: Icon(
                            Icons.access_alarm,
                            color: Colors.white,
                                                ),
                                                label: Text(
                            "Tasks",
                            style: TextStyle(color: Colors.white),
                                                ),
                                                onPressed: () {
                            //openFilterDelegate(context);
                                          
                                                Get.to( TasksPage());
                             
                                                }),
                                            TextButton.icon(
                                                icon: Icon(
                            Icons.filter_list,
                            color: Colors.white,
                                                ),
                                                label: Text(
                            "Filters",
                            style: TextStyle(color: Colors.white),
                                                ),
                                                onPressed: () {
                                  showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    
                                    insetPadding: EdgeInsets.all(10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: 
                                    PopScope(
                                         onPopInvokedWithResult:(isdone,value) {
                              if (isdone) {
                                  // User explicitly navigated back (e.g., using hardware back button)
                                  // Handle any cleanup or other logic here if needed.
                                } else {
                                  // User didn't navigate back directly; show the toast message.
                                  Fluttertoast.showToast(
                                    msg: "Please choose either 'Apply' or 'Clear' filters.",
                                  );
                                }
                                },
                                      canPop: false,
                                      child: Container(
                                        height: MediaQuery.of(context).size.height*0.9,
                                        child: FilterScreen()),
                                    ),
                                  );
                                },
                              );                  //openFilterDelegate(context);
                                                    
                                                }),
                                            TextButton.icon(
                                                icon: Icon(
                            Icons.add,
                            color: Colors.white,
                                                ),
                                                label: Text(
                            "Add Lead",
                            style: TextStyle(color: Colors.white),
                                                ),
                                                onPressed: () {
                            Get.to(LeadDetails(lead:Lead() , isNewLead:true));
                                                }),
                                                      
                                                     
 TextButton.icon(
                                                icon: Icon(
                            Icons.assignment_late,
                            color: Colors.white,
                                                ),
                                                label: Text(
                            "My BackLogs",
                            style: TextStyle(color: Colors.white),
                                                ),
                                                onPressed: () {
                                                Get.to(()=> MyBackLogs());
                                                }),

                                                    TextButton.icon(
                                                icon: Icon(
                            Icons.call_split,
                            color: Colors.white,
                                                ),
                                                label: Text(
                            "Opportunities",
                            style: TextStyle(color: Colors.white),
                                                ),
                                                onPressed: () {
                                                Get.to(()=> OpportunityListScreen());
                                                }),

                                                       TextButton.icon(
                                                icon: Icon(
                            Icons.favorite,
                            color: Colors.white,
                                                ),
                                                label: Text(
                            "Favourites",
                            style: TextStyle(color: Colors.white),
                                                ),
                                                onPressed: () {
                                                    showCupertinoModalPopup(context: context, builder:
                                              (context) => FavoriteLeadCarousel());
                                                }),
                                                
                                                     
                                                
                                             
                                             
                                             
                                                ],),
                          ),
                                              buildChipset()
                                             //buildChipset()
                        ],
                      )
                    


                    ],
              ),
            ),
           
            SizedBox(height: 5),
            Obx(() => _leads())
          ],
        ),
      ),
      onRefresh: () {
        print('load method is called');
        return Future.delayed(
          Duration(seconds: 1),
          () {
            leadController.leadModel.value=LeadModel();
leadController.currentPage=0;
            leadController.loadData(forcedReload: true);
          },
        );
      },
    );
  }

  void showComplaintDialog(BuildContext context, String? mobileNumber,
      String? name, String? email, String? organizationName, String? leadId) {
    TextEditingController textMobileNumber =
        TextEditingController(text: mobileNumber);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text("Add as Customer"), // Add your dialog title here
          content: Container(
            height: 150, // Adjust as needed
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: textMobileNumber,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: kPrimaryColor),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                               backgroundColor: Colors.red,
                              
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: EdgeInsets.all(12.0),
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop();
                          },
                          child: Text("      Cancel      ",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                               backgroundColor: Colors.blue,
                              
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: EdgeInsets.all(12.0),
                          ),
                          onPressed: () async {
                            await checkConsumer(context, mobileNumber, name,
                                email, organizationName, leadId);
                            // refreshCallback();
                            Navigator.of(context).pop();
                          },
                          child: Text("    Check    ",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showCustomerDialog(BuildContext context, String? mobileNumber,
      String? name, String? email, String? organizationName, String? leadID) {
    String? leadid = leadID;
    TextEditingController textMobileNumber =
        TextEditingController(text: mobileNumber);
    TextEditingController textName = TextEditingController(text: name);
    TextEditingController textEmail = TextEditingController(text: email);
    TextEditingController textOrganizationName =
        TextEditingController(text: organizationName);
    TextEditingController textPincode = TextEditingController(text: "");
    TextEditingController textCustomerRole = TextEditingController(text: "");
    TextEditingController textAffiliateStatus = TextEditingController(text: "");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text("Details"), // Add your dialog title here
          content: Container(
            height: 500, // Adjust as needed
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: textName,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: kPrimaryColor),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: textMobileNumber,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: kPrimaryColor),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: textOrganizationName,
                    decoration: InputDecoration(
                      labelText: 'Company Name',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: kPrimaryColor),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: textCustomerRole,
                    decoration: InputDecoration(
                      labelText: 'Customer Role',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: kPrimaryColor),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: textEmail,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: kPrimaryColor),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    // controller: textMobileNumber,
                    decoration: InputDecoration(
                      labelText: 'PAN Number',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: kPrimaryColor),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                               backgroundColor: Colors.red,
                               
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: EdgeInsets.all(12.0),
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop();
                          },
                          child: Text("      Cancel      ",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      Center(
                        child: ElevatedButton(

                          style: ElevatedButton.styleFrom(
                               backgroundColor: Colors.blue,
                           
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: EdgeInsets.all(12.0),
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await addCustomer(
                                leadid,
                                textName,
                                textMobileNumber,
                                textOrganizationName,
                                textPincode,
                                textCustomerRole,
                                textAffiliateStatus);
                            await reloadData();
                            // refreshCallback();
                          },
                          child: Text("    ADD    ",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> checkConsumer(
      BuildContext context,
      String? mobileNumber,
      String? name,
      String? email,
      String? organizationName,
      String? leadId) async {
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    print("mobinum : $mobileNumber");
    print("111111");
    try {
      print("222222");
      final response = await NetworkHelper().request(
        RequestType.get,
        Uri.parse(
            'https://${Globals.DomainPointer}/snappe-services/rest/v1/consumers/consumer?phoneNo=$mobileNumber&merchantName=$clientGroupName'),
        requestBody: "",
      );
      if (response != null) {
        print("333333");
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
        if (response.statusCode == 200) {
          print("its true");
          return true;
        } else if (response.statusCode == 404) {
          print("its false");
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            // The reason WidgetsBinding.instance?.addPostFrameCallback((_) {...}); helped is because it schedules a callback to be called after the current frame has been dispatched.
            showCustomerDialog(
                context, mobileNumber, name, email, organizationName, leadId);
          });
          return false;
        } else {
          print('Failed to load consumer data');
          throw Exception('Failed to load consumer data');
        }
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw e;
    }
    return false;
  }

  Future<void> addCustomer(
      String? leadId,
      TextEditingController textName,
      TextEditingController textMobileNumber,
      TextEditingController textOrganizationName,
      TextEditingController textPincode,
      TextEditingController textCustomerRole,
      TextEditingController textAffiliateStatus) async {
    try {
      String clientGroupName =
          await SharedPrefsHelper().getClientGroupName() ?? "";
      // Define the request body
      var requestBody = jsonEncode({
        "status": "OK",
        "firstName": "${textName.text}",
        "middleName": null,
        "lastName": "",
        "gstNo": null,
        "countryCode": "+91",
        "userName": null,
        "password": null,
        "phoneNo": "91${textMobileNumber.text}",
        "community": ".",
        "relativeLocation": null,
        "alternativeNo1": null,
        "primaryEmailAddress": "",
        "alternativeEmailAddress": null,
        "latitude": null,
        "longitude": null,
        "mapLocation": null,
        "houseNo": null,
        "pincode": "${textPincode.text}.",
        "city": null,
        "addressLine1": null,
        "addressLine2": null,
        "addressType": "Home",
        "mobileNumber": "+91${textMobileNumber.text}",
        "applicationNo": "91${textMobileNumber.text}",
        "token": null,
        "userId": null,
        "isValid": false,
        "isExtendable": false,
        "guid": null,
        "organizationName": "${textOrganizationName.text}",
        "isBilling": true,
        "isShipping": true,
        "tagsDTO": {"tags": []},
        "isNoteAvailable": false,
        "customColumns": [],
        "leadId": null,
        "block": null,
        "flat": null,
        "gstNumber": null,
        "panNo": null,
        "pan": null,
        "panFile": null,
        "gstFile": null,
        "isCopyNotes": true,
        "roleId": 1,
        "affiliateStatus": "Approved",
        "Community": null,
        "affilatedStatus": {"label": "Approved", "value": "Approved"},
        "role": "customer"
      });

      final response = await NetworkHelper().request(
        RequestType.post,
        Uri.parse(
            'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/lead-customer?clientLeadId=$leadId'),
        requestBody: requestBody,
      );
      if (response != null && response.statusCode == 200) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
        // Handle the response as needed
      } else {
        print('Failed to add customer');
        throw Exception('Failed to add customer');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<LeadScreenState> leadScreenKey =
        GlobalKey<LeadScreenState>();
    return Obx(()=>  Scaffold(
           floatingActionButton: LeadController.disableopquicty.value==0? FloatingActionButton(onPressed: ()async{
      setState(() {
        isjumping=true;
            
                
      });
       Future.delayed(Duration(milliseconds: 1 ), () { 

         leadController.scrollController.jumpTo(0);
       });
          
           setState(() {
              isjumping=false;
           });
    
           },child:isjumping? Center(child: CircularProgressIndicator(color: Colors.black,strokeWidth: 4,),):Icon(Icons.arrow_circle_up),):null,
      
      
      // List<dynamic> callogs= await fetchcallogs(0,1 );
      // List<dynamic> calledleads=callogs.map((e) {return  Lead.fromJson( e["lead"]); },).toList();
      // print("gg");
      // showDialog(
      //   useSafeArea: true,
      //   context: context,
      //   builder: (BuildContext context) {
      //           return AlertDialog(
      //             insetPadding: EdgeInsets.all(10),
      //       title: Text('Recent Leads From CallLogs'),
      //             content: Container(
      //               height: MediaQuery.of(context).size.height*0.2,
      //               width: MediaQuery.of(context).size.width*0.9,
      //               child: ListView.builder(
      //                                             shrinkWrap: true,
      //                                   itemCount:
      //                                       calledleads == null
      //                                           ? 0
      //                                           : calledleads.length,
      //                                   itemBuilder: (context, index) {
      //                                     var customer = calledleads[index].customer;
      //                                     int? customerId = customer != null
      //                                         ? customer['customerId']
      //                                         : null;
      //                       try{
      //                                     return  Slidable(
      //                                         startActionPane: ActionPane(
      //                                           motion: ScrollMotion(),
      //                                           children: <Widget>[
      //                                             SlidableAction(
      //                                               onPressed: (context) async {
      //                                                 final prefs =
      //                                                     await SharedPreferences
      //                                                         .getInstance();
      //                                                 List<String>? phoneNumbers = prefs
      //                                                     .getStringList('phoneNumbers');
      //                                                 print(
      //                                                     'Phone numbers in local storage: $phoneNumbers');
      //                                                 if (customerId != null) {
      //                                                   print("stratus is $customerId 1");
      //                                                   return;
      //                                                 } else {
      //                                                   print("stratus is $customerId");
      //                                                   String? mobileNumber =
      //                                                      calledleads[index]
      //                                                           .mobileNumber;
      //                                                   String? name = calledleads[index]
      //                                                       .customerName;
      //                                                   String? email = calledleads[index]
      //                                                       .email;
      //                                                   String? organizationName =
      //                                                     calledleads[index]
      //                                                           .organizationName;
      //                                                   String? leadId = calledleads[index]
      //                                                       .id
      //                                                       .toString();
                        
      //                                                   showComplaintDialog(
      //                                                       context,
      //                                                       mobileNumber,
      //                                                       name,
      //                                                       email,
      //                                                       organizationName,
      //                                                       leadId);
      //                                                 }
      //                                               },
      //                                               backgroundColor: Colors.green,
      //                                               foregroundColor: Colors.white,
      //                                               icon: Icons.arrow_forward_rounded,
      //                                               label: customerId != null
      //                                                   ? "ALREADY A\n CUSTOMER"
      //                                                   : 'CONVERT TO\n CUSTOMER',
      //                                             ),
      //                                           ],
      //                                         ),
      //                                         endActionPane: ActionPane(
      //                                           motion: ScrollMotion(),
      //                                           children: <Widget>[
      //                                             SlidableAction(
      //                                               onPressed: (context) async{
      //                                                 int? leadID = calledleads[index]
      //                                                     .id;
      //                                                 // Your delete function goes here
      //                                                 //https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/DivigoIndia/leads/9885378
      //                                               await  deleteLead(leadID);
      //                                              await   leadController.loadData(forcedReload: true);
      //                                               },
      //                                               backgroundColor: Colors.red,
      //                                               foregroundColor: Colors.white,
      //                                               icon: Icons.delete,
      //                                               label: 'Delete',
      //                                             ),
      //                                           ],
      //                                         ),
      //                                         child: LeadWidget(
      //                                           reducewidth: true,
      //                                             index: index,
      //                                             onBack: () {
      //                                               if (textEditingController
      //                                                       .text.isEmpty ||
      //                                                   textEditingController.text ==
      //                                                       "") {
      //                                                 //@leadscroll
      //                                                 //  leadController.loadData(forcedReload: true);
      //                                               } else {
      //                                                 leadController.getFilteredLeads(
                                                
      //                                                       );
      //                                               }
      //                                             },
      //                                             liveAgentUserName: liveAgentUserName,
      //                                             lead: calledleads[index],
      //                                             leadController: leadController,
      //                                             isNewleadd: false,
                                              
      //                                             firstAppName: widget.firstAppName,
      //                                             chatModels:
      //                                                 ChatController.newRequestList
      //                                             // assignedTo: assignedTo,
      //                                             ));}catch(e){
      //                                               print(e);
      //                                               return Text("Some Data is missing in the Lead");
      //                                             }
      //                                   }),
      //             ),
      //           );
      //         },
        
      //       );
      
        // },child:DragTarget<Lead>(
        
        // builder: (context, candidateData, rejectedData) {
        //   return  Image.asset("assets/images/conversation.png",width: 30,height: 30,);}
      
        body: _buildBody(context),
      ),
    );
  }

  featureKeyDDL() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Obx(
        () => CustomSearchableDropDown(
          items: leadController.featureKeys.value,
          label: 'Select filter',
          initialIndex: leadController.featureKeys
              .indexOf(leadController.selectedFeatureKey.value),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all()),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Icon(Icons.search),
          ),
          dropDownMenuItems: leadController.featureKeys.value.map((columnName) {
            return columnName;
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              leadController.selectedFeatureKey.value = value;
            } else {
              leadController.selectedFeatureKey.value = "";
            }
          },
        ),
      ),
    );
  }

  featureValueDDL() {
    //["Tags","AssignedTo","Organization Name","Email","Status","Source"]
    return Padding(
      padding: EdgeInsets.all(8),
      child: Obx(() => Column(
            children: [
              Visibility(
                  maintainState: true,
                  visible: leadController.selectedFeatureKey.value == "Tags",
                  child: tagsDDL()),
              Visibility(
                  maintainState: true,
                  visible:
                      leadController.selectedFeatureKey.value == "AssignedTo",
                  child: assignedToDDL()),
              Visibility(
                  maintainState: true,
                  visible: leadController.selectedFeatureKey.value == "Status",
                  child: statusDDL()),
              Visibility(
                  maintainState: true,
                  visible:
                      leadController.selectedFeatureKey.value == "AssignedBy",
                  child: assignedByDDL()),
              Visibility(
                  maintainState: true,
                  visible: leadController.selectedFeatureKey.value == "Source",
                  child: sourceDDL()),
              Visibility(
                  maintainState: true,
                  visible: leadController.selectedFeatureKey.value == "Date",
                  child: dateDDL()),
                   Visibility(
                  maintainState: true,
                  visible: leadController.selectedFeatureKey.value == "Period",
                  child: periodDDL()),
                          Visibility(
                  maintainState: true,
                  visible: leadController.selectedFeatureKey.value == "LastActivity",
                  child: LastModifiedDDL()),
            ],
          )),
    );
  }
Widget buildChipset() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Obx(() => Row(
      children: [


        SizedBox(
    height: 50, // Set a fixed height for the ListView
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemCount:  leadController.selectedAssignTags.value.length,
      itemBuilder: (context, index) {
        var item = leadController.selectedAssignTags.value[index];
        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Chip(
            avatar:   Container(
  width: 30,
  height: 30,
  decoration: BoxDecoration(
    color: Colors.brown,
    borderRadius: BorderRadius.circular(15), // This makes the container round
  ),
),
            label: Text(item.name .toString()),
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: Colors.blue),
            ),
            labelStyle: TextStyle(color: Colors.white),
            onDeleted: () {
             leadController.selectedAssignTags.value .removeAt(index);
              leadController.selectedAssignTags.refresh();  // Notify GetX about the change
              leadController.leadModel.value = LeadModel();
              leadController.currentPage = 0;
              leadController.loadData();
            },
          ),
        );
      },
    ),
  ),

        SizedBox(
    height: 50, // Set a fixed height for the ListView
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemCount:  leadController.selectedAssignedBy .value.length,
      itemBuilder: (context, index) {
        var item = leadController.selectedAssignedBy .value[index];
        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Chip(
            avatar:Image.asset("assets/icon/assignedby.png"),
            label: Text("${item.firstName }"),
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: Colors.blue),
            ),
            labelStyle: TextStyle(color: Colors.white),
            onDeleted: () {
             leadController.selectedAssignedBy .value .removeAt(index);
              leadController.selectedAssignedBy .refresh();  // Notify GetX about the change
              leadController.leadModel.value = LeadModel();
              leadController.currentPage = 0;
              leadController.loadData();
            },
          ),
        );
      },
    ),
  ),


       SizedBox(
    height: 50, // Set a fixed height for the ListView
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemCount:  leadController.selectedAssignedTo .value.length,
      itemBuilder: (context, index) {
        var item = leadController.selectedAssignedTo .value[index];
        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Chip(
            avatar:    Image.asset("assets/icon/assignedTo.jpg"),
            label: Text("${item.firstName }"),
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: Colors.blue),
            ),
            labelStyle: TextStyle(color: Colors.white),
            onDeleted: () {
             leadController.selectedAssignedTo .value .removeAt(index);
              leadController.selectedAssignedTo .refresh();  // Notify GetX about the change
              leadController.leadModel.value = LeadModel();
              leadController.currentPage = 0;
              leadController.loadData();
            },
          ),
        );
      },
    ),
  ),     SizedBox(
    height: 50, // Set a fixed height for the ListView
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemCount:  leadController.selectedSources .value.length,
      itemBuilder: (context, index) {
        var item = leadController.selectedSources .value[index];
        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Chip(

            label: Text("${item }"),
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: Colors.blue),
            ),
            labelStyle: TextStyle(color: Colors.white),
            onDeleted: () {
             leadController.selectedSources .value .removeAt(index);
              leadController.selectedSources .refresh();  // Notify GetX about the change
              leadController.leadModel.value = LeadModel();
              leadController.currentPage = 0;
              leadController.loadData();
            },
          ),
        );
      },
    ),
  ),
       SizedBox(
    height: 50, // Set a fixed height for the ListView
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemCount:  leadController.selectedLeadStatus .value.length,
      itemBuilder: (context, index) {
        var item = leadController.selectedLeadStatus .value[index];
        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Chip(
            label: Text("${item.statusName }"),
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: Colors.blue),
            ),
            labelStyle: TextStyle(color: Colors.white),
            onDeleted: () {
             leadController.selectedLeadStatus .value .removeAt(index);
              leadController.selectedLeadStatus .refresh();  // Notify GetX about the change
              leadController.leadModel.value = LeadModel();
              leadController.currentPage = 0;
              leadController.loadData();
            },
          ),
        );
      },
    ),
  ),
     
       leadController.selectedDates.value.isNotEmpty?   Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Chip(
            avatar: Icon(Icons.calendar_month),
            label: Text("${formatDates( leadController.selectedDates.value[0],leadController.selectedDates.value[1]) }"),
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: Colors.blue),
            ),
            labelStyle: TextStyle(color: Colors.white),
            onDeleted: () {
              leadController.selectedPeriod.value='all';
             leadController.selectedDates .value=[];
              leadController.selectedDates .refresh();  // Notify GetX about the change
              leadController.leadModel.value = LeadModel();
              leadController.currentPage = 0;
              leadController.loadData();
            },
          ),
        ):Container(),

 Padding(
   padding: const EdgeInsets.all(8.0),
   child: Chip(
    
              label: Text("${leadController.periodFilters.keys.firstWhere((key) => leadController.periodFilters[key] == leadController.selectedPeriod.value, orElse: () => "all")}"),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: BorderSide(color: Colors.blue),
              ),
              labelStyle: TextStyle(color: Colors.white),
            
            onDeleted: (){
     leadController.selectedPeriod.value="all";
       leadController.leadModel.value = LeadModel();
              leadController.currentPage = 0;
              leadController.loadData();

       Fluttertoast.showToast(msg: "Cant Remove Period Filter you Can only change it To all");
            },
            ),
 ),

          leadController.selectedLastmodifedFrom.value!=null? Chip(
            avatar: Image.asset("assets/icon/activity.png"),
            label: Text("${ formatDates( leadController.selectedLastmodifedFrom.value,leadController.selectedLastmodifedTo.value )}"),
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: Colors.blue),
            ),
            labelStyle: TextStyle(color: Colors.white),
           onDeleted: () {
             leadController.selectedLastmodifedFrom .value=null;
     leadController.selectedLastmodifedTo .value=null;
              leadController.leadModel.value = LeadModel();
              leadController.currentPage = 0;
              leadController.loadData();
            },
          ):Container(),

 Padding(
   padding: const EdgeInsets.all(8.0),
   child: Chip(
    
              label:Obx(()=> Text(capitalizeFirstLetter( 
                leadController.selectedSortFilter.value.contains('.')?    "${leadController.selectedSortFilter.value.split('.').first}-${leadController.selectedSortFilter.value.split('&').last.split('=').last}":
                 "${leadController.selectedSortFilter.value.split('&').first}-${leadController.selectedSortFilter.value.split('&').last.split('=').last}"))),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: BorderSide(color: Colors.blue),
              ),
              labelStyle: TextStyle(color: Colors.white),
            
            onDeleted: (){
     leadController.selectedSortFilter.value="lastModifiedTime&sortOrder=DESC";
       leadController.leadModel.value = LeadModel();
              leadController.currentPage = 0;
              leadController.loadData();

       Fluttertoast.showToast(msg: "Cant Remove Sort Filter you Can only change it To Default");
            },
            ),
 ),

      ],
    )),
  );
}



String formatDates(String? fromMillisStr, String? toMillisStr) {
  if (fromMillisStr == null && toMillisStr == null) {
    return 'Select date';
  }

  int? fromMillis = fromMillisStr != null ? int.tryParse(fromMillisStr) : null;
  int? toMillis = toMillisStr != null ? int.tryParse(toMillisStr) : null;

  DateFormat dateFormat = DateFormat('dd/MMM/yyyy');

  String fromDate = fromMillis != null
      ? dateFormat.format(DateTime.fromMillisecondsSinceEpoch(fromMillis*1000))
      : '';
  String toDate = toMillis != null
      ? dateFormat.format(DateTime.fromMillisecondsSinceEpoch(toMillis*1000))
      : '';

  if (fromDate.isNotEmpty && toDate.isNotEmpty) {
    return '$fromDate - $toDate';
  } else if (fromDate.isNotEmpty) {
    return fromDate;
  } else {
    return toDate;
  }}


  Widget dateDDL() {
    print("sdf ${leadController.selectedDates}");
    return Row(
      children: [
        ElevatedButton(
          child: Icon(Icons.calendar_today,),
          onPressed: () async {
            final DateTimeRange? picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(DateTime.now().year - 5),
              lastDate: DateTime(DateTime.now().year + 5),
            );

            if (picked != null) {
              setState(() {
                // Convert the dates to epoch values and store them in selectedDates
                leadController.selectedDates.clear();
                leadController.selectedDates.add(picked
                    .start.millisecondsSinceEpoch
                    .toString()
                    .substring(0, 10));
                leadController.selectedDates.add(picked
                    .end.millisecondsSinceEpoch
                    .toString()
                    .substring(0, 10));
              });
            }
          },
        ),
        if (leadController.selectedDates.isNotEmpty)
          Text(
            '${DateFormat('dd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(int.parse(leadController.selectedDates[0]) * 1000))} \n'
            '${DateFormat('dd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(int.parse(leadController.selectedDates[1]) * 1000))}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        if (leadController.selectedDates.isEmpty) Text("Select \n dates")
      ],
    );
  }

 
   Widget periodDDL() {
    print("sdf ${leadController.selectedPeriod}");
    return Container(
      height: 200,
      width: 300,
      child: ListView.builder(
        shrinkWrap: true,
            itemCount:leadController. periodFilters.length,
            itemBuilder: (context, index) {
              String key =leadController.  periodFilters.keys.elementAt(index);
              return 
       RadioListTile<String>(
                title: Text(key),
                value:leadController.  periodFilters.values.elementAt(index)!,
                groupValue: leadController.selectedPeriod.value,
                onChanged: (value) {
                leadController.selectedPeriod.value = value!;
            
                },
              );
            },
          ),
    );
    
  }

  Widget LastModifiedDDL() {
    TextEditingController textcontroller=TextEditingController();
    textcontroller.text=formatDates(leadController.selectedLastmodifedFrom.value, leadController.selectedLastmodifedTo.value);
    print("sdf ${leadController.selectedPeriod}");
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: TextFormField(
        controller:textcontroller ,
    
        readOnly: true,
        decoration: InputDecoration(
          hintText: "Select Date",
        label:Text( "Select Range"),
          suffixIcon:Icon( Icons.calendar_month),
          border: OutlineInputBorder()
        ),
        onTap: () async {
          List<DateTime?>? pickedDates = await showCalendarDatePicker2Dialog(
            dialogSize: Size(300, 400),
            context: context,
            config: CalendarDatePicker2WithActionButtonsConfig(
              calendarType: CalendarDatePicker2Type.range,
            ),
      
          );
          if (pickedDates != null) {
            List<DateTime> nonNullDates = pickedDates.whereType<DateTime>().toList();
     if (nonNullDates.isEmpty || nonNullDates==null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No dates selected. Please select at least one date.')),
      );
    } else if (nonNullDates.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Only one date selected: ${DateFormat('dd-MM-yyyy').format(nonNullDates.first)}')),
  
      );
        leadController.selectedLastmodifedFrom.value= (nonNullDates![0]!.millisecondsSinceEpoch~/ 1000).toString();
          leadController.selectedLastmodifedFrom.value= null;
            textcontroller.text=formatDates(leadController.selectedLastmodifedFrom.value, leadController.selectedLastmodifedTo.value);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Multiple dates selected: ${nonNullDates.map((date) => DateFormat('dd-MM-yyyy').format(date)).join(', ')}')),
        
      );
       leadController.selectedLastmodifedFrom.value= (nonNullDates![0]!.millisecondsSinceEpoch~/ 1000).toString();
              leadController.selectedLastmodifedTo.value= (nonNullDates![1]!.millisecondsSinceEpoch~/ 1000).toString();
                textcontroller.text=formatDates(leadController.selectedLastmodifedFrom.value, leadController.selectedLastmodifedTo.value);
    }
  
          }
        },
      ),
    );
    
 
    
  }




  // tagsDDL() {
  //   return CustomSearchableDropDown(
  //     items: leadController.tags.value,
  //     label: 'Select Tags',
  //     multiSelectTag: 'Tags',
  //     decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(15),
  //         border: Border.all()),
  //     multiSelect: true,
  //     prefixIcon: Padding(
  //       padding: const EdgeInsets.all(0.0),
  //       child: Icon(Icons.search),
  //     ),
  //     dropDownMenuItems: leadController.tags.value.map((Tag tag) {
  //       return tag.name;
  //     }).toList(),
  //     onChanged: (strJSON) {
  //       if (strJSON != null) {
  //         List<Tag> tags = tagListFromJson(strJSON);
  //         leadController.selectedTags.value = tags;
  //       } else {
  //         leadController.selectedTags.clear();
  //       }
  //     },
  //     initialValue: leadController.selectedTags.value
  //         .map((Tag tag) => {'value': tag.name, 'parameter': 'name'})
  //         .toList(),
  //   );
  // }
  tagsDDL() {
    final _items = leadController.tags.value
        .map((tag) => MultiSelectItem(tag, tag.name ?? ''))
        .toList();

    return MultiSelectDialogField(
      items: _items,
      initialValue: leadController.selectedTags.value,
      title: Text("Select Tags"),
      selectedColor: Colors.blue,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(),
      ),
      buttonText: Text("Choose Tags"),
      onConfirm: (results) {
        if (results != null) {
          List<Tag> tags = results.cast<Tag>();
          leadController.selectedTags.value = tags;
        } else {
          leadController.selectedTags.clear();
        }
      },
    );
  }

  // assignedToDDL() {
  //   return CustomSearchableDropDown(
  //     items: leadController.assignedTo.value,
  //     label: 'Select AssignedTo',
  //     multiSelectTag: 'AssignedTo',
  //     decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(15),
  //         border: Border.all()),
  //     multiSelect: true,
  //     prefixIcon: Padding(
  //       padding: const EdgeInsets.all(0.0),
  //       child: Icon(Icons.search),
  //     ),
  //     dropDownMenuItems: leadController.assignedTo.value.map((user) {
  //       return "${user.firstName} ${user.lastName}";
  //     }).toList(),
  //     onChanged: (strJson) {
  //       if (strJson != null) {
  //         List<User> users = userListFromJson(strJson);
  //         leadController.selectedAssignedTo.value = users;
  //       } else {
  //         leadController.selectedAssignedTo.clear();
  //       }
  //     },
  //     initialValue: leadController.selectedAssignedTo.value
  //         .map((User user) => {
  //               'value': "${user.firstName} ${user.lastName}",
  //               'parameter': 'fullName'
  //             })
  //         .toList(),
  //   );
  // }
  assignedToDDL() {
    final _items = leadController.assignedTo.value
        .map((user) =>
            MultiSelectItem(user, "${user.firstName} ${user.lastName}"))
        .toList();

    return MultiSelectDialogField(
      items: _items,
      initialValue: leadController.selectedAssignedTo.value,
      title: Text("Select Assigned To"),
      selectedColor: Colors.blue,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(),
      ),
      buttonText: Text("Choose Assign To"),
      onConfirm: (results) {
        if (results != null) {
          List<User> users = results.cast<User>();
          leadController.selectedAssignedTo.value = users;
        } else {
          leadController.selectedAssignedTo.clear();
        }
      },
    );
  }

  // assignedByDDL() {
  //   return CustomSearchableDropDown(
  //     items: leadController.assignedTo.value,
  //     label: 'Select AssignedBy',
  //     multiSelectTag: 'AssignedBy',
  //     decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(15),
  //         border: Border.all()),
  //     multiSelect: true,
  //     prefixIcon: Padding(
  //       padding: const EdgeInsets.all(0.0),
  //       child: Icon(Icons.search),
  //     ),
  //     dropDownMenuItems: leadController.assignedTo.value.map((user) {
  //       return "${user.firstName} ${user.lastName}";
  //     }).toList(),
  //     onChanged: (strJson) {
  //       if (strJson != null) {
  //         List<User> users = userListFromJson(strJson);
  //         leadController.selectedAssignedBy.value = users;
  //       } else {
  //         leadController.selectedAssignedBy.clear();
  //       }
  //     },
  //     initialValue: leadController.selectedAssignedBy.value
  //         .map((User user) => {
  //               'value': "${user.firstName} ${user.lastName}",
  //               'parameter': 'fullName'
  //             })
  //         .toList(),
  //   );
  // }
assignedByDDL() {
  final _items = leadController.assignedTo.value
      .map((user) => DropDownValueModel(
            name: "${user.firstName} ${user.lastName}",
            value: user,
          ))
      .toList();
  final _selecteditems = leadController.selectedAssignedBy.value
      .map((user) => DropDownValueModel(
            name: "${user.firstName} ${user.lastName}",
            value: user,
          ))
      .toList();
  print("_items$_items");
  print("_selectednumber$_selecteditems ");
  return DropDownTextField.multiSelection(
  clearOption: false,

    isEnabled: true,
    dropDownItemCount: 7,
    dropDownList: _items,
    initialValue: _selecteditems,
    onChanged: (value) {
      if (value != null) {
        print(value);
        leadController.selectedAssignedBy.value = (value as List<DropDownValueModel>)
            .map((dropdwnmodel) {
              return User.fromJson(dropdwnmodel.value.toJson());
            })
            .toList();
        print(leadController.selectedAssignedBy.value);
        leadController.selectedAssignedBy.refresh();
      } else {
        leadController.selectedAssignedBy.clear();
        leadController.selectedAssignedBy.refresh();
      }
    },
    textFieldDecoration: InputDecoration(
      labelText: "Select Assigned By",
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
  );
}

  // assignedByDDL() {
  //   final _items = leadController.assignedTo.value
  //       .map((user) =>
  //           MultiSelectItem(user, "${user.firstName} ${user.lastName}"))
  //       .toList();

  //   return MultiSelectDialogField(
  //     items: _items,
  //     initialValue: leadController.selectedAssignedBy.value,
  //     title: Text("Select Assigned By"),
  //     selectedColor: Colors.blue,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(15),
  //       border: Border.all(),
  //     ),
  //     buttonText: Text("Choose Assigned By"),
  //     onConfirm: (results) {
  //       if (results != null) {
  //         List<User> users = results.cast<User>();
  //         leadController.selectedAssignedBy.value = users;
  //          leadController.selectedAssignedBy.refresh();
  //       } else {
  //         leadController.selectedAssignedBy.clear();
  //         leadController.selectedAssignedBy.refresh();
  //       }
  //     },
  //   );
  // }

  // statusDDL() {
  //   return CustomSearchableDropDown(
  //     items: leadController.leadStatus.value,
  //     label: 'Select Status',
  //     multiSelectTag: 'Status',
  //     decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(15),
  //         border: Border.all()),
  //     multiSelect: true,
  //     prefixIcon: Padding(
  //       padding: const EdgeInsets.all(0.0),
  //       child: Icon(Icons.search),
  //     ),
  //     dropDownMenuItems: leadController.leadStatus.value.map((lead) {
  //       return "${lead.statusName}";
  //     }).toList(),
  //     onChanged: (strJson) {
  //       if (strJson != null) {
  //         List<AllLeadsStatus> leadStatus = leadStatusListFromJson(strJson);
  //         leadController.selectedLeadStatus.value = leadStatus;
  //       } else {
  //         leadController.selectedLeadStatus.clear();
  //       }
  //     },
  //     initialValue: leadController.selectedLeadStatus.value
  //         .map((AllLeadsStatus lead) =>
  //             {'value': "${lead.statusName}", 'parameter': 'statusName'})
  //         .toList(),
  //   );
  // }
  statusDDL() {
    final _items = leadController.leadStatus.value
        .map((lead) => MultiSelectItem(lead, lead.statusName ?? ""))
        .toList();

    return MultiSelectDialogField(
      items: _items,
      initialValue: leadController.selectedLeadStatus.value,
      title: Text("Select Status"),
      selectedColor: Colors.blue,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(),
      ),
      buttonText: Text("Choose Status"),
      onConfirm: (results) {
        if (results != null) {
          List<AllLeadsStatus> leadStatus = results.cast<AllLeadsStatus>();
          leadController.selectedLeadStatus.value = leadStatus;
          leadController.selectedLeadStatus.refresh();

        } else {
          leadController.selectedLeadStatus.clear();
          leadController.selectedLeadStatus.refresh();
        }
      },
    );
  }

  // sourceDDL() {
  //   print(
  //       'selectedSources: ${leadController.selectedSources.value.map((source) => {
  //             'value': "$source",
  //             'parameter': 'source'
  //           }).toList()}');
  //   //selectedSources: [{value: Referral, parameter: source}, {value: Paid Campaign, parameter: source}]
  //   return CustomSearchableDropDown(
  //     items: sources,
  //     label: 'Select Source',
  //     multiSelectTag: 'Source',
  //     decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(15),
  //         border: Border.all()),
  //     dropDownMenuItems: sources,
  //     multiSelect: true,
  //     prefixIcon: Padding(
  //       padding: const EdgeInsets.all(0.0),
  //       child: Icon(Icons.search),
  //     ),
  //     onChanged: (strJSON) {
  //       if (strJSON != null) {
  //         // Parse the JSON string to a list
  //         List<String> selectedItems = jsonDecode(strJSON).cast<String>();
  //         // Update the selectedSources observable list
  //         leadController.selectedSources.value = selectedItems;
  //       } else {
  //         leadController.selectedSources.clear();
  //       }
  //     },
  //     initialValue: null,
  //   );
  // }

  sourceDDL() {
    final _items = sources.map((e) => MultiSelectItem(e, e)).toList();

    return MultiSelectDialogField(
      items: _items,
      initialValue: leadController.selectedSources.value,
      title: Text("Select Source"),
      selectedColor: Colors.blue,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(),
      ),
      buttonText: Text("Choose Source"),
      onConfirm: (results) {
        leadController.selectedSources.value = results.cast<String>();
        leadController.selectedSources.refresh();
      },
    );
  }

  void openFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                  15.0), // Adjust the border radius as needed
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  featureKeyDDL(),
                  featureValueDDL(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          child: Text("Clear Filter"),
                          style: ElevatedButton.styleFrom(
                              // primary: Colors.red, // background color
                              ),
                          onPressed: () {
                            setState(() {
                              leadController.leadModel.value = LeadModel();
                              leadController.currentPage=0;
                              print(
                                  "key ${leadController.selectedFeatureKey.value}");
                              leadController.clearFilter();
                              leadController.getFilteredLeads();
                              leadController.refreshController();
                            });

                            Get.back();
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          child: Text("Apply"),
                          style: ElevatedButton.styleFrom(
                              // primary: Colors.blue, // background color
                              ),
                          onPressed: () {
                            setState(() {
                              leadController.leadModel.value = LeadModel();
                              leadController.currentPage=0;
                              leadController.getFilteredLeads();
                            });

                            Get.back();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

//   void openFilterDialog() {
//     Get.defaultDialog(
//         title: "Filters",
//         content: Column(
//           children: [
//             Container(
//               padding: EdgeInsets.only(top: 10, bottom: 15),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Flexible(
//                     child: featureKeyDDL(),
//                   ),
//                   SizedBox(width: 10),
//                   Flexible(
//                     child: featureValueDDL(),
//                   ),
//                 ],
//               ),
//             ),
//             Center(
//               child: TextButton(
//                   child: Text("Clear Filter"),
//                   onPressed: () {
//                     print("key ${leadController.selectedFeatureKey.value}");
//                     leadController.clearFilter();
//                     leadController.getFilteredLeads();
//                     Get.back();
//                   }),
//             )
//           ],
//         ),
//         textConfirm: "Apply",
//         confirmTextColor: Colors.white,
//         barrierDismissible: false,
//         onConfirm: () {
//           leadController.getFilteredLeads();
//           Get.back();
//         },
//         onCancel: () {
//           leadController.clearFilter();
//         });
//   }
// } 

Future<void> deleteLead(leadID) async {
  
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  final response = await NetworkHelper().request(
    RequestType.delete,
    Uri.parse(
        'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/leads/$leadID'),
    requestBody: "",
  );
  if (response != null && response.statusCode == 200) {
    return;
  } else {
    print(response!.statusCode);
    throw Exception('Failed to delete the lead');
  }
}


    Future<List<dynamic>> fetchcallogs(int page,int size,{bool reload=false})async{
 
  try {
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";
    final response = await NetworkHelper().request(
      RequestType.get,
      Uri.parse('https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/call/logs?page=$page&size=$size&sortBy=createdOn&sortOrder=DESC'),
      requestBody: "",
    );

    print('Response for customer roles: ${response?.body}');

    if (response != null && response.statusCode == 200) {
      dynamic parsed = json.decode(response.body);
  ;
parsed= parsed["callLogs"];
print("parsed,$parsed,");
      if (parsed != null && parsed is List<dynamic>) {
     return parsed;
       
      } else {
        print('Invalid response format for calllogs');
        throw Exception('Invalid response format');
      }
    } else {
      print('Failed to load callogs');
      throw Exception('Failed to load calllogs');
    }
  } catch (e) {
    print('Exception occurred while fetching cllogs: $e');
    throw e;
  }
}

class Debouncer {
  Debouncer({required this.interval});
  final Duration interval;

  VoidCallback? _action;
  Timer? _timer;

  void run(VoidCallback action) {
    _action = action;
    _timer?.cancel();
    _timer = Timer(interval, _executeAction);
  }

  void _executeAction() {
    _action?.call();
    _timer = null;
  }

  void cancel() {
    _action = null;
    _timer?.cancel();
    _timer = null;
  }
}

