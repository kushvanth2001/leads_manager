
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:leads_manager/widgets/customcoloumnwidgets.dart';

import '../../constants/colorsConstants.dart';
import '../../domainvariables.dart';
import '../../helper/SharedPrefsHelper.dart';
import '../../helper/networkHelper.dart';
import '../../models/model_community.dart';
import '../../models/model_consumer.dart';
import '../../models/model_customColumn.dart';
import '../../models/model_order_summary.dart';
import '../../models/model_orders.dart';
import '../../utils/snapPeNetworks.dart';
import '../../utils/snapPeUI.dart';
import 'cart/screen_cart.dart';

class AddQuotation extends StatefulWidget {
  const AddQuotation({Key? key}) : super(key: key);

  @override
  State<AddQuotation> createState() => _AddQuotationState();
}

class _AddQuotationState extends State<AddQuotation> {

    bool switchPendingOrder = false;
  bool isRequiredCompanyName = false;
  bool isNewCustomer = false;
  List<Community> communities = [];
  List<Order>? orders;
  String? _selectedCommunity;
  String _selectedcurrencey='Indian Rupee';
  String? orderJson;
  String? pendingOrderJson;
  String? communityJson;
   TextEditingController searchController = TextEditingController();
  List<Map<String,dynamic>> currencey= [
      { "name": 'Indian Rupee', 'code': 'INR' },
      { "name": 'United States Dollar', 'code': 'USD' },
      { "name": 'Euro', 'code': 'EUR' },
      { "name": 'British Pound Sterling', 'code': 'GBP' },
      { "name": 'Japanese Yen', 'code': 'JPY' },
      { "name": 'Swiss Franc', 'code': 'CHF' },
      { "name": 'Canadian Dollar', 'code': 'CAD' },
      { "name": 'Australian Dollar', 'code': 'AUD' },
      { "name": 'Chinese Yuan Renminbi', 'code': 'CNY' },
      { "name": 'Brazilian Real', 'code': 'BRL' },
      { "name": 'South African Rand', 'code': 'ZAR' },
      { "name": 'Russian Ruble', 'code': 'RUB' },
      { "name": 'Mexican Peso', 'code': 'MXN' },
      { "name": 'Singapore Dollar', 'code': 'SGD' },
      { "name": 'New Zealand Dollar', 'code':'NZD'}];
String selectedPaymenttype="";
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    setdata();
  }
  List<Map<String,dynamic>> paymentTypes=[];
  setdata()async{

  var k  =await fetchPaymentTypes()??[];
  setState(() {
    paymentTypes=k;
  });
  }

  @override
  Widget build(BuildContext context) {
     newCustomerDialog() {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final mobileController = TextEditingController();
    final companyController = TextEditingController();
    final pincodeController = TextEditingController();
    final fullAddressController = TextEditingController();
      
    _selectedCommunity = null;

    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("New Customer"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Visibility(
                      visible: !isNewCustomer,
                      child: TextFormField(
                        controller: mobileController,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        decoration: InputDecoration(
                            hintText: "Enter Customer Mobile",
                            labelText: "Customer Mobile"),
                      ),
                    ),
                    Visibility(
                        visible: isNewCustomer,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: firstNameController,
                              keyboardType: TextInputType.name,
                              maxLength: 50,
                              decoration: InputDecoration(
                                  hintText: "Enter First Name",
                                  labelText: "First Name"),
                            ),
                            TextFormField(
                              controller: lastNameController,
                              keyboardType: TextInputType.name,
                              maxLength: 50,
                              decoration: InputDecoration(
                                  hintText: "Enter Last Name",
                                  labelText: "Last Name"),
                            ),
                            Visibility(
                              visible: isRequiredCompanyName,
                              child: TextFormField(
                                controller: companyController,
                                keyboardType: TextInputType.name,
                                maxLength: 100,
                                decoration: InputDecoration(
                                    hintText: "Enter Company Name",
                                    labelText: "Company"),
                              ),
                            ),
                            DropdownButton<String>(
                              value: _selectedCommunity,
                              iconSize: 25,
                              elevation: 16,
                              hint: Text(
                                "Please choose a Community",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCommunity = newValue!;
                                });
                              },
                              items: communities.map<DropdownMenuItem<String>>(
                                  (Community value) {
                                return DropdownMenuItem<String>(
                                  value: value.communityName ?? "",
                                  child: Text("${value.communityName!}"),
                                );
                              }).toList(),
                            ),
                            TextFormField(
                              controller: pincodeController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              decoration: InputDecoration(
                                  hintText: "Enter pincode",
                                  labelText:
                                      "Pincode"), //errorText: 'value can\'t be empty'
                            ),
                            TextFormField(
                              controller: fullAddressController,
                              keyboardType: TextInputType.name,
                              maxLength: 100,
                              decoration: InputDecoration(
                                  hintText: "Enter Full Address",
                                  labelText: "Address"),
                            ),
                          ],
                        )),
                    Center(
                      child: ElevatedButton(
                        child: Text(isNewCustomer == false ? "Check" : "Save",
                            style: TextStyle(
                              color: Colors.white,
                            )),
                        onPressed: () async {
                          String mobile = mobileController.text.trim();

                          if (!isNewCustomer) {
                            if (mobile.length != 10) {
                              SnapPeUI().toastError(
                                  message: "Please Enter vaild Input.");
                              return;
                            }
                            if (await SnapPeNetworks()
                                .checkIsExistCustomer(mobile)) {
                              SnapPeUI().toastError(
                                  message:
                                      "$mobile This mobile number already exist.");
                              return;
                            }
                            setState(() {
                              print("new customer");
                              isNewCustomer = true;
                            });
                            return;
                          }

                          String fName = firstNameController.text.trim();
                          String lName = lastNameController.text.trim();

                          String company = companyController.text.trim();
                          String pincode = pincodeController.text.trim();
                          String address = fullAddressController.text.trim();

                          if (fName == '' ||
                              lName == '' ||
                              pincode == '' ||
                              address == '' ||
                              _selectedCommunity == '') {
                            SnapPeUI().toastError(
                                message: "Please Enter vaild Input.");
                            return;
                          }

                          ConsumerModel con = new ConsumerModel();
                          con.firstName = fName;
                          con.lastName = lName;
                          con.phoneNo = "91" + mobile;
                          con.organizationName = company;
                          con.pincode = int.parse(pincode);
                          con.community = _selectedCommunity;
                          con.houseNo = address;
                          con.addressType = "Home";
                          con.isValid = false;
                          bool result =
                              await SnapPeNetworks().createNewCustomer(con);
                          if (result) {
                            List<OrderSummaryModel> orders =
                                await SnapPeNetworks()
                                    .customerSuggestionsCallback(
                                        "${con.phoneNo}");
                            Navigator.pop(context);
                            if (orders.length == 0) {
                              SnapPeUI().toastError();
                              return;
                            }
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CartScreen(order: orders[0]),
                                ));
                          }
                        },
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
  

 
    return  Scaffold(
      appBar: AppBar(),
      body:   Container(
            
            child: SingleChildScrollView(
              child: Column(
                children: [
                    SizedBox(
                    height: 5,
                  ),
                  Align(child: Text("Customer Details"),alignment: Alignment.bottomLeft,),
                  SizedBox(
                    height: 5,
                  ),
                  TypeAheadField(
                    noItemsFoundBuilder: (context) {
                      return Text("No Customer Found.");
                    },
                    textFieldConfiguration: TextFieldConfiguration(
                        controller: searchController,
                        decoration:
                            InputDecoration(labelText: "Search customer",prefixIcon:Icon( Icons.search_off_rounded))),
                    suggestionsCallback: (pattern) async {
                      return await SnapPeNetworks()
                          .customerSuggestionsCallback(pattern);
                    },
                    itemBuilder: (context, OrderSummaryModel customer) {
                      return ListTile(
                        title: Text("${customer.customerName}"),
                        subtitle: Text("${customer.customerNumber}"),
                      );
                    },
                    onSuggestionSelected: (OrderSummaryModel customer) {
                      print(customer.customerNumber);
                      //var json = customerModelToJson(customer);
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CartScreen(order: customer),
                          ));
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "- - or - -",
                    style: TextStyle(color: kLightTextColor),
                  ),
                  MaterialButton(
                    child: Text("Create new Customer",
                        style: TextStyle(color: kLinkTextColor)),
                    onPressed: () async {
                      
                      isNewCustomer = false;
                      newCustomerDialog();
                    },
                  ),
                  SizedBox(height: 30,),
             Align(alignment: Alignment.centerLeft ,child: Labeler(childen: singleDropdown(currencey.map((e) => e["name"]).toList(),currencey.map((e) => e["name"]).toList()[0] ,(p0) {_selectedcurrencey=p0;print(_selectedcurrencey); }, 300, 100), lablel: "Currency")), 
                          Align(alignment: Alignment.centerLeft ,child: Labeler(childen: singleDropdown(paymentTypes.isNotEmpty? paymentTypes.map((e) => e["name"]).toList():["k","u"],null ,(p0) {selectedPaymenttype=p0;print(selectedPaymenttype); }, 300, 100), lablel: "Payment Terms")),     
                ],
              ),
            ),
          ),);
  }
}

