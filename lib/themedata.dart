import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leads_manager/constants/colorsConstants.dart';

class Themes{

static ThemeData lightthemedata=ThemeData(
            elevatedButtonTheme:ElevatedButtonThemeData(
             style:  ElevatedButton.styleFrom(
      backgroundColor: Colors.blue, // Set the background color to blue
      // Other styling properties (e.g., text color, shape, etc.)
    ),
            ) ,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            canvasColor: const Color(0xFFFFFFFF),
            cardColor: const Color(0xFFF5F5F5),
            dialogBackgroundColor: const Color(0xFFFFFFFF),
            disabledColor: const Color(0xFFBDBDBD),
            dividerColor: const Color(0xFFBDBDBD),
            focusColor: const Color(0xFF1E88E5),
            highlightColor: const Color(0xFFFFCDD2),
            hintColor: const Color(0xFF757575),
            hoverColor: const Color(0xFFE0E0E0),
            indicatorColor: const Color(0xFF1E88E5),
            primaryColor: const Color(0xFF2C3E50),
            primaryColorDark: const Color(0xFF1A242F),
            primaryColorLight: const Color(0xFF34495E),
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFFFFFFFF),
            secondaryHeaderColor: const Color(0xFFA9CCE3),
            shadowColor: const Color(0xFF000000),
            splashColor: const Color(0xFFB3E5FC),
            unselectedWidgetColor: const Color(0xFFBDBDBD),
            textTheme: TextTheme(
              displayLarge: GoogleFonts.oswald(
                fontSize: 72,
                fontWeight: FontWeight.bold,
              ),
              titleLarge: GoogleFonts.merriweather(
                fontSize: 30,
                fontStyle: FontStyle.italic,
              ),
              bodyMedium: GoogleFonts.lato(
                fontSize: 18,
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.blue.shade400,
              titleTextStyle: GoogleFonts.oswald(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            buttonTheme: const ButtonThemeData(
              buttonColor: Colors.blue,
              textTheme: ButtonTextTheme.primary,
            ),
          );
        


static void easyloadingsetup(){
    EasyLoading.instance
    ..indicatorWidget = Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child:  Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(child: Image.asset('assets/images/logo-removebg-preview.png'),),
       
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 4.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ],
        ),
      )
    
    )
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 50.0
      ..radius = 10.0
      ..progressColor = kPrimaryColor
      ..backgroundColor = Colors.transparent
      ..boxShadow = <BoxShadow>[] //to make the background transparent
      ..indicatorColor = kPrimaryColor
      ..textColor = Colors.white
      ..maskColor = Colors.transparent
      ..userInteractions = true
      ..dismissOnTap = true;
}

}
