// import 'dart:convert';
// import 'package:flutter/rendering.dart';
// import 'package:leads_manager/widgets/easyloadingwidget.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:leads_manager/Controller/chat_controller.dart';
// import 'package:leads_manager/Controller/leads_controller.dart';
// import 'package:leads_manager/constants/colorsConstants.dart';
// import 'package:leads_manager/helper/SharedPrefsHelper.dart';
// import 'package:leads_manager/helper/networkHelper.dart';
// import 'package:leads_manager/utils/snapPeUI.dart';
// import 'package:leads_manager/views/leads/leadDetails/leadDetails.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:leads_manager/views/leads/tasksPage.dart';
// import '../../constants/styleConstants.dart';
// import '../../models/model_LeadStatus.dart';
// import '../../models/model_Merchants.dart';
// import '../../models/model_Users.dart';
// import '../../models/model_lead.dart';
// import 'leadsWidget.dart';
// import 'dart:async';
// import 'package:multi_select_flutter/multi_select_flutter.dart';

// class LeadScreen extends StatefulWidget {
//   final GlobalKey<LeadScreenState>? key;
//   final String? firstAppName;

//   LeadScreen({this.key, this.firstAppName});

//   @override
//   LeadScreenState createState() => LeadScreenState();
// }

// class LeadScreenState extends State<LeadScreen> with WidgetsBindingObserver {
// final LeadController leadController = LeadController();
    
//   final TextEditingController textEditingController = TextEditingController();
//   Timer? _debounce;
//   bool _isLoading = false;
//   String? userId;
  
//   String? liveAgentUserName;
//   Future<void>? _loadingFuture;
//   // List<String> sources = [
//   //   "Email",
//   //   "WhatsApp",
//   //   "Facebook",
//   //   "Google",
//   //   "Network",
//   //   "Referral",
//   //   "Paid Campaign",
//   //   "Pamphlets",
//   //   "Newspaper",
//   //   "Affilates",
//   //   "Others"
//   // ];
//   List<String> sources = [];
// bool isscrollingup=true;
//   Future<void> reloadData() async {
//     liveAgentUserName = await SharedPrefsHelper().getMerchantName();
//     userId = await SharedPrefsHelper().getMerchantUserId();
//     await leadController.loadData(forcedReload: true);
//     String clientName = await SharedPrefsHelper().getClientName() ?? "";
//     print("$clientName from leadsscreen");
//   }

//   @override
//   void initState() {
//     super.initState();
//     reloadData();
//     fetchLeadSourcess().then((leadSources) {
//       if (mounted) {
//         setState(() {
//           sources = leadSources;
//         });
//       }
//     });
//     print("inside leadsscreen initstate");
//     WidgetsBinding.instance!.addObserver(this);
//     leadController.scrollController.addListener(() {
//   // Check if the previous scroll offset is less than the current scroll offset
//   setState(() {
    
//   });
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
// });
//   }

//   @override
//   void dispose() {
//     textEditingController.dispose();
//     _debounce?.cancel();
//     WidgetsBinding.instance!.removeObserver(this);
//     super.dispose();
//   }

//   void _onSearchChanged(String value) {
//     if (_debounce?.isActive ?? false) _debounce?.cancel();
//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       if (value == "") {
//         leadController.loadData(forcedReload: true);
//       } else {
//         leadController.getFilteredLeads(nameOrMobile: value);
//       }
//     });
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       // Set _isLoading to true when the app is resumed
//       if (mounted) {
//         setState(() {
//           _isLoading = true;
//         });
//       }
//       // Start a timer that will set _isLoading to false after 3 seconds
//       Timer(Duration(seconds: 4), () {
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       });
//       if (textEditingController.text.isNotEmpty) {
//         _onSearchChanged(textEditingController.text);
//       } else {
//         //@leadscroll
//       //  reloadData();
//       }
//     }
//   }

//   bool _showNoLeadsMessage = false;
//   _leads() {
//     final leads = leadController.leadModel.value.leads;
//     print("$leads from _leads leadsscreen");

//     if (leadController.leadModel.value.leads == null ||
//         leadController.leadModel.value.leads!.length == 0) {
//       if (!_showNoLeadsMessage) {
//         Future.delayed(Duration(seconds: 15), () {
//           if (mounted) {
//             setState(() {
//               _showNoLeadsMessage = true;
//             });
//           }
//         });
//         return SnapPeUI().loading();
//       } else {
//         return SnapPeUI().noDataFoundImage();
//       }
//     } else {
//       print("${leadController.leadModel.value.leads}");
//       bool isNewleadF = false;
//       return Obx(() =>  Expanded(
//         child:leadController.isloading.value==true? EasyLoadingWidget(child: Container()):Column(
//           children: [
//             Expanded(
//               child: ListView.builder(

