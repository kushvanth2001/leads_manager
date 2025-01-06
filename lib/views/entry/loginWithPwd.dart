import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../Controller/login_controller.dart';
import '../../constants/colorsConstants.dart';
import '../../constants/styleConstants.dart';
import 'Registration.dart';
import '../../utils/snapPeNetworks.dart';
import '../../utils/snapPeUI.dart';
//import 'package:sms_autofill/sms_autofill.dart';

import 'otp.dart';

class LogInWithPwd extends StatefulWidget {
  @override
  _LogInWithPwdState createState() => _LogInWithPwdState();
}

class _LogInWithPwdState extends State<LogInWithPwd> {
  LoginController _controller = LoginController();
  final snapPeNetworks = SnapPeNetworks();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  SnapPeUI snapPeUI = SnapPeUI();

  _btnLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email == '' || password == '') {
      SnapPeUI().toastWarning(message: "Please Enter Vaild Input.");
      return;
    }
    _controller.isLoading.value = true;
    // setState(() {
    //   isloading = true;
    // });
    snapPeNetworks.login(context, email, password, _controller);

    // if (await SnapPeNetworks().login(email, password)) {
    //   Navigator.pushNamedAndRemoveUntil(
    //       context, SnapPeRoutes.homeRoute, (route) => false);
    // } else {
    //   // setState(() {
    //   //   isloading = false;
    //   // });
    //   _controller.isLoading.value = false;
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text("Error.."),
    //   ));
    // }
  }

  _btnSendOTP() async {
    var signature = ""; //await SmsAutoFill().getAppSignature;
    print("AppSignature : $signature");
    final email = _emailController.text.trim();
    if (email == '') {
      SnapPeUI().toastWarning(message: "Please enter email Address.");
      return;
    }
    if (await SnapPeNetworks().requestOTP(email, signature)) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Otp(
                    mobileNumber: email,
                  )));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Authentication Error.."),
      ));
    }
  }

  _btnRegistration() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Registration()));
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
                  "Log In", "Hi there! Nice to see you again."),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 32),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          hintText: "Enter Email Id",
                          labelText: "Email Id"),
                    ),
                    TextFormField(
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.password),
                          hintText: "Enter Password",
                          labelText: "Password"),
                    ),
                    SizedBox(height: 30),
                    Obx(() => ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: buttonCOlor,
                              elevation: MaterialStateProperty.all(10),
                              minimumSize:
                                  MaterialStateProperty.all(Size(100, 40))),
                          onPressed: () {
                            _btnLogin();
                          },
                          child: _controller.isLoading.value
                              ? LinearProgressIndicator(
                                  minHeight: 1,
                                  color: Colors.white,
                                )
                              : Text(
                                  "Log In",
                                  style: TextStyle(
                                      fontFamily: fontFamily,
                                      fontWeight: FontWeight.bold,
                                      color: buttonTextColor),
                                ),
                        )),
                    SizedBox(height: 30),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                          text: "Forget Password ? ",
                          style: TextStyle(color: kLightTextColor)),
                      TextSpan(
                          text: "Send OTP",
                          style: TextStyle(color: kLinkTextColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _btnSendOTP();
                            })
                    ])),
                    // SizedBox(
                    //   height: 10,
                    // ),
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
                    //         })
                    // ])),
                    SizedBox(
                      height: 10,
                    ),
                    snapPeUI.privacyPolicy(context)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
