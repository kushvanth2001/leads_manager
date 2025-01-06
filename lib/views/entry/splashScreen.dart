import 'dart:ui';

import 'package:flutter/material.dart';
import '../../constants/colorsConstants.dart';
import '../../utils/snapPeRoutes.dart';
import '../../utils/snapPeUI.dart';
import '../../helper/SharedPrefsHelper.dart';

import '../../constants/styleConstants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLogin = false;

  _checkLogin() async {
    await Future.delayed(Duration(seconds: 1));
    SharedPrefsHelper().init();
    _isLogin = await SharedPrefsHelper().getLoginStatus();
    
    print("Is Login from splash screen- $_isLogin");
    if (_isLogin) {
      Navigator.pop(context);
      Navigator.pushNamed(context, SnapPeRoutes.homeRoute);
    } else {
      Navigator.pop(context);
      Navigator.pushNamed(context, SnapPeRoutes.loginRoute);
    }
  }

  @override
  void initState() {
    _checkLogin();
    print(_isLogin);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: Container(
                child: Stack(
                  children: [
                    Opacity(
                        child: Image.asset("assets/icon/logo.png",
                            color: Colors.white),
                        opacity: 0.08),
                    ClipRect(
                        child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                            child: Image.asset("assets/icon/logo.png",
                                fit: BoxFit.cover))),
                  ],
                ),
              ),
            ),
            // SnapPeUI().appBarText("Lead Manager", kBigFontSize),
            SizedBox(height: 5),
            // SnapPeUI().appBarSubText("~ Chutki Mein ~", kMediumFontSize),
          ],
        ),
      ),
    );
  }
}
