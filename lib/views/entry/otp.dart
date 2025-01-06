import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../constants/colorsConstants.dart';
import '../../utils/snapPeNetworks.dart';
import '../../utils/snapPeUI.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../constants/styleConstants.dart';

class Otp extends StatefulWidget {
  final mobileNumber;
  const Otp({Key? key, required this.mobileNumber}) : super(key: key);

  @override
  _OtpState createState() => _OtpState(mobileNumber);
}

class _OtpState extends State<Otp> with CodeAutoFill {
  //with CodeAutoFill
  String? appSignature;
  String? otpCode;
  String mobile = "";
  String? code;
  final snapPeNetworks = SnapPeNetworks();
  _OtpState(mobileNumber) {
    this.mobile = mobileNumber;
  }

  _btnResendOTP() async {
    var signature = await SmsAutoFill().getAppSignature;
    print("AppSignature : $signature");

    if (await SnapPeNetworks().requestOTP(mobile, signature)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Successfully Resend OTP."),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Authentication Error.."),
      ));
    }
  }

  @override
  void codeUpdated() {
    setState(() {
      otpCode = code!;
    });
  }

  @override
  void initState() {
    super.initState();
    listenForCode();

    SmsAutoFill().getAppSignature.then((signature) {
      setState(() {
        appSignature = signature;
        print(appSignature);
      });
    });
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    super.dispose();
    cancel();
  }

  final _codeController = TextEditingController();
  _continueBtn() async {
    var otp = _codeController.text;
    print(otp);
    snapPeNetworks.verifyOTP(context, mobile, otp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SnapPeUI().appBarBig(),
      body: Container(
        height: double.infinity,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 120),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SnapPeUI().headingSubheadingText(
                  "OTP Validation", "Please verify your number with OTP."),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 32),
                child: Column(
                  children: [

                    Pinput(
                length: 4,
                onSubmitted: (String pin) {
                  // Handle OTP submission
                  print('Submitted OTP: $pin');
                },
                focusNode: FocusNode(),
                controller: _codeController,
              
              ),

                    SizedBox(height: 30),
                   ElevatedButton(
  style: ButtonStyle(
    fixedSize: WidgetStateProperty.all(Size(250, 40)),
    backgroundColor: WidgetStateProperty.all(Colors.blue), // Set background color here
  ),
  onPressed: () {
    _continueBtn();
  },
  child: SnapPeUI().appBarText("Continue", kMediumFontSize),
),
                    SizedBox(height: 30),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: "Have any Problem ?  ",
                              style: TextStyle(color: kLightTextColor)),
                          TextSpan(
                              text: "Resend OTP",
                              style: TextStyle(color: kLinkTextColor),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  _btnResendOTP();
                                })
                        ],
                      ),
                    ),
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
