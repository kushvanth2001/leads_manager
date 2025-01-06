import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatelessWidget {
  final WebViewController controller;

  const WebViewScreen({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
       
         floatingActionButton:  
      
         
        Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            
          padding: EdgeInsets.only(top: 30,left: 6),
                 width: 80,
                 height: 128,
           // Set background color to red
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Center the icons horizontally
            mainAxisSize: MainAxisSize.min,
            children: [
            IconButton( icon: Icon(Icons.arrow_back), iconSize: 35.0, // Increase icon size
             color: Color.fromRGBO(187, 220, 254, 1.0), // Set icon color to white
              onPressed: () async { await controller.goBack(); },
                // Add padding inside the button alignment: Alignment.center, // Center align the icon constraints: BoxConstraints(), // Remove default constraints ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text("Back",style: TextStyle(fontSize: 13,color:Color.fromRGBO(187, 220, 254, 1.0) ),),
              )
            ],
          ),
           ),
        ),
        body: WebViewWidget(controller: controller),
      ),
    );
  }
}
