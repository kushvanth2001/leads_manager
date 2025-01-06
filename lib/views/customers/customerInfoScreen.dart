
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controller/customerDetails_controller.dart';
import '../../constants/colorsConstants.dart';
import '../../constants/styleConstants.dart';

class CustomerInfoScreen extends StatelessWidget {
  final CustomerDetailscontoller controller;
  const CustomerInfoScreen({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customer Info"),
      ),
      body: Container(
        padding: const EdgeInsets.all(25.0),
        color: Colors.grey[300],
        child: Card(
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Container(
              child: Obx(() => Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 50.0,
                        backgroundImage:
                            AssetImage("assets/images/profile.png"),
                        backgroundColor: Colors.transparent,
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Text('First Name :    ',
                              style: TextStyle(
                                  fontSize: kMediumFontSize, fontWeight: FontWeight.w400)),
                          Expanded(
                            child: Text(
                                controller
                                        .customerDetailsModel.value.firstName ??
                                    "",
                                style: TextStyle(
                                  color: kLightTextColor,
                                  fontSize: kMediumFontSize,
                                )),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text('Last Name :    ',
                              style: TextStyle(
                                  fontSize: kMediumFontSize, fontWeight: FontWeight.w400)),
                          Expanded(
                            child: Text(
                                controller
                                        .customerDetailsModel.value.lastName ??
                                    "",
                                style: TextStyle(
                                  color: kLightTextColor,
                                  fontSize: kMediumFontSize,
                                )),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text('Mobile :    ',
                              style: TextStyle(
                                  fontSize: kMediumFontSize, fontWeight: FontWeight.w400)),
                          Expanded(
                            child: Text(
                                controller.customerDetailsModel.value
                                        .mobileNumber ??
                                    "",
                                style: TextStyle(
                                  color: kLightTextColor,
                                  fontSize: kMediumFontSize,
                                )),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text('Email :    ',
                              style: TextStyle(
                                  fontSize: kMediumFontSize, fontWeight: FontWeight.w400)),
                          Expanded(
                            child: Text(
                                controller.customerDetailsModel.value
                                        .emailAddress ??
                                    "",
                                style: TextStyle(
                                  color: kLightTextColor,
                                  fontSize: kMediumFontSize,
                                )),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text('Full Address:    ',
                              style: TextStyle(
                                  fontSize: kMediumFontSize, fontWeight: FontWeight.w400)),
                          Expanded(
                            child: Text(
                                controller.customerDetailsModel.value
                                        .addressLine1 ??
                                    "",
                                style: TextStyle(
                                  color: kLightTextColor,
                                  fontSize: kMediumFontSize,
                                )),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text('PinCode :    ',
                              style: TextStyle(
                                  fontSize: kMediumFontSize, fontWeight: FontWeight.w400)),
                          Expanded(
                            child: Text(
                                "${controller.customerDetailsModel.value.pincode ?? ""}",
                                style: TextStyle(
                                  color: kLightTextColor,
                                  fontSize: kMediumFontSize,
                                )),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text('Community / Area :    ',
                              style: TextStyle(
                                  fontSize: kMediumFontSize, fontWeight: FontWeight.w400)),
                          Expanded(
                            child: Text(
                                controller
                                        .customerDetailsModel.value.community ??
                                    "",
                                style: TextStyle(
                                  color: kLightTextColor,
                                  fontSize: kMediumFontSize,
                                )),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
