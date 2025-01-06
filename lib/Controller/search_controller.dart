import 'package:get/get.dart';
import 'package:leads_manager/constants/networkConstants.dart';
import '../helper/SharedPrefsHelper.dart';
import '../helper/networkHelper.dart';
import '../models/model_chat.dart';
import '../utils/snapPeUI.dart';
import '../../../domainvariables.dart';
class SearchController extends GetxController {
  RxList<ChatModel> filterChatList = <ChatModel>[].obs;
searchFromApi(String keyword) async {
  String? appName = await SharedPrefsHelper().getSelectedChatBot();
  String? clientGroupName = await SharedPrefsHelper().getClientGroupName();
  String url = "";
  String? userselectedApplicationName =
      SharedPrefsHelper().getUserSelectedChatbot(clientGroupName);
  String id = await SharedPrefsHelper().getChatSessionId() ?? "";
  if (clientGroupName == null || appName == null) {
    SnapPeUI().toastError();
    return null;
  }
  if (userselectedApplicationName == null) {
    url = getSearchChatData(
        clientGroupName,
        appName,
        (DateTime.now().toUtc() .millisecondsSinceEpoch ~/ 1000).toString(),
        (DateTime.now().toUtc() .millisecondsSinceEpoch ~/ 1000).toString(),
        keyword,
        id,
        page: 0);
  } else {
    url = getSearchChatData(
        clientGroupName,
        userselectedApplicationName,
        (DateTime.now().toUtc() .millisecondsSinceEpoch ~/ 1000).toString(),
        (DateTime.now().toUtc() .millisecondsSinceEpoch ~/ 1000).toString(),
        keyword,
        id,
        page: 0);
  }
  try {
    print("listname");
    final response = await NetworkHelper().request(
      RequestType.get,
      Uri.parse(
        url,
      ),
      requestBody: "",
    );

    if (response != null && response.statusCode == 200) {
      if (response != null) {
        List<ChatModel> tempChatList = chatModelFromJson(response.body);
        print("tempchatlist");
        print(tempChatList);
        if (tempChatList.isNotEmpty) {
          print("tempchatlist");
          print(tempChatList);
          tempChatList.forEach((ChatModel chat) {
            String name = (chat.customerName ?? "").toLowerCase();
            String number = "${chat.customerNo}";
            if (name.contains(keyword.toLowerCase()) ||
                number.contains(keyword)) {
              print("$name name ,$number number");
            filterChatList.add(chat);
            }
          });
        }
      }
    }
  } catch (e) {
    print("chaterror$e");
  }
}
  filterChat(List<ChatModel> chatList, String keyword) {
    //     chatList.forEach((ChatModel chat) {
    //   String name = (chat.customerName ?? "").toLowerCase();
    //   String number = "${chat.customerNo}";
    //   if (name.contains(keyword.toLowerCase()) || number.contains(keyword)) {
    //     print("$name name ,$number number");
    //     filterChatList.add(chat);
    //   }
    // });
    filterChatList.clear();
    searchFromApi(keyword);
    print("filterchat is called");
    

  }
}



String getSearchChatData(String clientGroupName, String appName, String tsFrom,
    String tsTo, String keyword, String divigo_session_id,
    {int page = 0}) {
  // String sessionid=await SharedPrefsHelper().getChatSessionId()??"";
  print(
      "https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/applications/$appName/conversations/$tsFrom/$tsTo?page=$page&search_name_or_number=$keyword&divigo_session_id=$divigo_session_id");
  return "https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/applications/$appName/conversations/$tsFrom/$tsTo?page=$page&search_name_or_number=$keyword&divigo_session_id=$divigo_session_id";
  //"https://${Globals.DomainPointer}/snappe-services/messenger/chatbot/rest/v1/app/{appName}/Conversations/<ts_from>/<ts_to>"
}