Future<List<Map<String, dynamic>>?> fetchPaymentTypes() async {
  
    String? appName = await SharedPrefsHelper().getSelectedChatBot();
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    String? userselectedApplicationName =
        await SharedPrefsHelper().getUserSelectedChatbot(clientGroupName);

    // Construct the URL for the network request

  Uri url = Uri.parse("https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/payment-types");

    // Create an instance of the NetworkHelper class
    NetworkHelper networkHelper = NetworkHelper();

    

  try {
    // Make the GET request
   var response = await networkHelper.request(RequestType.get, url);

    // Check if the request was successful
    if (response!.statusCode == 200) {
      // Parse the response JSON
      List<dynamic> paymentTypesJson = jsonDecode(response.body)["paymentTypes"];
      
      // Convert JSON to List<Map<String, dynamic>>
      List<Map<String, dynamic>> paymentTypes = paymentTypesJson.cast<Map<String, dynamic>>();
      
      return paymentTypes;
    } else {
      // Request failed, throw an exception or handle the error
      throw Exception('Failed to load payment types');
    }
  } catch (e) {
    // Handle exceptions
    print('Exception while fetching payment types: $e');
    return null;
  }
}
class Labeler extends StatelessWidget {
final Widget childen;
final String lablel;
  Labeler({Key? key, required this.childen, required this.lablel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      SizedBox(height: 20,),
Text(lablel),
SizedBox(height: 20,),
childen

    ],);
  }
}