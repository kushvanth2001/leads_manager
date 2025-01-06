// import 'package:get/get.dart';
// import 'package:leads_manager/helper/SharedPrefsHelper.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ThemeController extends GetxController {
//   RxBool isLightTheme = true.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     // Call the startup function to check theme data
//     checkThemeData();
//   }

//   Future<void> checkThemeData() async {
  
//     bool? isLightThemeFromPrefs = await SharedPrefsHelper().getThemeData();
//     if (isLightThemeFromPrefs != null) {
//       // Theme data is available in SharedPreferences
//       isLightTheme.value = isLightThemeFromPrefs;
//     } else {
//       // Theme data is not available, set default theme
//       isLightTheme.value = true;
//       // Save default theme to SharedPreferences
//       await SharedPrefsHelper().setThemeData( true);
//     }
//   }

//   void updateTheme(bool isLight) async {
  
//     isLightTheme.value = isLight;
//     await SharedPrefsHelper().setThemeData( isLight);
//   }
// }
