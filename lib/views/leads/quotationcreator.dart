

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:leads_manager/main.dart';

import '../../constants/colorsConstants.dart';
import '../../models/model_order_summary.dart';
import '../../utils/snapPeNetworks.dart';
import '../order/cart/screen_cart.dart';
import '../order/createquotation.dart';

class QuotationCreator{


  selectCustomerDialog(String mobilenumber) async{

    print("in quotation creator");
    final searchController = TextEditingController();
    try{
      print(mobilenumber);
  List<OrderSummaryModel> l=await SnapPeNetworks().customerSuggestionsCallback(mobilenumber.length<=10?"91$mobilenumber":mobilenumber);
 
  if(l.isNotEmpty!=null){
  
l.map((e) => print("${e.toJson()}"));

  }
OrderSummaryModel?  customer= l.isNotEmpty?l[0]:null;
print("${customer?.toJson()}");

Get.back();
Get.back();
//BuildContext context=navigatorKey.currentContext!;
print(customer);


Map<String,dynamic>? map= await SnapPeNetworks().getCustomerAdressForOrder(customer!.userId.toString()??"0");
if(map!=null){
  customer.address=Address.fromJson(map['address']);
  customer.billingAddress=Address.fromJson(map['billingAddress']);
}
Get.to( QuotationCartScreeen(order: customer!,fromlead: true,));
    }catch(e){print("qutationcartscreenerror$e");}






}
}

getAdressOfUser(String userid){


}