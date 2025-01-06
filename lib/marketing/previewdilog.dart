

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../models/model_CreateNote.dart';
import '../widgets/chatbubblewidget.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import '../models/model_document.dart';

class PreviewDialog extends StatefulWidget {
  
  final String message;
  List<dynamic> documents;
  PreviewDialog({Key? key,required this.documents, required this.message}) : super(key: key);

  @override
  State<PreviewDialog> createState() => _PreviewDialogState();
}

class _PreviewDialogState extends State<PreviewDialog> {
List<dynamic> docs=[];
List<String> _buttondata=[];
@override
void initState() {
  super.initState();
  setState(() {
  
    docs=List<dynamic>.from(widget.documents ?? []);
 widget.documents;
    docs.add((fileData: widget.message));
 _buttondata=   extractPatterns(widget.message);
    print(docs);
  });
  
}List<String> extractPatterns(String input) {
  // Define your pattern using RegExp to match text between square brackets
  RegExp pattern = RegExp(r'\[([^,\]]+),');

  // Find all matches in the input string
  Iterable<RegExpMatch> matches = pattern.allMatches(input);

  // Extract and return the matched substrings as a list
  return matches.map((match) => match.group(1)!).toList();
}


  @override
  Widget build(BuildContext context) {
 return Card(
   child: Container(
    height:550,
    width: 300,
    decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/mobilebg.jpg"),fit: BoxFit.fitHeight)),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(0, 65, 0, 10),
      child: Column(children: [
        
      
        
        Container(height: 415,width: 248,decoration: BoxDecoration(image: DecorationImage(image:AssetImage("assets/images/whatsappbgimg.jpg"),fit: BoxFit.cover ) 
      
      
      ),
      child: ListView.builder(
        dragStartBehavior : DragStartBehavior.down,
  shrinkWrap: true,
  
  itemCount: docs.length,
  itemBuilder: (context, index) {
    return _buildDocumentChatBubble(docs[index]);
  },
),
      )]),
    ),
    
    ),
 );  

  }


   Widget _buildDocumentChatBubble(dynamic document) {
    
    String downloadLink= document.downloadLink==null?"":document.downloadLink!.toLowerCase();
String filedata= document.fileData==null?"":document.fileData!.toLowerCase();
    Widget leadingIcon;
    if (downloadLink.endsWith('jpeg' ) || downloadLink.endsWith( 'jpg' )|| downloadLink.endsWith('png')) {
      return Container(
            height: 100,
            width: 100,
            child:
            
             BubbleNormalImage(
              id: 'id001',
              image:  Image.network(document.downloadLink!),
              color: Colors.green.withOpacity(0.5),
              tail: true,
              delivered: true,
            ),
          );
          
    
      
     
    } else if (downloadLink.endsWith('mp4')) {
     return  Container(
        height: 100,
        width: 100,
        child: BubbleNormalImage(
          id: 'id001',
          image:  Icon(Icons.video_library,size: 100,),
          color: Colors.green.withOpacity(0.5),
          tail: true,
          delivered: true,
        ),);
     
     // Display video icon for mp4
    } else if(downloadLink.endsWith('docx' )|| 
    downloadLink.endsWith('.xls') ||
    downloadLink.endsWith('.xlsm') ||
    downloadLink.endsWith('.xlsb') ||
    downloadLink.endsWith('.xltx') ||
    downloadLink.endsWith('.xltm') ||
    downloadLink.endsWith('.csv') ||
    downloadLink.endsWith('.xlk') ||
    downloadLink.endsWith('.xla') ||
    downloadLink.endsWith('.xlam') ||
    downloadLink.endsWith('.ods') ||
     downloadLink.endsWith('.txt') ) {
      return  BubbleNormalImage(
          id: 'id001',
          image:  
       Icon(Icons.insert_drive_file,size: 100,),
          color: Colors.green.withOpacity(0.5),
          tail: true,
          delivered: true,
        );
      
    
    }else if(downloadLink.endsWith('.pdf')){
return  BubbleNormalImage(
          id: 'id001',
          image:  
       Icon(Icons.picture_as_pdf,size: 100,),
          color: Colors.green.withOpacity(0.5),
          tail: true,
          delivered: true,
        );

    }
    
    
    
    else{
      print(_buttondata);
      return Expanded(
        

        child: CustomchatBubble(
          buttons: _buttondata,
             color: Colors.green.withOpacity(0.3),
          id: '1001',
          delivered: true,
          tail: true,
          image: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(filedata),
          )));
    }
   }

}