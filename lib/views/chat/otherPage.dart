import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:leads_manager/Controller/leads_controller.dart';
import '../../Controller/search_controller.dart';
import '../../models/model_chat.dart';
import '../../utils/snapPeUI.dart';
import 'chatWidget.dart';

class OtherPage extends StatelessWidget {
  final List<ChatModel> chatModel;
  Timer? _debounce;
  String? firstAppName;
  final LeadController leadController;
  OtherPage(
      {Key? key,
      required this.chatModel,
      required this.leadController,
      this.firstAppName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    SearchController searchController = SearchController();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CupertinoSearchTextField(
            controller: textController,
            placeholder: "Search chat with name or number",
            decoration: SnapPeUI().searchBoxDecorationForChat(),
                   onChanged: (keyword) {
                if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
             searchController.filterChat(chatModel, keyword);
    });
         
              },
          ),
        ),
        Expanded(
            child: Container(
          child: Obx(() => (searchController.filterChatList.value.length == 0 &&
                  textController.text.isEmpty)
              ? (chatModel.length > 0
                  ? ListView.builder(
                      itemCount: chatModel.length,
                      itemBuilder: ((context, index) {
                        return ChatWidget(
                          chatModel: chatModel[index],
                          isOther: true,
                          leadController: leadController,
                          firstAppName: firstAppName,
                        );
                      }))
                  : Center(
                      child: Text(
                      'NO CHATS !',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic),
                    )))
              : (searchController.filterChatList.length > 0
                  ? ListView.builder(
                      itemCount: searchController.filterChatList.length,
                      itemBuilder: ((context, index) {
                        return ChatWidget(
                          chatModel: searchController.filterChatList[index],
                          isOther: true,
                          leadController: leadController,
                          firstAppName: firstAppName,
                        );
                      }))
                  : Center(
                      child: Text(
                      'NO CHATS !',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic),
                    )))),
        ))
      ],
    );
  }
}
