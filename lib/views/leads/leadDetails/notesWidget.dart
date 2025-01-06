import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leads_manager/helper/Filepickerhelper.dart';
import 'package:leads_manager/models/model_LeadNotes.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../../../constants/styleConstants.dart';

class NoteWidget extends StatelessWidget {
  final LeadAction? leadAction;
  const NoteWidget({Key? key, this.leadAction}) : super(key: key);
String formatDate(DateTime? createdAt) {
  if (createdAt == null) {
    return "";
  }

  final formatter = DateFormat("dd MMMM yyyy hh:mm a");
  return formatter.format(createdAt.add(Duration(hours: 5,minutes: 30)));
}
  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('note_card_${leadAction?.id}'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                child: Text(
              "Note By - ${leadAction?.createdBy}",
              style: TextStyle(
                  fontSize: kMediumFontSize, fontWeight: FontWeight.bold),
            )),
            Container(
                child: HtmlWidget(
              "${leadAction?.remarks}",
              textStyle: TextStyle(fontSize: kSmallFontSize),
            )),
            Container(
                child: HtmlWidget(
              "Created On : ${formatDate(leadAction?.createdOn!)}",
              textStyle: TextStyle(fontSize: kSmallFontSize),
            )),
Container(
  child: leadAction?.documents != null&&leadAction!.documents!.documents!.isNotEmpty
      ? Container(
        height: 150,
        width: 300,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: leadAction!.documents!.documents!.length,
            itemBuilder: (context, index) {
              final document = leadAction!.documents!.documents![index];
              return Padding(
                padding: const EdgeInsets.only(right: 8)  ,              child: FileUploadingManger.buildAttachmentWidget(document.fileLink??'', context, (value){},candelete: false,maxlines: 2),
              );
            },
          ),
      )
      : Container(),
)


          ],
        ),
      ),
    );
  }
}
//Text(" ${leadAction?.remarks}")