import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:leads_manager/Controller/chat_controller.dart';
import 'package:leads_manager/constants.dart';
import 'package:leads_manager/helper/Filepickerhelper.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:leads_manager/models/model_Merchants.dart';
import 'package:leads_manager/models/model_application.dart';
import 'package:leads_manager/models/model_assignedTo.dart';
import 'package:leads_manager/models/model_chat.dart';
// import 'package:leads_manager/models/model_assignedTo.dart' ;
import 'package:leads_manager/models/model_customColumn.dart';
import 'package:leads_manager/models/model_leadDetails.dart';
import 'package:leads_manager/models/model_leadsource.dart';
//import 'package:leads_manager/models/model_leadDetails.dart'
//     as assignedTo_Model;
import 'package:leads_manager/models/model_priority.dart';
import 'package:leads_manager/models/model_tag.dart';
import 'package:leads_manager/utils/SharedFunctions.dart';
import 'package:leads_manager/utils/snapPeUI.dart';
import 'package:leads_manager/views/chat/chatDetailsScreen.dart';
import 'package:leads_manager/views/leads/leadDetails/appController.dart';
import 'package:leads_manager/views/leads/leadDetails/notesWidget.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
// import 'package:leads_manager/views/leads/leadNotesScreen.dart';
import 'package:leads_manager/views/leads/leadNotesScreen.dart';
import 'package:leads_manager/models/model_LeadStatus.dart';
import 'package:leads_manager/views/leads/leadfilter.dart';
import 'package:leads_manager/views/leads/leadsWidget.dart';
import 'package:leads_manager/views/leads/quickResponse/QuickPage.dart';
import 'package:leads_manager/widgets/incrordecr.dart';
import 'package:leads_manager/widgets/skeletonitems.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Controller/leadDetails_controller.dart';
import '../../../Controller/leads_controller.dart';
import '../../../constants/colorsConstants.dart';
import 'package:leads_manager/models/model_lead.dart' as model_lead;


class LeadDetails extends StatefulWidget {
  final model_lead.Lead lead;
  final bool isNewLead;
  
  final Function(dynamic)? dynamicCallback;
  const LeadDetails(
      {super.key,
      required this.lead,
      required this.isNewLead,
      this.dynamicCallback,
    
      
      });

  @override
  State<LeadDetails> createState() => _LeadDetailsState();
}

class _LeadDetailsState extends State<LeadDetails> {
  LeadController _leadController = Get.find<LeadController>();
  late LeadDetailsModel overallleaddetailsmodel;
  bool isdataloaded = false;
  List<CustomColumn>? customColumns = [];
  List<TextEditingController> customColumnsControllers = [];

  late final SharedFunctions sharedFunctions;
  List<User> _users = [];
  List<String> DialCodes = [];
  Set<String> setdialCodes = {};
  List<String> dialCodes = [];
  List<dynamic> _status = [];
  List<LeadSource> sources = [];
  List<Priority> _priorities = [];
  String? _selectedApplicationName;
  List<String?> _applicationNames = [];
  String firstAppName = '';
  final List<ChatModel>? chatModels = ChatController.newRequestList;
  final _formKey = GlobalKey<FormState>();
  bool conversationPrivillage=  true;
    bool calllogsPrivillage= true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setdata();
  }

  setdata() async {

 conversationPrivillage=await SharedPrefsHelper().getviewCommnuicationsPrivillage();
   calllogsPrivillage=await SharedPrefsHelper().getviewcallLogsPrivillage() ;

     print("tasskkid${widget.lead.id} ");
    fetchCustomColumns(widget.lead.id, widget.isNewLead).then((columns) {
      if (mounted) {
        setState(() {
          customColumns = columns;
        });
      }
    });

    SnapPeNetworks().fetchUsers().then((users) {
      if (mounted) {
        setState(() {
          _users = users;
        });
      }
    });

    getAllLeadsStatus().then((allLeadsStatus) {
      if (mounted) {
        setState(() {
          _status = allLeadsStatus.map((e) => LeadStatus.fromJson(e)).toList();
        });
      }
    });

    fetchLeadSources().then((leadSources) {
      if (mounted) {
        setState(() {
          sources = leadSources;
        });
      }
    });

    fetchPriorities().then((priorities) {
      if (mounted) {
        setState(() {
          _priorities = priorities;
        });
      }
    });

    fetchApplications().then((applications) {
      if (mounted) {
        setState(() {
          _applicationNames =
              applications.map((app) => app.applicationName).toList();
          firstAppName = _applicationNames[0] ?? "";
        });
      }
    });
    var k = widget.isNewLead
        ? LeadDetailsModel(mobileNumber:int.tryParse(isValidIndianMobileNumber(widget.lead.mobileNumber ?? "")??"")??null,leadSource:widget.lead.leadSource!=null?widget.lead.leadSource:null,assignedBy:widget.lead.assignedBy!=null?widget.lead.assignedBy:null  )
        : await SnapPeNetworks()
            .getSingleLead("${widget.lead.id}", isalldetails: true);
    print(k);
    setState(() {
      overallleaddetailsmodel = k;
print(overallleaddetailsmodel.countryCode);
      isdataloaded = true;
    });
  }
