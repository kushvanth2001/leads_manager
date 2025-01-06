// import 'dart:convert';

// import 'package:bottom_picker/bottom_picker.dart';
// import 'package:dropdown_textfield/dropdown_textfield.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// import '../helper/SharedPrefsHelper.dart';
// import '../helper/networkHelper.dart';

// import '../models/model_contactlist.dart';
// import 'addpromotions.dart';
// import 'communicationdropdown.dart';
// import 'customdropdown.dart';

// class Steps extends StatefulWidget {
//   const Steps({Key? key}) : super(key: key);

//   @override
//   State<Steps> createState() => _StepsState();
// }

// class _StepsState extends State<Steps> {
//  void initState() {
//     super.initState();
//     setdata();

//   }
//   void setdata()async{
// var k=await fetchApplications();
// var u=await ContactList(contactsList: [],status: "ok").fetchContactLists();
// setState(() {
//     allcontactlist=u;
//      _trueApplications=k;
// });

//   }
//    int selectedRadio=1;
//    int _currentStep=0;
//    int uploadexternalRadio=1;
//   List<Application> _selectedValues = [];
//   List<Application> _trueApplications = [];
// DateTime promotiondate=DateTime(200);
// DateTime promotionstarttime=DateTime(200);
// DateTime promotionendtime=DateTime(200);
// String selectedCommunicarionList="";
// String selectedContactList="";
// List<String> allcontactlist=[];
//  FocusNode textFieldFocusNode=FocusNode();

//    setSelectedRadio(int val) {
//     setState(() {
//       selectedRadio = val;
//     });
//   }

//   Future<List<Application>> fetchApplications() async {
//     try {
//       String clientGroupName =
//           await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";

//       final response = await NetworkHelper().request(
//         RequestType.get,
//         Uri.parse(
//           'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/linked-numbers',
//         ),
//         requestBody: "",
//       );

//       if (response != null && response.statusCode == 200) {
//         final parsed = json.decode(response.body);

//         if (parsed != null && parsed is Map<String, dynamic>) {
//           final List<dynamic> applicationList = parsed['application'];
//           final List<Application> applications =
//               applicationList.map((json) => Application.fromJson(json)).toList();

//           return applications;
//         } else {
//           print('Invalid response format');
//           throw Exception('Invalid response format');
//         }
//       } else {
//         print('Failed to load applications');
//         throw Exception('Failed to load applications');
//       }
//     } catch (e) {
//       print('Exception occurred: $e');
//       throw e;
//     }
//   }
//    void _openCustomDropDownDialog(BuildContext context) {
//     var savedifcanceldapplications=_selectedValues;
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Select Application'),
//           content: CustomDropDown(
//             initiallySelectedItems: _selectedValues,
//             allapplicationlist: _trueApplications, // Provide your list of applications
//             onSelectionChanged: (_selectedItems) {
//               setState(() {
//                 _selectedValues = _selectedItems;
//               });
//           // Close the dialog on selection
//             },
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                    _selectedValues=savedifcanceldapplications;
//                 });
               
//                 Navigator.of(context).pop(); // Close the dialog without selection
              
//               },
//               child: Text('Cancel'),
//             ),
       
//        TextButton(
//               onPressed: () {
//              // Close the dialog without selection
//                Navigator.of(context).pop();
//                   for (int i = 0; i < _selectedValues.length; i++) {
//                   print(_selectedValues[i].toJson());
//                   }
//               },
//               child: Text('Save'),
//             ),
       
//           ],
//         );
//       },
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//      List<Widget> _steps=[
//         Card(
//           elevation: 4,
//           child: Container(

// padding: EdgeInsets.all(8),            color: Color.fromARGB(12, 12, 12, 12),
//             child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [Icon(Icons.person,size: 25,),Text("Basic Details",style: TextStyle(fontSize: 20),)],),
//                            Divider(color: Colors.black,),
//                   const SizedBox(height: 30),
//                   const Text("Name *", style: TextStyle(fontSize: 20)),
//                   const SizedBox(height: 10),
//                   SizedBox(
//                     width: MediaQuery.of(context).size.width,
//                     child: TextField(
//                       decoration: const InputDecoration(
//                         filled: true,
//                         fillColor: Color.fromARGB(12, 12, 12, 12),
//                         border: InputBorder.none,
//                         hintText: "Name",
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   const Text("Applications", style: TextStyle(fontSize: 20)),
//                   const SizedBox(height: 10),
       

