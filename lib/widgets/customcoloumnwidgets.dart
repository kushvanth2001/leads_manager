import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

Widget singleDropdown(List<dynamic> listdata,String? considerationvalue, void Function(dynamic) onSelect,double maxwidth,double maxheight,){
bool k=checkType( listdata.length==0?"S": listdata.first); 
return  IgnorePointer(
  ignoring:listdata.length==0?true:false ,
  child:   Container(
  
    constraints: BoxConstraints(maxWidth: maxwidth,maxHeight:maxwidth ),
  
    child:   MultiSelectDropDown(

    //controller:controller ,

      selectedOptions: listdata.length==0?[]:[ValueItem(label:k? listdata[0]:listdata[0].toJson()[considerationvalue],value: listdata[0])] ,
  
  //showClearIcon: false,
  
                  onOptionSelected: (List<dynamic> selectedOptions) {onSelect(selectedOptions[0].value);},
  
    
  
                  options:  listdata.length==0? [ValueItem(label: "",value: "")] :listdata.map(( value) {
  
    
  
             return ValueItem(value: value, label:k?value:value.toJson()[considerationvalue]);
  
    
  
          }).toList(),
  
    
  
                  selectionType: SelectionType.single,
  
    
  
                  chipConfig: const ChipConfig(wrapType: WrapType.wrap),
  
    
  
                  dropdownHeight: 300,
  
    
  
                  optionTextStyle: const TextStyle(fontSize: 16),
  
    
  
                  selectedOptionIcon: const Icon(Icons.check_circle),
  
    
  
                ),
  
  ),
);


}


Widget multiDropdown(List<dynamic> listdata,String? considerationvalue, void Function(dynamic) onSelect,double maxwidth,double maxheight,){
bool k=checkType( listdata.length==0?"S": listdata.first); 
return  Container(
  constraints: BoxConstraints(maxWidth: maxwidth,maxHeight:maxwidth ),
  child:   MultiSelectDropDown(
    
  //showClearIcon: false,
                onOptionSelected: (List<dynamic> selectedOptions) {onSelect(selectedOptions.map((e) => e.value).toList());},
  
                options:  listdata.length==0? [ValueItem(label: "Select",value: "")] :listdata.map(( value) {
  
           return ValueItem(value: value, label:k?value:value.toJson()[considerationvalue]);
  
        }).toList(),
  
                selectionType: SelectionType.multi,
  
                chipConfig: const ChipConfig(wrapType: WrapType.wrap),
  
                dropdownHeight: 300,
  
                optionTextStyle: const TextStyle(fontSize: 16),
  
                selectedOptionIcon: const Icon(Icons.check_circle),
  
              ),
);


}
  bool checkType(dynamic value) {
  // Check if the value is an int, double, string, float, long, or bool
  if (value is int || value is double || value is String || value is bool) {
    // Return true if it is
    return true;
  } else {
    // Return false otherwise
    return false;
  }
}