LeadController leadcontroller=Get.find<LeadController>();
  @override
  Widget build(BuildContext context) {
    return isdataloaded
        ? Scaffold(
            backgroundColor: Colors.white,
            floatingActionButton: Container(
              margin: EdgeInsets.only(left: 35),
              width: double.infinity, // Full width
              child: ElevatedButton(
                onPressed: () async {
                 if (_formKey.currentState!.validate()) {
              model_lead.  Lead? resultlead  = await SnapPeNetworks().saveLead(
                      widget.lead.id,
                      overallleaddetailsmodel,
                      widget.isNewLead,
                    );
(resultlead!=null && overallleaddetailsmodel.tagsDto!=null)? Tag.AssignTags(resultlead!.id.toString(), overallleaddetailsmodel.tagsDto!):null;
                  
                    if (!widget.isNewLead) {
                      for (int i = 0;
                          i < _leadController.leadModel.value.leads!.length;
                          i++) {
                        print(i);

                        if (_leadController.leadModel.value.leads![i].id ==
                            widget.lead.id) {
                          print("lead found");
                          try {
                            Future.delayed(Duration(seconds: 1));
                            model_lead.Lead k = await SnapPeNetworks()
                                .getSingleLead(widget.lead.id.toString());
                            _leadController.leadModel.value.leads?[i] = k;
                            
                            model_lead.LeadModel value =
                                _leadController.leadModel.value;
                            _leadController.leadModel.value = value;

                            _leadController.refreshController();
overallleaddetailsmodel.customColumns?.map((e){
  print("""|
  |
  |""");
print(e.toJson());
}).toList();
                            //print( LeadController().leadModel.value.leads![i].leadStatus!.toJson());
                            //  print("lead json ${k.toJson()} 2");
                          } catch (e) {
                            print("<<$e");
                          }
                        }
                      }
                    }
                    widget.dynamicCallback != null
                        ? widget.dynamicCallback!(resultlead)
                        : null;

                        if(resultlead!=null){
                    Get.back(result: overallleaddetailsmodel);
                 
                  }
                  
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Background color
                  foregroundColor: Colors.white, // Text color
                  padding:
                      EdgeInsets.symmetric(vertical: 15), // Padding for height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text('Save'),
              ),
            ),
            appBar: SnapPeUI().nAppBar2(
                widget.isNewLead,
                widget.isNewLead == true
                    ? "New Lead"
                    : "${ overallleaddetailsmodel.customerName ?? overallleaddetailsmodel.mobileNumber ?? ""}",
                overallleaddetailsmodel.id,
                _leadController,
                context),
            body: Form(
              key: _formKey,
              child: Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      //from lead widget
                widget.isNewLead?   Container() : actionMenuItems(widget.lead,context,calllogsPrivillage: calllogsPrivillage,conversationPrivillage: conversationPrivillage),

                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        child: TextFormField(
                          style: TextStyle(color: Colors.black),
                          initialValue: overallleaddetailsmodel.customerName,
                          onChanged: (value) {
                            setState(() {
                              overallleaddetailsmodel.customerName = value;
                            });
                          },
                          keyboardType: TextInputType.name,
                          decoration: overallborderstyle(
                              "Enter Name", Icons.person_2, null),
                          validator: (value) {
                            if ((value == null || value.isEmpty) &&
                                (overallleaddetailsmodel.email == null ||
                                    overallleaddetailsmodel.email == "") &&
                                (overallleaddetailsmodel.mobileNumber == null ||
                                    overallleaddetailsmodel.mobileNumber ==
                                        "")) {
                              return 'Among Name,Emai,Mobile number one should be present';
                            }
                            return null;
                          },
                        ),
                      ),

                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        child: IntlPhoneField(
                          validator: (value) {
                            if ((value == null || value == "") &&
                                (overallleaddetailsmodel.email == null ||
                                    overallleaddetailsmodel.email == "") &&
                                (overallleaddetailsmodel.customerName == null ||
                                    overallleaddetailsmodel.customerName ==
                                        "")) {
                              return 'Among Name,Emai,Mobile number one should be present';
                            }
                            return null;
                          },
                          initialValue: overallleaddetailsmodel.mobileNumber ==
                                  null
                              ? widget.lead.mobileNumber
                              : overallleaddetailsmodel.mobileNumber.toString(),
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(),
                            ),
                          ),
                          initialCountryCode: getCountryCode(validateString(
                                      overallleaddetailsmodel.countryCode) ??
                                  "") ??
                              'IN',
                          onChanged: (phone) {
                            setState(() {
                              overallleaddetailsmodel.countryCode =
                                  phone.countryCode;
                              overallleaddetailsmodel.mobileNumber = phone
                                      .completeNumber
                                      .startsWith("+")
                                  ? int.parse(phone.completeNumber.substring(1))
                                  : int.parse(phone.completeNumber);
                                  print( phone.countryCode);
                            });


 var nullcheck=overallleaddetailsmodel.countryCode?.substring(1)??'+91'.substring(1); 
 if(nullcheck==overallleaddetailsmodel.mobileNumber.toString()){
overallleaddetailsmodel.mobileNumber=null;

 }


                              print( overallleaddetailsmodel.countryCode);
                            print( "toals${overallleaddetailsmodel.mobileNumber}");
                          },
                        ),
                      ),

                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        child: TextFormField(
                          initialValue: overallleaddetailsmodel.email,
                          style: TextStyle(color: Colors.black),
                          keyboardType: TextInputType.emailAddress,
                          decoration: overallborderstyle(
                              "Enter Email", null, Icons.email),
                          onChanged: (value) {
                            setState(() {
                              overallleaddetailsmodel.email = value;
                            });
                          },
                          validator: (value) {
                            if ((value == null || value.isEmpty) &&
                                (overallleaddetailsmodel.mobileNumber == null ||
                                    overallleaddetailsmodel.mobileNumber ==
                                        "") &&
                                (overallleaddetailsmodel.customerName == null ||
                                    overallleaddetailsmodel.customerName ==
                                        "")) {
                              return 'Among Name,Emai,Mobile number one should be present';
                            }
                            return null;
                          },
                        ),
                      ),

                      // Organization Name
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        child: TextFormField(
                          initialValue:
                              overallleaddetailsmodel.organizationName,
                          style: TextStyle(color: Colors.black),
                          keyboardType: TextInputType.name,
                          decoration: overallborderstyle(
                              "Enter Organization", Icons.business, null),
                          onChanged: (value) {
                            setState(() {
                              overallleaddetailsmodel.organizationName = value;
                            });
                          },
                        ),
                      ), // City
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        child: TextFormField(
                          initialValue: overallleaddetailsmodel.city,
                          style: TextStyle(color: Colors.black),
                          keyboardType: TextInputType.name,
                          decoration: overallborderstyle(
                              "Enter City", Icons.location_city, null),
                          onChanged: (value) {
                            setState(() {
                              overallleaddetailsmodel.city = value;
                            });
                          },
                        ),
                      ),

                      // State
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        child: TextFormField(
                          initialValue: overallleaddetailsmodel.state,
                          style: TextStyle(color: Colors.black),
                          keyboardType: TextInputType.name,
                          decoration: overallborderstyle(
                              "Enter State", Icons.location_on, null),
                          onChanged: (value) {
                            setState(() {
                              overallleaddetailsmodel.state = value;
                            });
                          },
                        ),
                      ),

                      // Country
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        child: TextFormField(
                          initialValue: overallleaddetailsmodel.country,
                          style: TextStyle(color: Colors.black),
                          keyboardType: TextInputType.name,
                          decoration: overallborderstyle(
                              "Enter Country", Icons.location_on, null),
                          onChanged: (value) {
                            setState(() {
                              overallleaddetailsmodel.country = value;
                            });
                          },
                        ),
                      ),

                      // Pincode
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        child: TextFormField(
                          initialValue: overallleaddetailsmodel.pincode == null
                              ? ""
                              : overallleaddetailsmodel.pincode.toString(),
                          style: TextStyle(color: Colors.black),
                          keyboardType: TextInputType.number,
                          decoration: overallborderstyle(
                              "Enter Pincode", Icons.pin_drop, null),
                          onChanged: (value) {
                            setState(() {
                              overallleaddetailsmodel.pincode =
                                  int.tryParse(value) ?? 0;
                            });
                          },
                        ),
                      ),

                      // Address
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        child: TextFormField(
                          initialValue: overallleaddetailsmodel.fullAddress,
                          style: TextStyle(color: Colors.black),
                          keyboardType: TextInputType.multiline,
                          maxLines: 2,
                          decoration:
                              overallborderstyle("Enter Address", null, null),
                          onChanged: (value) {
                            setState(() {
                              overallleaddetailsmodel.fullAddress = value;
                            });
                          },
                        ),
                      ),
                      _status.isNotEmpty
                          ? Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              child: DropDownTextField(
                                clearOption: false,
                                textFieldDecoration: overallborderstyle(
                                    "Lead Status", null, null),
                                initialValue: overallleaddetailsmodel
                                    .leadStatus?.statusName,
                                dropDownList: _status.map((status) {
                                  return DropDownValueModel(
                                    value: status,
                                    name: status?.statusName??"",
                                  );
                                }).toList(),
                                onChanged: (selectedStatusId) {
                                  setState(() {
                                    overallleaddetailsmodel.leadStatus =
                                        selectedStatusId.value;
                                  });
                                },
                              ),
                            )
                          : Container(),

                      sources.isNotEmpty
                          ? Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              child: DropDownTextField(
                                clearOption: false,
                                textFieldDecoration:
                                    overallborderstyle("Source", null, null),
                                initialValue: overallleaddetailsmodel
                                    .leadSource?.sourceName,
                                dropDownList: sources.map((source) {
                                  return DropDownValueModel(
                                    value: source,
                                    name: source.sourceName??"",
                                  );
                                }).toList(),
                                onChanged: (selectedSourceId) {
                                  setState(() {
                                    overallleaddetailsmodel.leadSource =
                                        selectedSourceId.value;
                                  });
                                },
                              ),
                            )
                          : Container(),
                      _users.isNotEmpty
                          ? Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              child: DropDownTextField(
                                clearOption: false,
                                textFieldDecoration:
                                    overallborderstyle("Assign To", null, null),
                                initialValue:overallleaddetailsmodel
                                    .assignedTo!=null?
                                '${overallleaddetailsmodel.assignedTo?.firstName??""} ${overallleaddetailsmodel.assignedTo?.lastName??""}':null,
                                dropDownList: _users.map((user) {
                                  return DropDownValueModel(
                                    value: user,
                                    name: '${user.firstName??""} ${user.lastName??""}',
                                  );
                                }).toList(),
                                onChanged: (selectedUserId) {
                                  overallleaddetailsmodel.assignedTo =
                                      AssignedTo.fromJson(
                                          selectedUserId.value.toJson());
                                  print(overallleaddetailsmodel.assignedTo);
                                },
                              ),
                            )
                          : Container(),

                      _priorities.isNotEmpty
                          ? Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              child: DropDownTextField(
                                clearOption: false,
                                textFieldDecoration:
                                    overallborderstyle("Priority", null, null),
                                initialValue:
                                    overallleaddetailsmodel.priorityId?.name,
                                dropDownList: _priorities.map((priority) {
                                  return DropDownValueModel(
                                    value: priority,
                                    name: priority.name,
                                  );
                                }).toList(),
                                onChanged: (selectedPriorityId) {
                                  setState(() {
                                    overallleaddetailsmodel.priorityId =
                                       PriorityId.fromJson( selectedPriorityId.value.toJson());
                                  });
                                },
                              ),
                            )
                          : Container(),
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        child: TextFormField(
                          initialValue:
                              overallleaddetailsmodel.potentialDealValue,
                          keyboardType: TextInputType.number,
                          decoration: overallborderstyle(
                              "Potential Deal Value", Icons.attach_money, null),
                          onChanged: (value) {
                            setState(() {
                              overallleaddetailsmodel.potentialDealValue =
                                  value;
                            });
                          },
                        ),
                      ),

                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        child: TextFormField(
                          initialValue: overallleaddetailsmodel.actualDealValue,
                          keyboardType: TextInputType.number,
                          decoration: overallborderstyle(
                              "Actual Deal Value", Icons.attach_money, null),
                          onChanged: (value) {
                            setState(() {
                              overallleaddetailsmodel.actualDealValue = value;
                            });
                          },
                        ),
                      ),

                      IncrementDecrementBar(
                        title: "Score",
                        onChanged: (value) {
                          setState(() {
                            overallleaddetailsmodel.score = value;
                          });
                        },
                        initialValue: overallleaddetailsmodel.score,
                      ),

                      Text(
                        "Tags",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                   
                   widget.isNewLead?Container():
                     Container(
  height: 150, // Set height to 100
  width:250,
  padding: EdgeInsets.all(8.0),
  child: ListView(
    children: [
      Wrap(
        spacing: 8.0, // Horizontal spacing between the tags
        runSpacing: 8.0, // Vertical spacing between the lines
        children: buildTagsbydto(overallleaddetailsmodel.tagsDto).map((tagWidget) {
          return Container(
            child: tagWidget, // Each individual tag widget
          );
        }).toList(),
      ),
      IconButton(onPressed:(){
  


  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Assign Tags"),
        content: CustomCheckboxList(
              initialValue:(overallleaddetailsmodel?.tagsDto?.tags??[])
                  .map((value) => CustomCheckBox(value.name ?? "", value))
                  .toList(),
              items:leadcontroller.tags.value
                  .map((value) => CustomCheckBox(value.name ?? "", value))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  print(value);
                  setState(() {
                           overallleaddetailsmodel.tagsDto?.tags =
    (value as List<CustomCheckBox>).map((dropdwnmodel) {
  return dropdwnmodel.value as Tag;
}).toList();

print(overallleaddetailsmodel.tagsDto?.tags);

                  });
        

                 
                } else {
                
                }
              },
            ) ,
        actions: <Widget>[
       
          TextButton(
            child: Text("Close"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );


        



      }, icon:Icon( Icons.add))
    ],
  ),
),

                      ...generateCustomFields(
                          customColumns: overallleaddetailsmodel.customColumns),
                      Container(
                        height: 50,
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        : SkeletonItem();
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

  List<Widget> generateCustomFields({
    required List<CustomColumn>? customColumns,
  }) {
    List<Widget> textFields = [];

    for (var i = 0; i < (customColumns?.length ?? 0); i++) {
      var customColumn = customColumns![i];

      if (customColumn?.type == "lead") {
        TextInputType keyboardType;
        List<DropdownMenuItem<String>>? dropdownItems;
        List<DropDownValueModel>? multidropdownitems;
        Widget textwidget=Container();

        switch (customColumn?.dataType) {
          case "Number":
            keyboardType = TextInputType.number;
            break;
          case "Text":
            keyboardType = TextInputType.name;
            break;
          case "DropDown":
            keyboardType = TextInputType.text;
            dropdownItems = customColumn?.optionValueArray is List<dynamic>
                ? (customColumn?.optionValueArray as List<dynamic>)
                    .toSet()
                    .map((optionValue) => DropdownMenuItem(
                          value: optionValue.toString(),
                          child: Text(optionValue.toString()),
                        ))
                    .toList()
                : null;
                dropdownItems?.add(DropdownMenuItem(child: Text('None'),value:'Nonee',));
            break;
        case 'MultiSelect':
      List<DropDownValueModel> items = (customColumn?.multiSelectOptions ?? []).map<DropDownValueModel>((dynamic e) {
  return DropDownValueModel(name: e['name'], value: e);
}).toList();
multidropdownitems=items;

        break;
        case 'Calendar':
         print('case calender'); 
         print(customColumn.columnName); 
         TextEditingController calcontroller = TextEditingController(); 
        (customColumn.value!=null && customColumn.value!=''&& customColumn.value!= "None")?  calcontroller.text = DateFormat('dd-MM-yyyy, h:mm a') .format(parseDate( customColumn.value)):null;
         textwidget= Container( margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10), child: 
         TextFormField( 
          controller: calcontroller, readOnly: true,
           decoration: overallborderstyle(customColumn.displayName, null, Icons.calendar_today), 
           onTap: () async { print('Tapped');
            DateTime? pickedDateTime = await showOmniDateTimePicker( context: context, initialDate:customColumn.value==null? DateTime.now():DateTime.parse(customColumn.value), firstDate: DateTime(1940), lastDate: DateTime(2101), ); if (pickedDateTime != null) { setState(() { overallleaddetailsmodel.customColumns![i].value = pickedDateTime.toIso8601String(); 
            calcontroller.text = DateFormat('dd-MM-yyyy, h:mm a') .format(pickedDateTime); }); } }, ), ); 
        break;
        case 'Attachment':
          TextEditingController attachController = TextEditingController(); 
           (customColumn.value!=null && customColumn.value!=''&& customColumn.value!= "None")?  attachController.text= customColumn.value :"";
        textFields.add( Container(
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: TextFormField(
                initialValue: customColumn?.value?.toString() ?? '',
                readOnly:  true,
                onTap: ()async{
                  if(attachController.text==''){
                   var k=await FileUploadingManger.uploadFiles();
                   try{

              overallleaddetailsmodel.customColumns![i].value=      k?[0];
              attachController.text=k?[0];
                   }catch(e){

                    print(e);
                   }
                   
                   }else{

  Uri uri = Uri.parse(attachController.text);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    
  }
                   }
                },
          
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: customColumn?.displayName,
                ),
              ),
            ),);
       

        break;
          default:
            keyboardType = TextInputType.text;
        }

        if (dropdownItems != null) {
          textFields.add(
            Builder(
              builder: (BuildContext context) {
                return 
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      child: DropdownButtonFormField<String>(
                        value:
                            customColumn?.value == "" ? null : customColumn?.value,
                        onChanged: (newValue) {
                          overallleaddetailsmodel.customColumns![i].value =newValue=='Nonee'?null:
                              newValue;
                        },
                        hint: Text("${customColumn?.displayName}"),
                        items: dropdownItems,
                        decoration: overallborderstyle(
                              "${customColumn?.displayName}", null, null),
                      ),
                    );
                
              },
            ),
          );
        } else if(customColumn?.dataType=='Calendar'){
textFields.add(textwidget);
        }else if(customColumn?.dataType=='MultiSelect'){

     textFields.add(     Container(
       margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
       child: DropDownTextField.multiSelection(
                textFieldDecoration:overallborderstyle(customColumn?.displayName??'', null, null) ,
                    initialValue: overallleaddetailsmodel.customColumns![i].multiSelectedOption,
                     displayCompleteItem: true,
                    checkBoxProperty: CheckBoxProperty(
                        fillColor: MaterialStateProperty.all<Color>(Colors.red)),
                    dropDownList: multidropdownitems!,
                    onChanged: (val) {
                      overallleaddetailsmodel.customColumns![i].multiSelectedOption=val;
                      
                    },
                  ),
     ),);
        }
        
        else {
          textFields.add(
            Container(
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: TextFormField(
                initialValue: customColumn?.value?.toString() ?? '',
                
                onChanged: (newValue) {
                
                    try {
                      overallleaddetailsmodel.customColumns![i].value =
                          newValue;
                    } catch (e) {
                      print("Invalid number: $newValue");
                    }
                  
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: customColumn?.displayName,
                ),
              ),
            ),
          );
        }
      }
    }

    return textFields;
  }
}
String? isValidIndianMobileNumber(String input) {
 String  cleanedInput = input.replaceAll(RegExp(r'[^0-9]'), '');

  final length = cleanedInput.length;

  if (length == 10) {
  cleanedInput='91'+cleanedInput;
    return cleanedInput;
  } else if (length == 12 && cleanedInput.startsWith('91')) {
    
    return cleanedInput;
  }
  return null;
}


DateTime parseDate(String dateString) {
  List<String> formats = [
    "dd-MM-yyyy, h:mm a",
    "dd/MM/yyyy, h:mm a",
    "dd-MM-yy, h:mm a",
    "MM/dd/yyyy, h:mm a",
    "MM-dd-yyyy, h:mm a",
    "yyyy-MM-ddTHH:mm:ssZ" // ISO format
  ];

  for (String format in formats) {
    try {
      return DateFormat(format).parse(dateString);
    } catch (e) {
      // Continue to next format
    }
  }

  // If none of the formats matched, return the current date and time
  return DateTime.now();
}

