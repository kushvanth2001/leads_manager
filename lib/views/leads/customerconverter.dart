import 'dart:convert';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:leads_manager/models/model_customer.dart';
import 'package:leads_manager/views/leads/quotationcreator.dart';
import 'package:leads_manager/views/order/ordersDetails.dart';

import '../../constants/colorsConstants.dart';
import '../../domainvariables.dart';
import '../../helper/SharedPrefsHelper.dart';
import '../../helper/networkHelper.dart';
import '../../models/model_community.dart';
import '../../models/model_customerroles.dart';
import '../../models/model_order_summary.dart';
import '../../utils/snapPeNetworks.dart';

class CustomerConvertor {
  void showComplaintDialog(
    BuildContext context,
    int? pincode,
    String? mobileNumber,
    String? name,
    String? email,
    String? organizationName,
    String? leadId,
  ) {
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
                                   //primarycolorerror
                            // primary: Colors.redAccent, // Background color
                            // onPrimary: Colors.white, // Text color
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
                                   //primarycolorerror
                            // primary: const Color.fromARGB(
                            //     255, 23, 151, 255), // Background color
                            // onPrimary: Colors.white, // Text color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: EdgeInsets.all(12.0),
                          ),
                          onPressed: () async {
                            if(textMobileNumber.text!=""&&textMobileNumber.text!=null){
                            SharedPrefsHelper pref = SharedPrefsHelper();
                            var t = await pref.getDefaultPincode();
                            int? e = int.tryParse(t ?? "if") ?? null;
if(e==null){
  dynamic u=await getPincode();
 e =int.tryParse(u??"k") ??null;
 e!=null? SharedPrefsHelper().setDefaultPincode("$e"):null;

}
                            var res = await checkConsumer(
                                context,
                                pincode != null ? pincode : e ?? null,
                                mobileNumber,
                                name,
                                email,
                                organizationName,
                                leadId);
                            Navigator.of(context).pop();
                            res == true
                                ? QuotationCreator().selectCustomerDialog(
                                    mobileNumber!.length <= 10
                                        ? "91$mobileNumber"
                                        : mobileNumber)
                                : null;
                          }else{
                            Fluttertoast.showToast(msg: "No value in the mobile number Feild");
                          }},
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