//  ElevatedButton(
//             onPressed: () {
//               _openCustomDropDownDialog(context);
//             },
//             child: Text('Select Application '),
//           ),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//             children: _selectedValues.map((selectedItem) {
//               return Container(
//                 margin: EdgeInsets.all(8),
//                 padding: EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.blue,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   selectedItem.applicationName,
//                   style: TextStyle(color: Colors.white),
//                 ),
//               );
//             }).toList(),
//           ),
//           ),

//                   const SizedBox(height: 10),
//                   const Text("Description", style: TextStyle(fontSize: 20)),
//                   const SizedBox(height: 10),
//                   SizedBox(
//                     width: MediaQuery.of(context).size.width,
//                     height: 120,
//                     child: TextField(
//                       decoration: const InputDecoration(
//                         filled: true,
//                         fillColor: Color.fromARGB(12, 12, 12, 12),
//                         border: InputBorder.none,
//                         hintText: "Description",
//                       ),
//                       expands: true,
//                       minLines: null,
//                       maxLines: null,
//                     ),
//                   ),
//                    const SizedBox(height: 30),],),
//           ),
//         ),
       
       
//        //step2
//        Card(
//         elevation: 4,
//          child: Container(

//           color: Color.fromARGB(12, 12, 12, 12),
//           padding: EdgeInsets.symmetric(vertical: 20),
//            child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//              children: [
//                 Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [Icon(Icons.send,size: 25,),Text("Send To",style: TextStyle(fontSize: 20),)],),
//                       Divider(color: Colors.black,),
//                 const SizedBox(height: 30),
//                  Column(
//                   mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Radio(
//                   value: 1,
//                   groupValue: selectedRadio,
//                   onChanged: (val) {
//                     setSelectedRadio(val as int);
//                   },
//                 ),
//                 Text('Communication List'),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Radio(
//                   value: 2,
//                   groupValue: selectedRadio,
//                   onChanged: (val) {
//                     setSelectedRadio(val as int);
//                   },
//                 ),
//                 Text('Upload External File'),
//               ],
//             ),
//             ],
//                ),
//          selectedRadio==1?Center(child: Column(
//            children: [
//              MaterialButton(color: Colors.blue,onPressed: (){
//   showDialog(
//                   context: context,
//                   builder: (BuildContext context) {
//                     return Dialog(
//                       // Set the shape of the dialog
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                       child: CommunicationListDropdown(initialSelectedValue: selectedCommunicarionList ,onItemSelected: (value) {
//                           setState(() {
//                             selectedCommunicarionList = value;
//                           });
//                           Navigator.pop(context);}),
//                     );
//                   },         );

//              }, child: Text(selectedCommunicarionList!=""?"Reselect the communication list":"Select Communication List")),
         
//     selectedCommunicarionList!=""? Text("selectedCommunicarionList:$selectedCommunicarionList"):Container()
//            ],
//          )):Column(children: [
//              Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Radio(
//                   value: 1,
//                   groupValue: uploadexternalRadio,
//                   onChanged: (val) {
//                   setState(() {
//                     uploadexternalRadio=val as int;
//                   });
//                   },
//                 ),
//                 Text('select contact List'),
//               ],
//             ),
          
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Radio(
//                   value: 2,
//                   groupValue: uploadexternalRadio,
//                   onChanged: (val) {
//                       setState(() {
//                     uploadexternalRadio=val as int;
//                   });
//                   },
//                 ),
//                 Text('Upload External File'),
//               ],
//             ),
//               uploadexternalRadio==1?Padding(
//                 padding: EdgeInsets.all(20),
//                 child: DropDownTextField(
                  
                
//                           clearOption: true,
                         
//                         textFieldDecoration: const InputDecoration(
//                           label:Text("Select Contact List"),
//                       border: OutlineInputBorder(
                        
//                       )
//                       ),
//                           searchDecoration: const InputDecoration(
//                          border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(20.0)),
//                   ),
//                   hintText: "Search Contact List here"),
                        
//                           dropDownItemCount: 6,
//                           dropDownList: allcontactlist.map((contact) {
//                 return DropDownValueModel(name: contact, value: contact);
//                           }).toList(),
//                           onChanged: (val) {
              
//                 setState(() {
//                   selectedCommunicarionList=val.toString();
//                 });
                    
//                           },
//                         ),
//               ):Container(),
//             uploadexternalRadio==2? MaterialButton(color: Colors.blue,onPressed: (){}, child: Text("Upload a Contact List")):Container(), 
//          ],)  ],
//            ),
//          ),
//        ),
//        //step3
//        Card(
//         elevation: 8,
//          child: Container(
          
//           color: Color.fromARGB(12, 12, 12, 12),
//            child: Padding(
//              padding: const EdgeInsets.all(20),
//              child: Column(
//                children: [
//                   Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [Icon(Icons.message,size: 25,),Text("Message",style: TextStyle(fontSize: 20),)],),
//                              Divider(color: Colors.black,),
//                   SizedBox(height: 6,),
//                  Container(height: 200,width: 300,child: TextField(decoration: InputDecoration(border: OutlineInputBorder(),hintText: "Message",filled: true,fillColor: Color.fromARGB(12, 12, 12, 12),),textAlignVertical: TextAlignVertical.top,expands: true,minLines: null,maxLines: null,),),
//                ],
//              ),
//            ),
//          ),
//        ),
//        //step4
//        Card(
//         elevation: 4,
//          child: Container(
//           padding: EdgeInsets.all(20),
//           color: Color.fromARGB(12, 12, 12, 12),
//        child: Column(
//          children: [
       
//              Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [Icon(Icons.more_vert_sharp,size: 25,),Text("Advanced Details",style: TextStyle(fontSize: 20),)],),
//               Divider(color: Colors.black,),
//           TextButton(child: Text(promotiondate.year==200? "Select Start date :":"start date is ${DateFormat('MM-dd-yyyy').format(promotiondate)}"),onPressed: (){BottomPicker.date(
           
//             title:  "Set the promotion exact  date",
           
//             titleStyle:  TextStyle(
           
//               fontWeight:  FontWeight.bold,
           
//               fontSize:  15,
           
//               color:  Colors.black
           
//             ),
           
//             onSubmit: (date) {
           
               
           
//            setState(() {
           
//              promotiondate=date;
           
//            });
           
           
           
//             },
           
         
            
           
//             buttonText:  'Confirm',
           
//             buttonTextStyle:  const  TextStyle(
           
//               color:  Colors.white
           
//             ),
           
//             buttonSingleColor:  Colors.pink,
           
//             minDateTime:  DateTime(1960, 5, 1),
           
//             maxDateTime:  DateTime(2959, 8, 2)
           
           
           
//              ).show(context);},),
//          TextButton(child: Text(promotionstarttime.year==200? "Select time :":"start time is ${DateFormat('HH:mm aa').format(promotionstarttime)}"),onPressed: (){BottomPicker.time(
           
//             title:  "Set the promotion exact start time",
           
//             titleStyle:  TextStyle(
           
//               fontWeight:  FontWeight.bold,
           
//               fontSize:  15,
           
//               color:  Colors.black
           
//             ),
           
//             onSubmit: (time) {
           
               
           
//            setState(() {
           
//              promotionstarttime=time;
           
//            });
           
           
           
//             },
           
           
           
//             buttonText:  'Confirm',
           
//             buttonTextStyle:  const  TextStyle(
           
//               color:  Colors.white
           
//             ),
           
//             buttonSingleColor:  Colors.pink,
           
//             initialTime:  Time.now(),
           
          
           
           
//              ).show(context);},),
//             TextButton(child: Text(promotionendtime.year==200? "Select end time :":"start end time is ${DateFormat('HH:mm aa').format(promotionendtime)}"),onPressed: (){BottomPicker.time(
           
//             title:  "Set the promotion exact end  time",
           
//             titleStyle:  TextStyle(
           
//               fontWeight:  FontWeight.bold,
           
//               fontSize:  15,
           
//               color:  Colors.black
           
//             ),
           
//             onSubmit: (time) {
           
               
           
//            setState(() {
           
//              promotionendtime=time;
           
//            });
           
           
           
//             },
           
           
           
//             buttonText:  'Confirm',
           
//             buttonTextStyle:  const  TextStyle(
           
//               color:  Colors.white
           
//             ),
           
//             buttonSingleColor:  Colors.pink,
           
//             initialTime:  Time.now(),
           
           
           
//              ).show(context);},),
         
         
         
//          ],
//        )
       
//        ),
//        ),
//        //step5
//        Card(
//         elevation: 4,
//          child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//            children: [
//                   Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [Icon(Icons.attach_file,size: 25,),Text("Attachments",style: TextStyle(fontSize: 20),)],),
//                          Divider(color: Colors.black,),
//              Container(
//               padding: EdgeInsets.all(20),
             
//                  color: Color.fromARGB(12, 12, 12, 12),
//               child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//                children: [
//                 MaterialButton(color: Colors.blue,onPressed: (){},child: Column(children: [Text("Add Document"),Icon(Icons.edit_document)]),),
//                 SizedBox(width: 5,),
//                  MaterialButton(color: Colors.blue,onPressed: (){},child: Column(children: [Text("Add Attachment"),Icon(Icons.attach_file)]),),
//                ],
//              ),),
//            ],
//          ),
//        ),];
//     return const Placeholder();
//   }
// }