// import 'dart:async';
// import 'package:flutter/material.dart';
// import '../../helper/SharedPrefsHelper.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import '../../../domainvariables.dart';
// class DashBoardScreen extends StatefulWidget {
//   const DashBoardScreen({Key? key}) : super(key: key);

//   @override
//   State<DashBoardScreen> createState() => _DashBoardScreenState();
// }

// class _DashBoardScreenState extends State<DashBoardScreen> {
//   void initState() {
//     super.initState();
//     // Enable virtual display.
//     //if (Platform.isAndroid) WebView.platform = AndroidWebView();
//   }

//   final url = "https://${Globals.DomainPointer}/";

//   final Completer<WebViewController> _controller =
//       Completer<WebViewController>();
//   late WebViewController _webViewController;

//   @override
//   Widget build(BuildContext context) {
//     _controller.future.then((controller) {
//       _webViewController = controller;
//      // _webViewController.loadUrl(url);
//     });

//     return Scaffold(
//       appBar: AppBar(title: Text("Dashboard")),
//       body: SafeArea(
//         child: Container(
//           child: WebView(
//             debuggingEnabled: true,
//             javascriptMode: JavascriptMode.unrestricted,
//             onWebViewCreated: (WebViewController webViewController) {
//               _controller.complete(webViewController);
//             },
//             onPageStarted: (f) {
//               setCookies(_webViewController);
//             },
//             // onPageFinished: (String url) {
//             //   _controller.future.then((value) => value
//             //       .evaluateJavascript("document.body.style.zoom = '1.5';"));
//             // },
//           ),
//         ),
//       ),
//     );
//   }

//   void setCookies(WebViewController webViewController) async {
//     String? token = await SharedPrefsHelper().getToken();
//     String? clientGroupName = await SharedPrefsHelper().getClientGroupName();
//     String? userId = await SharedPrefsHelper().getMerchantUserId();
//     String tokenCookie =
//         'document.cookie = "client_group_name=${clientGroupName}_$userId; expires=Thu, 01 Mar 3000 00:00:00 UTC; path=/";';
//     String clientCookie = 'document.cookie = "token=$token; path=/";';

//     // await webViewController.evaluateJavascript(tokenCookie);
//     // await webViewController.evaluateJavascript(clientCookie);

//     // print(tokenCookie);
//     // print(clientCookie);
//   }
// }
