import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:leads_manager/constants/colorsConstants.dart';
import 'package:leads_manager/models/model_chatlist.dart';
import 'package:leads_manager/views/chat/Indetailchatscreen.dart';
import 'package:leads_manager/views/chat/chatDetailsScreen.dart';

class Chatlistwidget extends StatefulWidget {
  final ChatList chatListModel;
  const Chatlistwidget({super.key,required this.chatListModel,});

  @override
  State<Chatlistwidget> createState() => _ChatlistwidgetState();
}

class _ChatlistwidgetState extends State<Chatlistwidget> {
  @override
  Widget build(BuildContext context) {
   String lastTsText = widget.chatListModel.lastTs.value != null
        ? convertDateTimeStr(widget.chatListModel.lastTs.value ~/ 1)
        : '';
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),color:  Colors.white),
      
      child: Column(
        children: [
          Stack(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueGrey,
                  backgroundImage: AssetImage("assets/images/profile.png"),
                ),
                title: Text(
                  "${widget.chatListModel.customerName.value == null || widget.chatListModel.customerName.value == "" ? widget.chatListModel.customerNo.value :widget.chatListModel.customerName.value}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                     // color: Color.fromARGB(255, 49, 49, 49)),
                  )
                ),
                subtitle: Obx(() => widget.chatListModel.previewMessage .value.isNotEmpty
                    ? Text(widget.chatListModel.previewMessage.value, maxLines: 1)
                    : Text("")),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(lastTsText,
                        style: TextStyle(
                            color: kSecondayTextcolor,
                            fontStyle: FontStyle.italic)),
                    Obx(() => widget.chatListModel.messageCount.value > 0
                        ? CircleAvatar(
                            radius: 15,
                            child: Text(
                                widget.chatListModel.messageCount.value.toString()),
                          )
                        : SizedBox.shrink()),
                  ],
                ),
                onTap: () async {
                  widget.chatListModel.messageCount.value=0;
                 Get.to(Indetailchatscreen(chatinfo: widget.chatListModel,));
                },
              ),
            ],
          ),
          // Divider(
          //   height: 1,
          // )
        ],
      ),
    );
  }
}

  String convertDateTimeStr(int timestamp) {
    var format = new DateFormat('dd-MM-yy hh:mm a');
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var str = format.format(date);
    return str;
  }