import 'dart:convert';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:leads_manager/models/model_lead.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../../domainvariables.dart';
import '../widgets/calender.dart';

class CustomColumn {
  int? id;
  int? clientGroupId;
  String? columnName;
  String? displayName;
  String? type;
  String? optionValues;
  bool? isActive;
  dynamic value;
  dynamic optionValueArray;
  String? dataType;
  dynamic multiSelectOptions;
  dynamic multiSelectedOption;

  CustomColumn({
    this.id,
    this.clientGroupId,
    this.columnName,
    this.displayName,
    this.type,
    this.optionValues,
    this.isActive,
    this.value,
    this.optionValueArray,
    this.dataType,
    this.multiSelectOptions,
    this.multiSelectedOption
  });

  factory CustomColumn.fromJson(Map<String, dynamic> json) {
    return CustomColumn(
      id: json['id'],
      clientGroupId: json['clientGroupId'],
      columnName: json['columnName'],
      displayName: json['displayName'],
      type: json['type'],
      optionValues: json['optionValues'],
      isActive: json['isActive'],
      value: json['value'],
      optionValueArray: json['optionValueArray'],
      dataType: json['dataType'],
      multiSelectOptions:json['multiSelectOptions'],
      multiSelectedOption:json['multiSelectedOption']
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['clientGroupId'] = this.clientGroupId;
    data['columnName'] = this.columnName;
    data['displayName'] = this.displayName;
    data['type'] = this.type;
    data['optionValues'] = this.optionValues;
    data['isActive'] = this.isActive;
    data['value'] = this.value;
    data['optionValueArray'] = this.optionValueArray;
    data['dataType'] = this.dataType;
    data['multiSelectOptions']=this.multiSelectOptions;
    data['multiSelectedOption']=this.multiSelectedOption;
    return data;
  }



}

 Widget customColumnNumber(String? initalvalue,String? hintText,int maxheight,int maxwidth,TextEditingController? controller){
return Container(
  constraints: BoxConstraints(maxHeight: maxheight*1.0,maxWidth: maxwidth*1.0),
  child: TextFormField(
    controller: controller,
    decoration: InputDecoration(hintText: hintText??"",border: OutlineInputBorder(),),initialValue: initalvalue??"",keyboardType: TextInputType.number,));}



 Widget customColumnText(String? initalvalue,String? hintText,int maxheight,int maxwidth,TextEditingController? controller){
return Container(
  constraints: BoxConstraints(maxHeight: maxheight*1.0,maxWidth: maxwidth*1.0),
  child: TextFormField(
    controller: controller,
    decoration: InputDecoration(hintText: hintText??"",border: OutlineInputBorder()),initialValue: initalvalue??"",));}
     Widget customColumnLargeText(String? initalvalue,String? hintText,int maxheight,int maxwidth,TextEditingController? controller){
return Container(
  constraints: BoxConstraints(maxHeight: maxheight*1.0,maxWidth: maxwidth*1.0),
  child: TextFormField(
    controller: controller,
    decoration: InputDecoration(hintText: hintText??"",border: OutlineInputBorder()),initialValue: initalvalue??"",expands: true,minLines: null,maxLines: null,textAlign: TextAlign.start,),);}
   
