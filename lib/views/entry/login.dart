import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:leads_manager/constants/colorsConstants.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/utils/snapPeRoutes.dart';
import 'package:leads_manager/utils/snapPeUI.dart';
import '../../constants/styleConstants.dart';
import 'Registration.dart';
import 'otp.dart';

class LogIn extends StatefulWidget {
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  SnapPeUI snapPeUI = SnapPeUI();
  _btnRegistration() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Registration()));
  }

  // void insertdata() async {
  //   Map<String, dynamic> row = {
  //     DataBaseHelper.cUserName: "Rohit Gupta",
  //     DataBaseHelper.cUserID: 10
  //   };
  //   final id = await DataBaseHelper.instance.insert(row);
  //   print(id);
  // }

  final _mobileController = TextEditingController();

  // _btnGetOTP() async {
  //   var mobile = "91" + _mobileController.text;

  //   //var signature = await SmsAutoFill().getAppSignature;
  //   var signature = ""; //test
  //   print("AppSignature : $signature");

  //   if (await SnapPeNetworks().requestOTP(mobile, signature)) {
  //     Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => Otp(
  //                   mobileNumber: mobile,
  //                 )));
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text("Authentication Error.."),
  //     ));
  //   }
  // }
  _btnGetOTP() async {
    var mobile = "91" + _mobileController.text;

    //var signature = await SmsAutoFill().getAppSignature;
    var signature = ""; //test
    print("AppSignature : $signature");

    if (await SnapPeNetworks().requestOTP(mobile, signature)) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Otp(
                    mobileNumber: mobile,
                  )));
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text("Authentication Error.."),
      // ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SnapPeUI().appBarBig(),
      body: Container(
        height: double.infinity,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SnapPeUI().headingSubheadingText(
                  "Sign In / Sign Up", "Hi there! Nice to see you again."),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 32),
                child: Form(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.phone_android),
                            errorMaxLines: 10,
                            prefix: Text("+91  "),
                            hintText: "Enter Phone Number",
                            labelText: "Phone"),
                        validator: (value) {
                          if (value != null && value.length < 10) {
                            return "Please Enter Valid Phone Number.";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.blue),
                            fixedSize:
                                WidgetStateProperty.all(Size(250, 40))),
                        onPressed: () {
                          _btnGetOTP(); //test
                        },
                        child: Text(
                          "Get OTP",
                          style: TextStyle(
                            color: buttonTextColor,
                            fontSize: kMediumFontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: fontFamily,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      RichText(
                          text: TextSpan(
                        children: [
                          TextSpan(
                              text: "Have an Password ? ",
                              style: TextStyle(color: kLightTextColor)),
                          TextSpan(
                              text: "Sign In",
                              style: TextStyle(color: kLinkTextColor),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // FirebaseCrashlytics.instance.crash();
                                  Navigator.pushNamed(
                                      context, SnapPeRoutes.loginWithPwdRoute);
                                  print("sign In button press.");
                                })
                        ],
                      )),
                      SizedBox(
                        height: 20,
                      ),
                      // RichText(
                      //     text: TextSpan(children: [
                      //   TextSpan(
                      //       text: "New User ",
                      //       style: TextStyle(color: kLightTextColor)),
                      //   TextSpan(
                      //       text: "Registration",
                      //       style: TextStyle(color: kLinkTextColor),
                      //       recognizer: TapGestureRecognizer()
                      //         ..onTap = () {
                      //           _btnRegistration();
                      //         }),
                      // ])),
                      // SizedBox(
                      //   height: 10,
                      // ),
                      snapPeUI.privacyPolicy(context)
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
