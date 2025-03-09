import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:leads_manager/domainvariables.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:leads_manager/models/model_LeadStatus.dart';
import 'package:leads_manager/models/model_Merchants.dart';
import 'package:leads_manager/models/model_customColumn.dart';
import 'package:leads_manager/models/model_customerroles.dart';
import 'package:leads_manager/models/model_priority.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';


class AddOpportunityScreen extends StatefulWidget {
  final Map<String, dynamic>? editedData;
   
  AddOpportunityScreen({this.editedData});
  @override
  _AddOpportunityScreenState createState() => _AddOpportunityScreenState();
}

class _AddOpportunityScreenState extends State<AddOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isloading=true;

List<Priority> priorites=[];
List<dynamic> customcoloumnsbyoppr=[];
List<CustomerRole> customerroles=[];
List<dynamic> communities=[];
 List<User> users=[];
 List<dynamic> status=[];
 TextEditingController expectedDateController =TextEditingController();
  Map<String, dynamic> formData = {
  
  };

  @override
  void initState() {
    super.initState();
   
initAsync();

  }
initAsync()async{
  try{
    customcoloumnsbyoppr=await SnapPeNetworks().customColumnForOpp0rtunitiy();
  customerroles=await CustomerRole.fetchCustomerRoles();
if (widget.editedData != null && widget.editedData!.containsKey('expectedDate') && widget.editedData!['expectedDate'] != null) {
  expectedDateController.text = DateFormat('dd-MM-yyyy, h:mm a').format(DateTime.parse(widget.editedData!['expectedDate']));
} else {
  expectedDateController.text = "";
}

if(widget.editedData!=null){
formData=widget.editedData!;
formData['customColumns']==null?formData['customColumns']= customcoloumnsbyoppr:null;
}else{

formData['customColumns']= customcoloumnsbyoppr;
}

   String? com=     await SharedPrefsHelper().getCommunity() ??
          await SnapPeNetworks().getCommunity();
          com!=null?communities=jsonDecode(com)['communities']:null;


priorites=await fetchPriorities();
users=await SnapPeNetworks().fetchUsers();
status=await getAllLeadsStatus();

}

catch(e){
print("error$e");

}
setState(() {
  isloading=false;
});

print(customerroles);
print(customcoloumnsbyoppr);
print(communities);
}
  @override
  Widget build(BuildContext context) {
    return isloading? Center(child: CircularProgressIndicator(strokeWidth: 4,color: Colors.black,),):Container(
      margin: EdgeInsets.only(top: 16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Details Section
              Section(
                title: "Basic Details",
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      readOnly:   (widget.editedData!=null && (formData["customerName"]!=null && formData["customerName"]!="" )) ? true:false,
                      initialValue: formData["customerName"],
                      decoration: overallborderstyle("Customer Name",null,null),
                      onChanged: (value) => formData["customerName"] = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter customer name';
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      readOnly: (widget.editedData!=null && (formData["mobileNumber"]!=null)) ? true:false,
                      initialValue: formData["mobileNumber"],
                      decoration: overallborderstyle("Mobile Number",null,null), 
                      keyboardType: TextInputType.phone,
                      onChanged: (value) => formData["mobileNumber"] = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter mobile number';
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                       margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      initialValue: formData["organizationName"],
                      decoration:overallborderstyle("Organization Name",null,null),
                      onChanged: (value) => formData["organizationName"] = value,
                     
                    ),
                  ),
                  Container(
                       margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      initialValue: formData["opportunityName"],
                      decoration: overallborderstyle("Opportunity Name",null,null),
                      onChanged: (value) => formData["opportunityName"] = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter opportunity name';
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                       margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: DropDownTextField(
                      
                      clearOption: false,
                      onChanged: (value) => formData["assignedTo"] = value.value.toJson(),
                     searchDecoration: overallborderstyle("Search",null,null),
                      dropDownList:users.map((e){
                        return  DropDownValueModel(name: '${e.firstName??''} ${e.lastName} ', value: e);
                      }).toList()  ,
                      textFieldDecoration: overallborderstyle("Assigned To",null,null),
                    ),
                  ),
                  Container(
                       margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: DropDownTextField(
                      
                      clearOption: false,
                      onChanged: (value) => formData["leadStatus"] = value.value,
                                  
                      dropDownList: status.map((e){
                        return  DropDownValueModel(name: '${e['statusName'] }', value: e);
                      }).toList() ,
                      textFieldDecoration: overallborderstyle("Status",null,null),
                    ),
                  ),
                ],
              ),
              // Advanced Details Section
              Section(
                title: "Advanced Details",
                children: [

         Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
           child: TextFormField( 
          
          controller: expectedDateController
          , readOnly: true,
             decoration: overallborderstyle('Expected Date', null, Icons.calendar_today), 
             onTap: () async { print('Tapped');
              DateTime? pickedDateTime = await showOmniDateTimePicker( context: context, firstDate: DateTime(1940), lastDate: DateTime(2101), ); 
              if (pickedDateTime != null) {
                
              

                 setState(() {
              
                   formData['expectedDate'] = pickedDateTime.toIso8601String(); 
            expectedDateController.text = DateFormat('dd-MM-yyyy, h:mm a') .format(pickedDateTime); 
            }); } }, ),
         ), 


                  Container(
                       margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      initialValue: formData["potentialDealValue"],
                      decoration: overallborderstyle('Potential Deal Value', null, null),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => formData["potentialDealValue"] = value,
          
                    ),
                  ),
                  Container(
                       margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      initialValue: formData["actualDealValue"],
                      decoration: overallborderstyle('Actual Deal Value', null, null),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => formData["actualDealValue"] = value,
                 
                    ),
                  ),
               
                  Container(
                       margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      initialValue: formData["description"],
                      decoration: overallborderstyle('Description', null, null),
                      maxLines: 5,
                      onChanged: (value) => formData["description"] = value,
                      
                    ),
                  ),
                ],
              ),

              //section three

              Section(title: 'Custom Columns', children:generateCustomFields(customColumns: formData['customColumns'].map((e){
              return  CustomColumn.fromJson(e);
              }).toList() ) ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async{
                  if (_formKey.currentState!.validate()) {
                    // Process the data
                    print(formData); // For demonstration, print the formData
                    
bool k =await SnapPeNetworks().postoppurtunity(formData);
if(k){
  Fluttertoast.showToast(msg: "Opportunity Saved ✅" );
Get.back(result: true);
}else{
  Fluttertoast.showToast(msg: "Error while Sending  Opportunity please try again");
}
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );

  }


  List<Widget> generateCustomFields({
    required List<dynamic>? customColumns,
  }) {
    List<Widget> textFields = [];

    for (var i = 0; i < (customColumns?.length ?? 0); i++) {
      var customColumn = customColumns![i];

      
        TextInputType keyboardType;
        List<DropdownMenuItem<String>>? dropdownItems;
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
        case 'Calendar':
         print('case calender'); 
         print(customColumn.columnName); 
         TextEditingController calcontroller = TextEditingController(); 
        (customColumn.value!=null && customColumn.value!=''&& customColumn.value!= "None")?  calcontroller.text = DateFormat('dd-MM-yyyy, h:mm a') .format(DateTime.parse( customColumn.value)):null;
         textwidget= Container( margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10), child: 
         TextFormField( 
          controller: calcontroller, readOnly: true,
           decoration: overallborderstyle(customColumn.displayName, null, Icons.calendar_today), 
           onTap: () async { print('Tapped');
            DateTime? pickedDateTime = await showOmniDateTimePicker( context: context, initialDate:customColumn.value==null? DateTime.now():DateTime.parse(customColumn.value), firstDate: DateTime(1940), lastDate: DateTime(2101), ); 
            if (pickedDateTime != null) {
              print(pickedDateTime);
               setState(() { 
                formData['customColumns'][i]['value'] = pickedDateTime.toIso8601String(); 
            calcontroller.text = DateFormat('dd-MM-yyyy, h:mm a') .format(pickedDateTime); }); } }, ), ); 
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
                          formData['customColumns'][i]['value'] =newValue=='Nonee'?null:
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

        }
        
        else {
          textFields.add(
            Container(
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: TextFormField(
                initialValue: customColumn?.value?.toString() ?? '',
                
                onChanged: (newValue) {
                
                    try {
                      formData['customColumns'][i]['value'] =
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

    return textFields;
  }


  Future<List<Priority>> fetchPriorities() async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  try {
    final response = await NetworkHelper().request(
      RequestType.get,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/priorities'),
      requestBody: "",
    );
    if (response != null && response.statusCode == 200) {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      final parsed = jsonDecode(response.body)['allPriorities'];
      return List<Priority>.from(parsed.map((json) => Priority.fromJson(json)));
    } else {
      print('Failed to load priorities ${response?.statusCode}');
      throw Exception('Failed to load priorities');
    }
  } catch (e) {
    print('Exception occurred: $e');
    throw e;
  }
}


Future<List<dynamic>> getAllLeadsStatus() async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  try {
    final response = await NetworkHelper().request(
      RequestType.get,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/lead-status'),
      requestBody: "",
    );
    if (response != null && response.statusCode == 200) {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      final parsed = jsonDecode(response.body)['allLeadsStatus'];
      return parsed;
    } else {
      print(
          'Failed to load all leads status with status code: ${response?.statusCode}');
      throw Exception('Failed to load all leads status');
    }
  } catch (e) {
    print('Exception occurred: $e');
    throw e;
  }
}

}

class Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Column(children: children),
      ],
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