//                   controller: leadController.scrollController,
//                   shrinkWrap: true,
//                   itemCount: leadController.leadModel.value.leads==null?0: leadController.leadModel.value.leads!.length,
//                   itemBuilder: (context, index) {
//                     var customer =
//                         leadController.leadModel.value.leads![index].customer;
//                     int? customerId =
//                         customer != null ? customer['customerId'] : null;
                   
//                     return Slidable(
//                         startActionPane: ActionPane(
//                           motion: ScrollMotion(),
//                           children: <Widget>[
//                             SlidableAction(
//                               onPressed: (context) async {
//                                 final prefs =
//                                     await SharedPreferences.getInstance();
//                                 List<String>? phoneNumbers =
//                                     prefs.getStringList('phoneNumbers');
//                                 print(
//                                     'Phone numbers in local storage: $phoneNumbers');
//                                 if (customerId != null) {
//                                   print("stratus is $customerId 1");
//                                   return;
//                                 } else {
//                                   print("stratus is $customerId");
//                                   String? mobileNumber = leadController
//                                       .leadModel
//                                       .value
//                                       .leads![index]
//                                       .mobileNumber;
//                                   String? name = leadController.leadModel.value
//                                       .leads![index].customerName;
//                                   String? email = leadController
//                                       .leadModel.value.leads![index].email;
//                                   String? organizationName = leadController
//                                       .leadModel
//                                       .value
//                                       .leads![index]
//                                       .organizationName;
//                                   String? leadId = leadController
//                                       .leadModel.value.leads![index].id
//                                       .toString();

//                                   showComplaintDialog(context, mobileNumber,
//                                       name, email, organizationName, leadId);
//                                 }
//                               },
//                               backgroundColor: Colors.green,
//                               foregroundColor: Colors.white,
//                               icon: Icons.arrow_forward_rounded,
//                               label: customerId != null
//                                   ? "ALREADY A\n CUSTOMER"
//                                   : 'CONVERT TO\n CUSTOMER',
//                             ),
//                           ],
//                         ),
//                         endActionPane: ActionPane(
//                           motion: ScrollMotion(),
//                           children: <Widget>[
//                             SlidableAction(
//                               onPressed: (context) {
//                                 int? leadID = leadController
//                                     .leadModel.value.leads![index].id;
//                                 // Your delete function goes here
//                                 //https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/DivigoIndia/leads/9885378
//                                 deleteLead(leadID);
//                                 leadController.loadData(forcedReload: true);
//                               },
//                               backgroundColor: Colors.red,
//                               foregroundColor: Colors.white,
//                               icon: Icons.delete,
//                               label: 'Delete',
//                             ),
//                           ],
//                         ),
//                         child: LeadWidget(
//                           index: index,
//                             onBack: () {
//                               if (textEditingController.text.isEmpty ||
//                                   textEditingController.text == "") {
//                                     //@leadscroll
//                               //  leadController.loadData(forcedReload: true);
//                               } else {
//                                 leadController.getFilteredLeads(
//                                     nameOrMobile: textEditingController.text);
//                               }
//                             },
//                             liveAgentUserName: liveAgentUserName,
//                             lead: leadController.leadModel.value.leads![index],
//                             leadController: leadController,
//                             isNewleadd: isNewleadF,
//                             statusList: leadController.statusList,
//                             firstAppName: widget.firstAppName,
//                             chatModels: ChatController.newRequestList
//                             // assignedTo: assignedTo,
//                             ));
//                   }),
//             ),
//           ],
//         ),
//       ));
//     }
//   }

