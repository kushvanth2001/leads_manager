import 'package:get/get.dart';

class GlobalChatNumbers {
  static final presentAppname = <String>[].obs;

  static void updateAppName(String appName) {
    print("$appName in global chatnumbers method");
    presentAppname.add(appName);
  }

  static void clearAppName() {
    presentAppname.clear();
  }
}