 Widget customColumnCalender(String? initalvalue,String? hintText,int maxheight,int maxwidth,TextEditingController? controller,String filter,   VoidCallback onValueChanged(DateTime date1,DateTime date2,String filter),BuildContext context){
String k=filter;
TextEditingController dateController=TextEditingController();
return  Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [DropDownTextField(
    clearOption: false,
    initialValue: "Between",
    onChanged: (value) {
       DateTime date1=DateTime(200);
  
    if (value.value == "Today") {
      date1 = DateTime.now();
    } else if (value.value == "Yesterday") {
      date1 = DateTime.now().subtract(Duration(days: 1));
    } else if (value.value == "Last 7 days") {
      date1 = DateTime.now().subtract(Duration(days: 7));
    } else if (value.value == "This Month") {
      date1 = DateTime(DateTime.now().year, DateTime.now().month, 1);
    } else if (value.value == "Last Month") {
      date1 = DateTime(DateTime.now().year, DateTime.now().month - 1, 1);
    } else if (value.value == "This Year") {
      date1 = DateTime(DateTime.now().year, 1, 1);
    } else if (value.value == "Last Year") {
      date1 = DateTime(DateTime.now().year - 1, 1, 1);
    }

  onValueChanged(date1,DateTime(200),value.value);
    k=value.value;
    },


    textFieldDecoration: InputDecoration(border: OutlineInputBorder(),),
    dropDownList: [
DropDownValueModel(name:"Between" , value: "Between"),
DropDownValueModel(name:"Today" , value: "Today"),
DropDownValueModel(name:"Yesterday" , value: "Yesterday"),
DropDownValueModel(name:"Last 7 days" , value: "Last 7 days"),
DropDownValueModel(name:"This Month" , value: "This Month"),
DropDownValueModel(name:"Last Month" , value: "Last Month"),
DropDownValueModel(name:"This Year" , value: "This Year"),
DropDownValueModel(name:"last Year" , value: "Last Year"),
  ]),
  SizedBox(height: 5,),
  
  
   k=="Between"?  TextFormField(
        onTap:(){
            showDialog(
  context: context,
  builder: (BuildContext context) {
    // Your dialog content goes here
    return  CalendarPage(                    onDateSelected: (start, end) {
                     onValueChanged(start,end,k);
                        dateController.text="${DateFormat('dd/MM/yyyy').format(start)}-${DateFormat('dd/MM/yyyy').format(start)}";} 
);
  },
);
        } ,
        readOnly: true,
        controller: dateController,decoration: InputDecoration(border: OutlineInputBorder(),suffixIcon:    Icon(Icons.calculate_sharp)),):Container()
    

   
    ],);}






 Widget customColumnDropdown(String? initalvalue,String? hintText,int maxheight,int maxwidth,TextEditingController? controller,VoidCallback onValueChanged(String filter)){
  String k=initalvalue??"";
return Container(
  constraints: BoxConstraints(maxHeight: maxheight*1.0,maxWidth: maxwidth*1.0),
  child: DropDownTextField(
    clearOption: false,
    initialValue: "Equals/Contains",
    onChanged: (value) {
       onValueChanged( value.value);
      
    },
    textFieldDecoration: InputDecoration(border: OutlineInputBorder(),hintText: "Select Value"),
    dropDownList: [
DropDownValueModel(name:"Less than" , value: "Less than"),
DropDownValueModel(name:"Equals/Contains" , value: "Equals/Contains"),
DropDownValueModel(name:"Less than Equals to" , value: "Less than Equals to"),
DropDownValueModel(name:"Greater than" , value: "Greater than"),
DropDownValueModel(name:"Greater than or Equals to" , value: "Greater than or Equals to")
  ]));}



 Widget customColumnMultiselect({dynamic initalvalue,String? hintText,int? maxheight, int? maxwidth,TextEditingController? controller,required VoidCallback? onValueChanged(List<dynamic> result),String? considerationvalue,required List<dynamic> initiallist}){
  String k=initalvalue??"";
return MultiSelectDialogField(
  buttonText: hintText==null? null:Text("Search $hintText"),
  onConfirm: (value){
onValueChanged(value );
  },
  initialValue: [initalvalue],items: initiallist.map((e) => MultiSelectItem(e,"${considerationvalue!=null?e.toJson()[considerationvalue]:e}" )).toList(),);}


Future<List<CustomColumn>> fetchCustomColumns(
    int? leadId, bool? isNewlead) async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  try {
    final response = isNewlead == true
        ? await NetworkHelper().request(
            RequestType.get,
            Uri.parse(
                'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/custom-column/lead'),
            requestBody: "",
          )
        : await NetworkHelper().request(
            RequestType.get,
            Uri.parse(
                'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/leads/$leadId'),
            requestBody: "",
          );
    if (response != null && response.statusCode == 200) {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      final parsed = jsonDecode(response.body)['customColumns'];
      return List<CustomColumn>.from(
          parsed.map((json) => CustomColumn.fromJson(json)));
    } else {
      print('Failed to load custom columns ${response?.statusCode}');
      throw Exception('Failed to load custom columns');
    }
  } catch (e) {
    print('Exception occurred: $e');
    throw e;
  }



}
