import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leads_manager/domainvariables.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:mime/mime.dart';
class FileUploadingManger{



   static Future<List<dynamic>?>uploadFiles() async {
var _selectedFiles=[];
  String? fileType;

try{

  
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      
        _selectedFiles = result.files;
      

      for (var file in _selectedFiles) {
        String? filePath = file.path;
        String? mimeType;

        if (filePath != null) {
          mimeType = lookupMimeType(filePath);
          // Use the value of 'mimeType' here
        }

        if (mimeType != null) {
          List<String> parts = mimeType.split('/');
          fileType = parts[0];
          // Use the value of 'fileType' here
        } else {
          // Handle the case where 'mimeType' is null
          fileType = null;
        }
      }}

}catch(e){


throw "Unable to pick files in filepicker helper$e";
}






    var clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
    var uri = Uri.parse(
        "https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/files/upload?bucket=taskBucket");
    var request = http.MultipartRequest('POST', uri);
var uuid = Uuid();

    for (var file in _selectedFiles) {
    File k= File(file.path) ;
      request.files.add(http.MultipartFile.fromBytes(
          'files', k.readAsBytesSync(),
          filename:uuid.v4()+ '/' +file.path.split('/').last
));
    }
    var response = await NetworkHelper()
        .request(RequestType.post, uri, requestBody: request);
    if (response != null && response.statusCode == 200) {
      var responseJson = jsonDecode(response.body);
      // handle response
      print("this is reponseJson $responseJson");
    var  fileLink = responseJson["documents"].map((e){

return e['fileLink'];

    }).toList();
    
    //responseJson["documents"][0]["fileLink"];
      

    return fileLink;
    } else {
      
      throw Exception('Failed to upload files');

    }
  }


 static Widget buildAttachmentWidget(String link, BuildContext context, Function(String?) onDelete,{bool candelete=true,maxlines=5}) {
    Widget leadingWidget;

    if (link.endsWith('.jpg') || link.endsWith('.png')) {
      leadingWidget = Container(
        height: 70,width: 70,
        child: Image.network(link, fit: BoxFit.cover));
    } else if (link.endsWith('.mp4')) {
      leadingWidget = Icon(Icons.videocam,);
    } else if (link.endsWith('.mp3')) {
      leadingWidget = Icon(Icons.audiotrack);
    } else if (link.endsWith('.pdf')) {
      leadingWidget = Icon(Icons.picture_as_pdf);
    } else {
      leadingWidget = Icon(Icons.insert_drive_file);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leadingWidget,
      candelete?  IconButton(
          onPressed: () async {
            onDelete(link);
          },
          icon: CircleAvatar(
            backgroundColor: Colors.red,
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ):Container(),
        textWrapper(link,maxlines),
      ],
    );
  }

  static Widget textWrapper(String link,int maxlines) {
    return Container(
      height: 70,
      width: 70,
      child: Wrap(
        children: [
          Text(
            '${link.split('/') .last}',
            maxLines: maxlines,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );}
}