//   _buildBody(context) {
//     print("reloadin");
//     bool isNewleadT = true;
//     return RefreshIndicator(
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             CupertinoSearchTextField(
//                 controller: textEditingController,
//                 placeholder: "Search Leads by Name or Mobile Number",
//                 decoration: SnapPeUI().searchBoxDecoration(),
//                 style: TextStyle(fontSize: kMediumFontSize),
//                 //onSubmitted: _onSearchChanged,
//                 onChanged: _onSearchChanged
//                 // onChanged: (value) {},
//                 ),
//         (isscrollingup)?  TweenAnimationBuilder(
//           curve: Curves.easeInOut,
//         tween: Tween<double>(begin: 0.0, end: 1.0),
//         duration: Duration(seconds: 1), // Adjust duration as needed
//         builder: (BuildContext context, double value, Widget? child) {
//           return  Opacity(
//             opacity: value,
//             child: Container(
//               height: value*50,
//             child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
//                   Expanded(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: EdgeInsets.only(
//                               left: 8.0), // Add 8.0 logical pixels of left padding
//                           child: _isLoading
//                               ? CircularProgressIndicator(
//                                   strokeWidth: 2.0,
//                                   valueColor:
//                                       AlwaysStoppedAnimation<Color>(Colors.white),
//                                 )
//                               : Container(child: Text("")),
//                         ),
//                       ],
//                     ),
//                   ),
                     
//                   TextButton.icon(
//                       icon: Icon(
//                         Icons.access_alarm,
//                         color: Colors.white,
//                       ),
//                       label: Text(
//                         "Tasks",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       onPressed: () {
//                         //openFilterDelegate(context);
                  
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => TasksPage(),
//                           ),
//                         );
//                       }),
//                   TextButton.icon(
//                       icon: Icon(
//                         Icons.filter_list,
//                         color: Colors.white,
//                       ),
//                       label: Text(
//                         "Filters",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       onPressed: () {
//                         //openFilterDelegate(context);
//                         openFilterDialog();
//                       }),
//                   TextButton.icon(
//                       icon: Icon(
//                         Icons.add,
//                         color: Colors.white,
//                       ),
//                       label: Text(
//                         "Add Lead",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                       onPressed: () {
//                         //openFilterDelegate(context);
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => LeadDetails(
//                               onBack: () {
//                                 print("inside onback functioNnnn");
//                                 if (textEditingController.text.isEmpty ||
//                                     textEditingController.text == "") {
//                                       //@leadscroll
//                                 //  leadController.loadData(forcedReload: true);
//                                 } else {
//                                   leadController.getFilteredLeads(
//                                       nameOrMobile: textEditingController.text);
//                                 }
//                               },
//                               openAssignTagsDialog: (empty) {
//                                 print("empty");
//                               },
//                               leadController: leadController,
//                               isNewleadd: isNewleadT,
//                               // lead: leadController.leadModel.value
//                               //     .leads![0] //remove lead it is not necessary
//                             ),
//                           ),
//                         );
//                       }),
//                 ]),
//                   ),
//           );
//         },
//       )
        
//          :TweenAnimationBuilder(
//           curve: Curves.easeInOut,
//         tween: Tween<double>(begin: 1.0, end: 0),
//         duration: Duration(seconds: 1), // Adjust duration as needed
//         builder: (BuildContext context, double value, Widget? child) {
//           return Opacity(
//             opacity: value,
//             child: Container(
            
//               height: 50*value,
            
//               // Your widget content here
//             ),
//           );
//         },
//       ),
//             SizedBox(height: 5),
//             Obx(() => _leads())
//           ],
//         ),
//       ),
//       onRefresh: () {
//         print('load method is called');
//         return Future.delayed(
//           Duration(seconds: 1),
//           () {
//             leadController.loadData(forcedReload: true);
//           },
//         );
//       },
//     );
//   }

//   void showComplaintDialog(BuildContext context, String? mobileNumber,
//       String? name, String? email, String? organizationName, String? leadId) {
//     TextEditingController textMobileNumber =
//         TextEditingController(text: mobileNumber);
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           title: Text("Add as Customer"), // Add your dialog title here
//           content: Container(
//             height: 150, // Adjust as needed
//             child: Padding(
//               padding: const EdgeInsets.all(3),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   TextField(
//                     controller: textMobileNumber,
//                     decoration: InputDecoration(
//                       labelText: 'Mobile Number',
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                         borderSide: BorderSide(color: kPrimaryColor),
//                       ),
//                     ),
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Center(
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             primary: Colors.redAccent, // Background color
//                             onPrimary: Colors.white, // Text color
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                             padding: EdgeInsets.all(12.0),
//                           ),
//                           onPressed: () async {
//                             Navigator.of(context).pop();
//                           },
//                           child: Text("      Cancel      ",
//                               style: TextStyle(color: Colors.white)),
//                         ),
//                       ),
//                       Center(
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             primary: const Color.fromARGB(
//                                 255, 23, 151, 255), // Background color
//                             onPrimary: Colors.white, // Text color
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                             padding: EdgeInsets.all(12.0),
//                           ),
//                           onPressed: () async {
//                             await checkConsumer(context, mobileNumber, name,
//                                 email, organizationName, leadId);
//                             // refreshCallback();
//                             Navigator.of(context).pop();
//                           },
//                           child: Text("    Check    ",
//                               style: TextStyle(color: Colors.white)),
//                         ),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void showCustomerDialog(BuildContext context, String? mobileNumber,
//       String? name, String? email, String? organizationName, String? leadID) {
//     String? leadid = leadID;
//     TextEditingController textMobileNumber =
//         TextEditingController(text: mobileNumber);
//     TextEditingController textName = TextEditingController(text: name);
//     TextEditingController textEmail = TextEditingController(text: email);
//     TextEditingController textOrganizationName =
//         TextEditingController(text: organizationName);
//     TextEditingController textPincode = TextEditingController(text: "");
//     TextEditingController textCustomerRole = TextEditingController(text: "");
//     TextEditingController textAffiliateStatus = TextEditingController(text: "");
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           title: Text("Details"), // Add your dialog title here
//           content: Container(
//             height: 500, // Adjust as needed
//             child: Padding(
//               padding: const EdgeInsets.all(3),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   TextField(
//                     controller: textName,
//                     decoration: InputDecoration(
//                       labelText: 'Name',
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                         borderSide: BorderSide(color: kPrimaryColor),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   TextField(
//                     controller: textMobileNumber,
//                     decoration: InputDecoration(
//                       labelText: 'Mobile Number',
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                         borderSide: BorderSide(color: kPrimaryColor),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   TextField(
//                     controller: textOrganizationName,
//                     decoration: InputDecoration(
//                       labelText: 'Company Name',
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                         borderSide: BorderSide(color: kPrimaryColor),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   TextField(
//                     controller: textCustomerRole,
//                     decoration: InputDecoration(
//                       labelText: 'Customer Role',
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                         borderSide: BorderSide(color: kPrimaryColor),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   TextField(
//                     controller: textEmail,
//                     decoration: InputDecoration(
//                       labelText: 'Email',
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                         borderSide: BorderSide(color: kPrimaryColor),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   TextField(
//                     // controller: textMobileNumber,
//                     decoration: InputDecoration(
//                       labelText: 'PAN Number',
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                         borderSide: BorderSide(color: kPrimaryColor),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Center(
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             primary: Colors.redAccent, // Background color
//                             onPrimary: Colors.white, // Text color
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                             padding: EdgeInsets.all(12.0),
//                           ),
//                           onPressed: () async {
//                             Navigator.of(context).pop();
//                           },
//                           child: Text("      Cancel      ",
//                               style: TextStyle(color: Colors.white)),
//                         ),
//                       ),
//                       Center(
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             primary: const Color.fromARGB(
//                                 255, 23, 151, 255), // Background color
//                             onPrimary: Colors.white, // Text color
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                             padding: EdgeInsets.all(12.0),
//                           ),
//                           onPressed: () async {
//                             Navigator.of(context).pop();
//                             await addCustomer(
//                                 leadid,
//                                 textName,
//                                 textMobileNumber,
//                                 textOrganizationName,
//                                 textPincode,
//                                 textCustomerRole,
//                                 textAffiliateStatus);
//                             await reloadData();
//                             // refreshCallback();
//                           },
//                           child: Text("    ADD    ",
//                               style: TextStyle(color: Colors.white)),
//                         ),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<bool> checkConsumer(
//       BuildContext context,
//       String? mobileNumber,
//       String? name,
//       String? email,
//       String? organizationName,
//       String? leadId) async {
//     String clientGroupName =
//         await SharedPrefsHelper().getClientGroupName() ?? "";
//     print("mobinum : $mobileNumber");
//     print("111111");
//     try {
//       print("222222");
//       final response = await NetworkHelper().request(
//         RequestType.get,
//         Uri.parse(
//             'https://${Globals.DomainPointer}/snappe-services/rest/v1/consumers/consumer?phoneNo=$mobileNumber&merchantName=$clientGroupName'),
//         requestBody: "",
//       );
//       if (response != null) {
//         print("333333");
//         print('Response Status: ${response.statusCode}');
//         print('Response Body: ${response.body}');
//         if (response.statusCode == 200) {
//           print("its true");
//           return true;
//         } else if (response.statusCode == 404) {
//           print("its false");
//           WidgetsBinding.instance?.addPostFrameCallback((_) {
//             // The reason WidgetsBinding.instance?.addPostFrameCallback((_) {...}); helped is because it schedules a callback to be called after the current frame has been dispatched.
//             showCustomerDialog(
//                 context, mobileNumber, name, email, organizationName, leadId);
//           });
//           return false;
//         } else {
//           print('Failed to load consumer data');
//           throw Exception('Failed to load consumer data');
//         }
//       }
//     } catch (e) {
//       print('Exception occurred: $e');
//       throw e;
//     }
//     return false;
//   }

//   Future<void> addCustomer(
//       String? leadId,
//       TextEditingController textName,
//       TextEditingController textMobileNumber,
//       TextEditingController textOrganizationName,
//       TextEditingController textPincode,
//       TextEditingController textCustomerRole,
//       TextEditingController textAffiliateStatus) async {
//     try {
//       String clientGroupName =
//           await SharedPrefsHelper().getClientGroupName() ?? "";
//       // Define the request body
//       var requestBody = jsonEncode({
//         "status": "OK",
//         "firstName": "${textName.text}",
//         "middleName": null,
//         "lastName": "",
//         "gstNo": null,
//         "countryCode": "+91",
//         "userName": null,
//         "password": null,
//         "phoneNo": "91${textMobileNumber.text}",
//         "community": ".",
//         "relativeLocation": null,
//         "alternativeNo1": null,
//         "primaryEmailAddress": "",
//         "alternativeEmailAddress": null,
//         "latitude": null,
//         "longitude": null,
//         "mapLocation": null,
//         "houseNo": null,
//         "pincode": "${textPincode.text}.",
//         "city": null,
//         "addressLine1": null,
//         "addressLine2": null,
//         "addressType": "Home",
//         "mobileNumber": "+91${textMobileNumber.text}",
//         "applicationNo": "91${textMobileNumber.text}",
//         "token": null,
//         "userId": null,
//         "isValid": false,
//         "isExtendable": false,
//         "guid": null,
//         "organizationName": "${textOrganizationName.text}",
//         "isBilling": true,
//         "isShipping": true,
//         "tagsDTO": {"tags": []},
//         "isNoteAvailable": false,
//         "customColumns": [],
//         "leadId": null,
//         "block": null,
//         "flat": null,
//         "gstNumber": null,
//         "panNo": null,
//         "pan": null,
//         "panFile": null,
//         "gstFile": null,
//         "isCopyNotes": true,
//         "roleId": 1,
//         "affiliateStatus": "Approved",
//         "Community": null,
//         "affilatedStatus": {"label": "Approved", "value": "Approved"},
//         "role": "customer"
//       });

//       final response = await NetworkHelper().request(
//         RequestType.post,
//         Uri.parse(
//             'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/lead-customer?clientLeadId=$leadId'),
//         requestBody: requestBody,
//       );
//       if (response != null && response.statusCode == 200) {
//         print('Response Status: ${response.statusCode}');
//         print('Response Body: ${response.body}');
//         // Handle the response as needed
//       } else {
//         print('Failed to add customer');
//         throw Exception('Failed to add customer');
//       }
//     } catch (e) {
//       print('Exception occurred: $e');
//       throw e;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final GlobalKey<LeadScreenState> leadScreenKey =
//         GlobalKey<LeadScreenState>();
//     return Scaffold(
//       body: _buildBody(context),
//     );
//   }

//   featureKeyDDL() {
//     return Padding(
//       padding: EdgeInsets.all(8.0),
//       child: Obx(
//         () => CustomSearchableDropDown(
//           items: leadController.featureKeys.value,
//           label: 'Select filter',
//           initialIndex: leadController.featureKeys
//               .indexOf(leadController.selectedFeatureKey.value),
//           decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(15),
//               border: Border.all()),
//           prefixIcon: Padding(
//             padding: const EdgeInsets.all(0.0),
//             child: Icon(Icons.search),
//           ),
//           dropDownMenuItems: leadController.featureKeys.value.map((columnName) {
//             return columnName;
//           }).toList(),
//           onChanged: (value) {
//             if (value != null) {
//               leadController.selectedFeatureKey.value = value;
//             } else {
//               leadController.selectedFeatureKey.value = "";
//             }
//           },
//         ),
//       ),
//     );
//   }

//   featureValueDDL() {
//     //["Tags","AssignedTo","Organization Name","Email","Status","Source"]
//     return Padding(
//       padding: EdgeInsets.all(8),
//       child: Obx(() => Column(
//             children: [
//               Visibility(
//                   maintainState: true,
//                   visible: leadController.selectedFeatureKey.value == "Tags",
//                   child: tagsDDL()),
//               Visibility(
//                   maintainState: true,
//                   visible:
//                       leadController.selectedFeatureKey.value == "AssignedTo",
//                   child: assignedToDDL()),
//               Visibility(
//                   maintainState: true,
//                   visible: leadController.selectedFeatureKey.value == "Status",
//                   child: statusDDL()),
//               Visibility(
//                   maintainState: true,
//                   visible:
//                       leadController.selectedFeatureKey.value == "AssignedBy",
//                   child: assignedByDDL()),
//               Visibility(
//                   maintainState: true,
//                   visible: leadController.selectedFeatureKey.value == "Source",
//                   child: sourceDDL()),
//               Visibility(
//                   maintainState: true,
//                   visible: leadController.selectedFeatureKey.value == "Date",
//                   child: dateDDL()),
//             ],
//           )),
//     );
//   }

//   Widget dateDDL() {
//     print("sdf ${leadController.selectedDates}");
//     return Row(
//       children: [
//         IconButton(
//           icon: Icon(Icons.calendar_today),
//           onPressed: () async {
//             final DateTimeRange? picked = await showDateRangePicker(
//               context: context,
//               firstDate: DateTime(DateTime.now().year - 5),
//               lastDate: DateTime(DateTime.now().year + 5),
//             );

//             if (picked != null) {
//               setState(() {
//                 // Convert the dates to epoch values and store them in selectedDates
//                 leadController.selectedDates.clear();
//                 leadController.selectedDates.add(picked
//                     .start.millisecondsSinceEpoch
//                     .toString()
//                     .substring(0, 10));
//                 leadController.selectedDates.add(picked
//                     .end.millisecondsSinceEpoch
//                     .toString()
//                     .substring(0, 10));
//               });
//             }
//           },
//         ),
//         if (leadController.selectedDates.isNotEmpty)
//           Text(
//             '${DateFormat('dd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(int.parse(leadController.selectedDates[0]) * 1000))} \n'
//             '${DateFormat('dd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(int.parse(leadController.selectedDates[1]) * 1000))}',
//             style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
//           ),
//         if (leadController.selectedDates.isEmpty) Text("Select \n dates")
//       ],
//     );
//   }

//   // tagsDDL() {
//   //   return CustomSearchableDropDown(
//   //     items: leadController.tags.value,
//   //     label: 'Select Tags',
//   //     multiSelectTag: 'Tags',
//   //     decoration: BoxDecoration(
//   //         color: Colors.white,
//   //         borderRadius: BorderRadius.circular(15),
//   //         border: Border.all()),
//   //     multiSelect: true,
//   //     prefixIcon: Padding(
//   //       padding: const EdgeInsets.all(0.0),
//   //       child: Icon(Icons.search),
//   //     ),
//   //     dropDownMenuItems: leadController.tags.value.map((Tag tag) {
//   //       return tag.name;
//   //     }).toList(),
//   //     onChanged: (strJSON) {
//   //       if (strJSON != null) {
//   //         List<Tag> tags = tagListFromJson(strJSON);
//   //         leadController.selectedTags.value = tags;
//   //       } else {
//   //         leadController.selectedTags.clear();
//   //       }
//   //     },
//   //     initialValue: leadController.selectedTags.value
//   //         .map((Tag tag) => {'value': tag.name, 'parameter': 'name'})
//   //         .toList(),
//   //   );
//   // }
//   tagsDDL() {
//     final _items = leadController.tags.value
//         .map((tag) => MultiSelectItem(tag, tag.name ?? ''))
//         .toList();

//     return MultiSelectDialogField(
//       items: _items,
//       initialValue: leadController.selectedTags.value,
//       title: Text("Select Tags"),
//       selectedColor: Colors.blue,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(),
//       ),
//       buttonText: Text("Choose Tags"),
//       onConfirm: (results) {
//         if (results != null) {
//           List<Tag> tags = results.cast<Tag>();
//           leadController.selectedTags.value = tags;
//         } else {
//           leadController.selectedTags.clear();
//         }
//       },
//     );
//   }

//   // assignedToDDL() {
//   //   return CustomSearchableDropDown(
//   //     items: leadController.assignedTo.value,
//   //     label: 'Select AssignedTo',
//   //     multiSelectTag: 'AssignedTo',
//   //     decoration: BoxDecoration(
//   //         color: Colors.white,
//   //         borderRadius: BorderRadius.circular(15),
//   //         border: Border.all()),
//   //     multiSelect: true,
//   //     prefixIcon: Padding(
//   //       padding: const EdgeInsets.all(0.0),
//   //       child: Icon(Icons.search),
//   //     ),
//   //     dropDownMenuItems: leadController.assignedTo.value.map((user) {
//   //       return "${user.firstName} ${user.lastName}";
//   //     }).toList(),
//   //     onChanged: (strJson) {
//   //       if (strJson != null) {
//   //         List<User> users = userListFromJson(strJson);
//   //         leadController.selectedAssignedTo.value = users;
//   //       } else {
//   //         leadController.selectedAssignedTo.clear();
//   //       }
//   //     },
//   //     initialValue: leadController.selectedAssignedTo.value
//   //         .map((User user) => {
//   //               'value': "${user.firstName} ${user.lastName}",
//   //               'parameter': 'fullName'
//   //             })
//   //         .toList(),
//   //   );
//   // }
//   assignedToDDL() {
//     final _items = leadController.assignedTo.value
//         .map((user) =>
//             MultiSelectItem(user, "${user.firstName} ${user.lastName}"))
//         .toList();

//     return MultiSelectDialogField(
//       items: _items,
//       initialValue: leadController.selectedAssignedTo.value,
//       title: Text("Select Assigned To"),
//       selectedColor: Colors.blue,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(),
//       ),
//       buttonText: Text("Choose Assign To"),
//       onConfirm: (results) {
//         if (results != null) {
//           List<User> users = results.cast<User>();
//           leadController.selectedAssignedTo.value = users;
//         } else {
//           leadController.selectedAssignedTo.clear();
//         }
//       },
//     );
//   }

//   // assignedByDDL() {
//   //   return CustomSearchableDropDown(
//   //     items: leadController.assignedTo.value,
//   //     label: 'Select AssignedBy',
//   //     multiSelectTag: 'AssignedBy',
//   //     decoration: BoxDecoration(
//   //         color: Colors.white,
//   //         borderRadius: BorderRadius.circular(15),
//   //         border: Border.all()),
//   //     multiSelect: true,
//   //     prefixIcon: Padding(
//   //       padding: const EdgeInsets.all(0.0),
//   //       child: Icon(Icons.search),
//   //     ),
//   //     dropDownMenuItems: leadController.assignedTo.value.map((user) {
//   //       return "${user.firstName} ${user.lastName}";
//   //     }).toList(),
//   //     onChanged: (strJson) {
//   //       if (strJson != null) {
//   //         List<User> users = userListFromJson(strJson);
//   //         leadController.selectedAssignedBy.value = users;
//   //       } else {
//   //         leadController.selectedAssignedBy.clear();
//   //       }
//   //     },
//   //     initialValue: leadController.selectedAssignedBy.value
//   //         .map((User user) => {
//   //               'value': "${user.firstName} ${user.lastName}",
//   //               'parameter': 'fullName'
//   //             })
//   //         .toList(),
//   //   );
//   // }
//   assignedByDDL() {
//     final _items = leadController.assignedTo.value
//         .map((user) =>
//             MultiSelectItem(user, "${user.firstName} ${user.lastName}"))
//         .toList();

//     return MultiSelectDialogField(
//       items: _items,
//       initialValue: leadController.selectedAssignedBy.value,
//       title: Text("Select Assigned By"),
//       selectedColor: Colors.blue,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(),
//       ),
//       buttonText: Text("Choose Assigned By"),
//       onConfirm: (results) {
//         if (results != null) {
//           List<User> users = results.cast<User>();
//           leadController.selectedAssignedBy.value = users;
//         } else {
//           leadController.selectedAssignedBy.clear();
//         }
//       },
//     );
//   }

//   // statusDDL() {
//   //   return CustomSearchableDropDown(
//   //     items: leadController.leadStatus.value,
//   //     label: 'Select Status',
//   //     multiSelectTag: 'Status',
//   //     decoration: BoxDecoration(
//   //         color: Colors.white,
//   //         borderRadius: BorderRadius.circular(15),
//   //         border: Border.all()),
//   //     multiSelect: true,
//   //     prefixIcon: Padding(
//   //       padding: const EdgeInsets.all(0.0),
//   //       child: Icon(Icons.search),
//   //     ),
//   //     dropDownMenuItems: leadController.leadStatus.value.map((lead) {
//   //       return "${lead.statusName}";
//   //     }).toList(),
//   //     onChanged: (strJson) {
//   //       if (strJson != null) {
//   //         List<AllLeadsStatus> leadStatus = leadStatusListFromJson(strJson);
//   //         leadController.selectedLeadStatus.value = leadStatus;
//   //       } else {
//   //         leadController.selectedLeadStatus.clear();
//   //       }
//   //     },
//   //     initialValue: leadController.selectedLeadStatus.value
//   //         .map((AllLeadsStatus lead) =>
//   //             {'value': "${lead.statusName}", 'parameter': 'statusName'})
//   //         .toList(),
//   //   );
//   // }
//   statusDDL() {
//     final _items = leadController.leadStatus.value
//         .map((lead) => MultiSelectItem(lead, lead.statusName ?? ""))
//         .toList();

//     return MultiSelectDialogField(
//       items: _items,
//       initialValue: leadController.selectedLeadStatus.value,
//       title: Text("Select Status"),
//       selectedColor: Colors.blue,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(),
//       ),
//       buttonText: Text("Choose Status"),
//       onConfirm: (results) {
//         if (results != null) {
//           List<AllLeadsStatus> leadStatus = results.cast<AllLeadsStatus>();
//           leadController.selectedLeadStatus.value = leadStatus;
//         } else {
//           leadController.selectedLeadStatus.clear();
//         }
//       },
//     );
//   }

//   // sourceDDL() {
//   //   print(
//   //       'selectedSources: ${leadController.selectedSources.value.map((source) => {
//   //             'value': "$source",
//   //             'parameter': 'source'
//   //           }).toList()}');
//   //   //selectedSources: [{value: Referral, parameter: source}, {value: Paid Campaign, parameter: source}]
//   //   return CustomSearchableDropDown(
//   //     items: sources,
//   //     label: 'Select Source',
//   //     multiSelectTag: 'Source',
//   //     decoration: BoxDecoration(
//   //         color: Colors.white,
//   //         borderRadius: BorderRadius.circular(15),
//   //         border: Border.all()),
//   //     dropDownMenuItems: sources,
//   //     multiSelect: true,
//   //     prefixIcon: Padding(
//   //       padding: const EdgeInsets.all(0.0),
//   //       child: Icon(Icons.search),
//   //     ),
//   //     onChanged: (strJSON) {
//   //       if (strJSON != null) {
//   //         // Parse the JSON string to a list
//   //         List<String> selectedItems = jsonDecode(strJSON).cast<String>();
//   //         // Update the selectedSources observable list
//   //         leadController.selectedSources.value = selectedItems;
//   //       } else {
//   //         leadController.selectedSources.clear();
//   //       }
//   //     },
//   //     initialValue: null,
//   //   );
//   // }

//   sourceDDL() {
//     final _items = sources.map((e) => MultiSelectItem(e, e)).toList();

//     return MultiSelectDialogField(
//       items: _items,
//       initialValue: leadController.selectedSources.value,
//       title: Text("Select Source"),
//       selectedColor: Colors.blue,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(),
//       ),
//       buttonText: Text("Choose Source"),
//       onConfirm: (results) {
//         leadController.selectedSources.value = results.cast<String>();
//       },
//     );
//   }

//   void openFilterDialog() {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(
//                   15.0), // Adjust the border radius as needed
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.5),
//                   spreadRadius: 5,
//                   blurRadius: 7,
//                   offset: Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   featureKeyDDL(),
//                   featureValueDDL(),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: ElevatedButton(
//                           child: Text("Clear Filter"),
//                           style: ElevatedButton.styleFrom(
//                            // primary: Colors.red, // background color
//                           ),
//                           onPressed: () {
//                              setState(() {
//                               leadController.leadModel.value=LeadModel();
//                               print(
//                                 "key ${leadController.selectedFeatureKey.value}");
//                             leadController.clearFilter();
//                             leadController.getFilteredLeads();
//                             leadController.refreshController();

//                             });
                       
                           
                            
//                             Navigator.pop(context);
//                           },
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: ElevatedButton(
//                           child: Text("Apply"),
//                           style: ElevatedButton.styleFrom(
//                            // primary: Colors.blue, // background color
//                           ),
//                           onPressed: () {
//                               setState(() {
//                               leadController.leadModel.value=LeadModel();
//                             leadController.getFilteredLeads();

//                             });
                          
//                             Navigator.pop(context);
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// //   void openFilterDialog() {
// //     Get.defaultDialog(
// //         title: "Filters",
// //         content: Column(
// //           children: [
// //             Container(
// //               padding: EdgeInsets.only(top: 10, bottom: 15),
// //               child: Row(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Flexible(
// //                     child: featureKeyDDL(),
// //                   ),
// //                   SizedBox(width: 10),
// //                   Flexible(
// //                     child: featureValueDDL(),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             Center(
// //               child: TextButton(
// //                   child: Text("Clear Filter"),
// //                   onPressed: () {
// //                     print("key ${leadController.selectedFeatureKey.value}");
// //                     leadController.clearFilter();
// //                     leadController.getFilteredLeads();
// //                     Get.back();
// //                   }),
// //             )
// //           ],
// //         ),
// //         textConfirm: "Apply",
// //         confirmTextColor: Colors.white,
// //         barrierDismissible: false,
// //         onConfirm: () {
// //           leadController.getFilteredLeads();
// //           Get.back();
// //         },
// //         onCancel: () {
// //           leadController.clearFilter();
// //         });
// //   }
// // }

// deleteLead(leadID) async {
//   String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
//   final response = await NetworkHelper().request(
//     RequestType.delete,
//     Uri.parse(
//         'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/leads/$leadID'),
//     requestBody: "",
//   );
//   if (response != null && response.statusCode == 200) {
//     return;
//   } else {
//     throw Exception('Failed to load templates');
//   }
// }

// Future<List<String>> fetchLeadSourcess() async {
//   String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
//   try {
//     final response = await NetworkHelper().request(
//       RequestType.get,
//       Uri.parse(
//           'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/lead-source'),
//       requestBody: "",
//     );
//     if (response != null && response.statusCode == 200) {
//       print('Response Status: ${response.statusCode}');
//       print('Response Body: ${response.body}');
//       final parsed = jsonDecode(response.body)['allLeadsSources'];
//       return List<String>.from(parsed.map((json) => json['sourceName']));
//     } else {
//       print('Failed to load lead sources ${response?.statusCode}');
//       throw Exception('Failed to load lead sources');
//     }
//   } catch (e) {
//     print('Exception occurred: $e');
//     return [];
//   }
// }
