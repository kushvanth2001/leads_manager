import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatControllerr extends GetxController {
  RxString lastMessage = ''.obs;
  RxInt messageCount = 0.obs;

  void updateChat(String destinationId, String appname) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    lastMessage.value =
        prefs.getString('lastMessage_$destinationId$appname') ?? '';
    messageCount.value =
        prefs.getInt('newMessageCount_$destinationId$appname') ?? 0;

    print('updateChat called for $destinationId$appname');
    print('lastMessage: ${lastMessage.value}');
    print('messageCount: ${messageCount.value}');
  }
}