  void showCustomerDialog(
      int? pincode,
      List<CustomerRole> customerroles,
      List<Community> communites,
      BuildContext context,
      String? mobileNumber,
      String? name,
      String? email,
      String? organizationName,
      String? leadID) {
    String? leadid = leadID;
    TextEditingController textMobileNumber =
        TextEditingController(text: mobileNumber);
    TextEditingController textName =
        TextEditingController(text: "${name ?? ""}");
    TextEditingController textEmail =
        TextEditingController(text: "${email ?? ""}");
    TextEditingController textOrganizationName =
        TextEditingController(text: organizationName);
    TextEditingController textPincode =
        TextEditingController(text: "${pincode ?? ""}");
    TextEditingController textCustomerRole = TextEditingController(text: "");
    List<String> AffiliateStatusList = [
      "Approved",
      "Suspended",
      "Submitted",
      "Rejected"
    ];
    CustomerRole selectedcustomerrole = CustomerRole(
        id: 1, name: "customer", autoApprove: true, isVisible: true);

    String selectedAffiliateStatus = "Approved";
    Community? selectedcommunity;
    Get.dialog(
      // Add your dialog title here
      AlertDialog(
        insetPadding: EdgeInsets.only(top: 25, left: 15, right: 15, bottom: 15),
        title: Text(
          "Details",
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Container(
          // decoration: BoxDecoration(color: Colors.white,  borderRadius: BorderRadius.circular(20),),

          height: Get.height * 0.8,
          width: 600,

          // height: MediaQuery.of(context).size.height*0.8, // Adjust as needed
          // width: MediaQuery.of(context).size.width*0.5,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10),
                  Text("Name  *"),
                  SizedBox(height: 5),
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
                  Text("Mobile Number *"),
                  SizedBox(height: 5),
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
                  Text("Select Community *"),
                  SizedBox(height: 5),
                  DropDownTextField(
                    clearOption: false,
                    onChanged: (value) {
                      selectedcommunity = communites
                          .firstWhere((element) => element.id == value.value);

                      print(selectedcustomerrole);
                    },
                    textFieldDecoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Select Community", // Completed this part
                    ),
                    dropDownList: communites
                        .map((e) =>
                            DropDownValueModel(name: '${e.name}', value: e.id))
                        .toList(),
                  ),
                  SizedBox(height: 10),
                  Text("Select AffiliateStatus *"),
                  SizedBox(height: 5),
                  DropDownTextField(
                    clearOption: false,
                    initialValue: "Approved",
                    onChanged: (value) {
                      selectedAffiliateStatus = AffiliateStatusList.firstWhere(
                        (element) => element == value.value,
                        orElse: () =>
                            "Approved", // Provide a default value if no match is found
                      );
                    },
                    textFieldDecoration: InputDecoration(
                      border: OutlineInputBorder(),
                      // Completed this part
                    ),
                    dropDownList: AffiliateStatusList.map(
                            (e) => DropDownValueModel(name: '${e}', value: e))
                        .toList(),
                  ),
                  SizedBox(height: 10),
                  Text("Customer Role  *"),
                  SizedBox(height: 5),
                  DropDownTextField(
                    clearOption: false,
                    initialValue: "Customer",
                    onChanged: (value) {
                      selectedcustomerrole = customerroles.firstWhere(
                        (element) => element.id == value.value,
                        orElse: () => CustomerRole(
                            id: 1,
                            name: "customer",
                            autoApprove: true,
                            isVisible: true),
                      );
                      print(selectedcustomerrole);
                    },
                    textFieldDecoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Customer", // Completed this part
                    ),
                    dropDownList: customerroles
                        .map((e) =>
                            DropDownValueModel(name: e.name, value: e.id))
                        .toList(),
                  ),
                  SizedBox(height: 10),
                  Text("PinCode  *"),
                  SizedBox(height: 5),
                  TextField(
                    controller: textPincode,
                    decoration: InputDecoration(
                      labelText: 'Pin Code',
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
                ],
              ),
            ),
          ),
        ),
        actions: [
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
                    Get.back();
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
                    if (selectedcommunity != null &&
                        textMobileNumber.text != "" &&
                        textName.text != "" &&
                        selectedAffiliateStatus != null &&
                        selectedcustomerrole != null &&
                        textPincode.text != "") {
                      leadid != null
                          ? await callConvertCustomer(leadID!)
                          : null;

                      await addCustomer(
                        selectedcustomerrole,
                        communites,
                        selectedcommunity!,
                        leadid,
                        textName,
                        textMobileNumber,
                        textOrganizationName,
                        textPincode,
                        selectedAffiliateStatus,
                      );
                    } else {
                      print(
                          "$selectedcommunity,${textMobileNumber.text},${textName.text} ,${textPincode.text},$selectedAffiliateStatus,$selectedcustomerrole");
                      Fluttertoast.showToast(
                        msg: "Please Select the Required Fields",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                    // refreshCallback();
                    print("above qutation creator");
                  },
                  child: Text("    ADD    ",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          )
        ],
      ),

