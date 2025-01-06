import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:leads_manager/Controller/profile_controller.dart';
import 'package:leads_manager/constants/colorsConstants.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/utils/snapPeUI.dart';

import '../../constants/styleConstants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ProfileController _controller = ProfileController();

    return Container(
      color: kBackgroundColor,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Obx(() => Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        child: Column(
                          children: [
                            
                            Row(
                              children: [
                                Text('Profile Details - ',
                                    style: TextStyle(
                                        color: kPrimaryColor,
                                        fontSize: kBigFontSize,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Text('Merchant Name :    ',
                                    style: TextStyle(
                                        fontSize: kMediumFontSize,
                                        fontWeight: FontWeight.w400)),
                                Expanded(
                                  child: Text(
                                      _controller.merchantProfile.value
                                              .merchantName ??
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
                                Text('Google Pay No :    ',
                                    style: TextStyle(
                                        fontSize: kMediumFontSize,
                                        fontWeight: FontWeight.w400)),
                                Expanded(
                                  child: Text(
                                      _controller
                                              .merchantProfile.value.phoneNo ??
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
                                Text('Bank Account No :    ',
                                    style: TextStyle(
                                        fontSize: kMediumFontSize,
                                        fontWeight: FontWeight.w400)),
                                Expanded(
                                  child: Text(
                                      _controller.merchantProfile.value
                                              .bankAccountNumber ??
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
                                Text('Bank Name :    ',
                                    style: TextStyle(
                                        fontSize: kMediumFontSize,
                                        fontWeight: FontWeight.w400)),
                                Expanded(
                                  child: Text(
                                      _controller
                                              .merchantProfile.value.bankName ??
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
                                Text('IFSC Code :    ',
                                    style: TextStyle(
                                        fontSize: kMediumFontSize,
                                        fontWeight: FontWeight.w400)),
                                Expanded(
                                  child: Text(
                                      _controller.merchantProfile.value.ifsc ??
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
                                Text('UPI Code :    ',
                                    style: TextStyle(
                                        fontSize: kMediumFontSize,
                                        fontWeight: FontWeight.w400)),
                                Expanded(
                                  child: Text(
                                      _controller
                                              .merchantProfile.value.upiCode ??
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
                                Text('GST Number :    ',
                                    style: TextStyle(
                                        fontSize: kMediumFontSize,
                                        fontWeight: FontWeight.w400)),
                                Expanded(
                                  child: Text(
                                      _controller.merchantProfile.value
                                                  .kycDetails ==
                                              null
                                          ? ""
                                          : _controller.merchantProfile.value
                                                  .kycDetails?.gstNo ??
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
                                Text('PAN Number :    ',
                                    style: TextStyle(
                                        fontSize: kMediumFontSize,
                                        fontWeight: FontWeight.w400)),
                                Expanded(
                                  child: Text(
                                      _controller.merchantProfile.value
                                                  .kycDetails ==
                                              null
                                          ? ""
                                          : _controller.merchantProfile.value
                                                      .kycDetails ==
                                                  null
                                              ? ""
                                              : _controller
                                                      .merchantProfile
                                                      .value
                                                      .kycDetails
                                                      ?.panNo ??
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
                                Text('Selling type :    ',
                                    style: TextStyle(
                                        fontSize: kMediumFontSize,
                                        fontWeight: FontWeight.w400)),
                                Expanded(
                                  child: Text(
                                      _controller.merchantProfile.value.mode ??
                                          "",
                                      style: TextStyle(
                                        color: kLightTextColor,
                                        fontSize: kMediumFontSize,
                                      )),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text('Address Details - ',
                                    style: TextStyle(
                                        color: kPrimaryColor,
                                        fontSize: kBigFontSize,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Text('House No :    ',
                                    style: TextStyle(
                                        fontSize: kMediumFontSize,
                                        fontWeight: FontWeight.w400)),
                                Expanded(
                                  child: Text(
                                      _controller.merchantProfile.value.user
                                              ?.houseNo ??
                                          "",
                                      style: TextStyle(
                                        color: kLightTextColor,
                                        fontSize: kMediumFontSize,
                                      )),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text('City :   ',
                                    style: TextStyle(
                                        fontSize: kMediumFontSize,
                                        fontWeight: FontWeight.w400)),
                                Expanded(
                                  child: Text(
                                      _controller.merchantProfile.value.user
                                              ?.city ??
                                          "",
                                      style: TextStyle(
                                        color: kLightTextColor,
                                        fontSize: kMediumFontSize,
                                      )),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text('State :   ',
                                    style: TextStyle(
                                        fontSize: kMediumFontSize,
                                        fontWeight: FontWeight.w400)),
                                Expanded(
                                  child: Text(
                                      _controller.merchantProfile.value.user
                                              ?.state ??
                                          "",
                                      style: TextStyle(
                                        color: kLightTextColor,
                                        fontSize: kMediumFontSize,
                                      )),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text('Pincode :   ',
                                    style: TextStyle(
                                        fontSize: kMediumFontSize,
                                        fontWeight: FontWeight.w400)),
                                Expanded(
                                  child: Text(
                                      (_controller.merchantProfile.value.user
                                                  ?.pincode ??
                                              "")
                                          .toString(),
                                      style: TextStyle(
                                        color: kLightTextColor,
                                        fontSize: kMediumFontSize,
                                      )),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text('Country :   ',
                                    style: TextStyle(
                                        fontSize: kMediumFontSize,
                                        fontWeight: FontWeight.w400)),
                                Expanded(
                                  child: Text(
                                      _controller.merchantProfile.value.user
                                              ?.country ??
                                          "",
                                      style: TextStyle(
                                        color: kLightTextColor,
                                        fontSize: kMediumFontSize,
                                      )),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text('Address Line 1 :   ',
                                    style: TextStyle(
                                        fontSize: kMediumFontSize,
                                        fontWeight: FontWeight.w400)),
                                Expanded(
                                  child: Text(
                                      _controller.merchantProfile.value.user
                                              ?.addressLine1 ??
                                          "",
                                      style: TextStyle(
                                        color: kLightTextColor,
                                        fontSize: kMediumFontSize,
                                      )),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('Business Category - ',
                                  style: TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: kBigFontSize,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Text(_controller.listofCategory.value,
                                    style: TextStyle(
                                      color: kLightTextColor,
                                      fontSize: kMediumFontSize,
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      child: Text(
                        "Log Out",
                        style: TextStyle(
                          color: buttonTextColor,
                          fontSize: kMediumFontSize,
                          fontWeight: FontWeight.bold,
                          fontFamily: fontFamily,
                        ),
                      ),
                      onPressed: () => SnapPeNetworks().logOut(),
                      style: ButtonStyle(
                          backgroundColor: buttonCOlor,
                          fixedSize: MaterialStateProperty.all(Size(150, 40))),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
