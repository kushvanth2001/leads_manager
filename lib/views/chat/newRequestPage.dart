import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:leads_manager/Controller/chat_controller.dart';
import 'package:leads_manager/Controller/leads_controller.dart';
import 'package:leads_manager/views/chat/chatWidget.dart';

import '../../Controller/search_controller.dart' as controller;
import '../../models/model_chat.dart';
import '../../utils/snapPeUI.dart';

class NewRequestPage extends StatefulWidget {
  final List<ChatModel> chatModel;
  final List<dynamic>? templates;
  final String? firstAppName;
  final LeadController leadController;
  final List<String?>? applicationNames;
  final List<ChatModel>? chatModels;
  const NewRequestPage(
      {Key? key,
      required this.chatModel,
      this.firstAppName,
      this.templates,
      required this.leadController,
      this.applicationNames,
      this.chatModels})
      : super(key: key);

  @override
  _NewRequestPageState createState() => _NewRequestPageState();
}

class _NewRequestPageState extends State<NewRequestPage> {
  final textController = TextEditingController();
  controller.SearchController searchController = controller.SearchController();
  bool isloading=false;
Timer? _debounce;
  void refreshData() {
    ChatController().clearTimes();
     //testforcereload
    ChatController().loadData(forcedReload: true);
    // print("data is reloading called refreshdata  \/\n\\n\\n\n\n\n\\n\n\\\n\n\n\n\\n\n\n\n\\n\n\\\n\n\n\n\n\n\n\\n\n\\\n\n\n\n\\n\n\n\n\\n\n\\\n\n\n\n\\n\n\n\n\\n\n\\\n\n\n\n\\n\n\n\n\\n\n\\\n\n\nn/n/n/n///n/n/n/n/n\n\n\n\n\\ ");
  }
  @override
void dispose() {
    _debounce?.cancel();
    super.dispose();
}

  @override
  void initState() {
    super.initState();
    // EasyLoading.show(status: 'Loading...');
    // Future.delayed(Duration(seconds:22), () {
    //   EasyLoading.dismiss();
    // });
    // Future.delayed(Duration(seconds: 6), () async {
    //  // await ChatController().loadData();
    //  setState(() {
    //    isloading=false;
    //  });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        return Future.delayed(
          Duration(seconds: 1),
          () {
            ChatController().clearTimes();
            ChatController().loadData(forcedReload: true);
          },
        );
      },
      child: Column(
        children: [
      
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoSearchTextField(
              controller: textController,
              placeholder: "Search chat with name or number",
              decoration: SnapPeUI().searchBoxDecorationForChat(),
                onSubmitted: (keyword) {
                  searchController.filterChat(widget.chatModel, keyword);
    
         
              },
              onChanged: (keyword){
if(keyword==""){
  searchController.filterChatList.clear();
  EasyLoading.init();
  ChatController().loadData(forcedReload: true);

}
              },
            ),
          ),
          Expanded(
            child:Container(
                child: Obx(
              () => searchController.filterChatList.value.length == 0 &&
                      textController.text.isEmpty
                  ?ChatController.isloading.value?Center(child: CircularProgressIndicator(),) :ListView.builder(
                      // Pass the scrollController from the ChatController class
                      controller: ChatController().scrollController,
                      itemCount: widget.chatModel.length,
                      itemBuilder: ((context, index) {
                        return ChatWidget(
                            chatModel: widget.chatModel[index],
                            firstAppName: widget.firstAppName,
                            templates: widget.templates,
                            onBack: refreshData,
                            leadController: widget.leadController);
                      }))
                  : ListView.builder(
                      // Pass the scrollController from the ChatController class
                      controller: ChatController().scrollController,
                      itemCount: searchController.filterChatList.length,
                      itemBuilder: ((context, index) {
                        return ChatWidget(
                            chatModel: searchController.filterChatList[index],
                            firstAppName: widget.firstAppName,
                            onBack: refreshData,
                            leadController: widget.leadController);
                      })),
            )),
          )
        ],
      ),
    );
  }
}