      useSafeArea: false,
      barrierDismissible: true,
      name: "Details",
    );
  }

  Future<bool> checkConsumer(
      BuildContext context,
      int? pincode,
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
          List<OrderSummaryModel> res = await SnapPeNetworks()
              .customerSuggestionsCallback(mobileNumber ?? "");
          if (res.length != 0) {
            print("its true");
            return true;
          } else {
            print("its false");
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              // The reason WidgetsBinding.instance?.addPostFrameCallback((_) {...}); helped is because it schedules a callback to be called after the current frame has been dispatched.
              callConvertCustomer(leadId!);
              List<CustomerRole> customerroles =
                  await CustomerRole.fetchCustomerRoles();
              String? communityJson =
                  await SharedPrefsHelper().getCommunity() ??
                      await SnapPeNetworks().getCommunity();
              try {
                CommunityModel communityModel =
                    communityModelFromJson(communityJson!);
                List<Community> communities = communityModel.communities == null
                    ? []
                    : communityModel.communities!;

                showCustomerDialog(pincode, customerroles, communities, context,
                    mobileNumber, name, email, organizationName, leadId);
              } catch (e) {
                print("$e");
              }
            });
            return false;
          }
        } else if (response.statusCode == 404) {
          print("its false");
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            // The reason WidgetsBinding.instance?.addPostFrameCallback((_) {...}); helped is because it schedules a callback to be called after the current frame has been dispatched.
            callConvertCustomer(leadId!);
            List<CustomerRole> customerroles =
                await CustomerRole.fetchCustomerRoles();
            String? communityJson = await SharedPrefsHelper().getCommunity() ??
                await SnapPeNetworks().getCommunity();
            try {
              CommunityModel communityModel =
                  communityModelFromJson(communityJson!);
              List<Community> communities = communityModel.communities == null
                  ? []
                  : communityModel.communities!;

              showCustomerDialog(pincode, customerroles, communities, context,
                  mobileNumber, name, email, organizationName, leadId);
            } catch (e) {
              print("$e");
            }
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
      CustomerRole selecteedcustomerrole,
      List<Community> communities,
      Community selectedcommunity,
      String? leadId,
      TextEditingController textName,
      TextEditingController textMobileNumber,
      TextEditingController textOrganizationName,
      TextEditingController textPincode,
      String textAffiliateStatus) async {
    try {
      String clientGroupName =
          await SharedPrefsHelper().getClientGroupName() ?? "";
      // Define the request body
      var requestBody = jsonEncode({
        "status": "OK",
        "firstName": textName.text,
        "middleName": null,
        "lastName": "",
        "gstNo": null,
        "countryCode": null,
        "userName": null,
        "password": null,
        "phoneNo": "${textMobileNumber.text}",
        "community": "${selectedcommunity.name}",
        "relativeLocation": null,
        "alternativeNo1": null,
        "primaryEmailAddress": "",
        "alternativeEmailAddress": null,
        "latitude": null,
        "longitude": null,
        "mapLocation": null,
        "houseNo": null,
        "pincode": "${textPincode.text}",
        "city": null,
        "addressLine1": null,
        "addressLine2": null,
        "addressType": "Home",
        "mobileNumber": null,
        "applicationNo": "${textMobileNumber.text}",
        "token": null,
        "userId": null,
        "isValid": false,
        "isExtendable": false,
        "guid": null,
        "organizationName": null,
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
        "role": "$selecteedcustomerrole",
        "affiliateStatus":
            "${(textAffiliateStatus == "" ? "Approved" : textAffiliateStatus)}"
      });

//Get.back();
      print("mobilenumber..${textMobileNumber.text}");
      //QuotationCreator().selectCustomerDialog(textMobileNumber.text);
      print(requestBody);
      final response = await NetworkHelper().request(
        RequestType.post,
        Uri.parse(
            'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/lead-customer?clientLeadId=$leadId'),
        requestBody: requestBody,
      );
      if (response != null && response.statusCode == 200) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
        prints(response.body);
        Get.back();
        QuotationCreator().selectCustomerDialog(textMobileNumber.text);
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
}

String parseMoblieNUmber(String moblienumber) {
  moblienumber.startsWith("+") ? moblienumber.substring(1) : null;
  if (moblienumber != "" || moblienumber.length < 10) {
    return "";
  } else {
    if (moblienumber.length > 10) {
      moblienumber.substring(moblienumber.length - 10);
    }
    return moblienumber;
  }
}
