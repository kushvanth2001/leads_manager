import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../domainvariables.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:leads_manager/constants/colorsConstants.dart';
import 'package:leads_manager/constants/networkConstants.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:leads_manager/models/model_application.dart';
import 'package:leads_manager/models/model_document.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/utils/snapPeUI.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;

class TemplatePage extends StatefulWidget {
  final String data;
  final String? mobileNumber;
  List<Application> applications;
  final List<int?> applicationIds;
  String? selectedApplicationName;
  int? selectedApplicationId;
  Document? document;
  bool? file;
  bool fromMessageTab;
  TemplatePage(
      this.data,
      this.mobileNumber,
      this.applications,
      this.applicationIds,
      this.selectedApplicationName,
      this.selectedApplicationId,
      {this.document,
      this.file,
      required this.fromMessageTab});

  @override
  State<TemplatePage> createState() => _TemplatePageState();
}

class _TemplatePageState extends State<TemplatePage> {
  bool _isVisible = true;
  late TextEditingController _controller;
  late FocusNode _focusNode;
  var fileLink;
  @override
  void initState() {
    super.initState();
    final text = utf8.decode(utf8.encode(widget.data));
    _controller = TextEditingController(text: text);

    _focusNode = FocusNode();
    // Request focus on the TextEditingController when the page is called
    _focusNode.requestFocus();
    // fetchApplicationsforLinkedNumber().then((applications) {
    //   if (mounted) {
    //     setState(() {
    //       _applicationIds = applications.map((app) => app.id).toList();
    //       _applications = applications;

    //       // Set initial value of _selectedApplication to first element in applicationNames list
    //       if (_applicationIds.isNotEmpty) {
    //         _selectedApplication = _applicationIds.first;
    //       }
    //     });
    //   }
    // });
  }

  bool _isRequestingPermission = false;

  void _requestPermission() async {
    if (_isRequestingPermission) {
      print("Permission request is already running");
      return;
    }

    _isRequestingPermission = true;

    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    _isRequestingPermission = false;

    final info = statuses[Permission.storage].toString();
    print('Storage permission: $info');
  }

  // bool _isReturningFromSettings = false;
  // void _requestPermission() async {
  //   Map<Permission, PermissionStatus> statuses = await [
  //     Permission.storage,
  //   ].request();

  //   final info = statuses[Permission.storage].toString();
  //   print('Storage permission: $info');
  // _isReturningFromSettings = true;
  // openAppSettings();
  // var status = await Permission.storage.status;
  // if (status.isDenied) {
  //   // We didn't ask for permission yet or the permission has been denied before but not permanently.
  //   await Permission.storage.request();
  // }

  // if (status.isPermanentlyDenied) {
  //   // The user opted to never again see the permission request dialog for this
  //   // app. The only way to change the permission's status now is to let the
  //   // user manually enable it in the system settings.
  //   // Show a dialog box
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Permission Denied'),
  //         content: Text(
  //             'Please allow the app to read files and media for better functionality'),
  //         actions: <Widget>[
  //           ElevatedButton(
  //             child: Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Dismiss the dialog
  //             },
  //           ),
  //           ElevatedButton(
  //             child: Text('Okay'),
  //             onPressed: () {
  //               openAppSettings();
  //               Navigator.of(context).pop(); // Dismiss the dialog
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  // }

 List<dynamic> _selectedFiles = [];

  String? fileType;
  void _handleFileInput() async {
  try {
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
      }

     _uploadFiles(_selectedFiles);
    } else {
      // User canceled file selection or no files were picked
      // Handle this case as appropriate for your app
    }
  } catch (e) {
    // Handle error
    print('Error picking files: $e');
  }
}


   void _uploadFiles(List<dynamic> files) async {
    var clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
    var uri = Uri.parse(
        "https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/files/upload?bucket=taskBucket");
    var request = http.MultipartRequest('POST', uri);
var uuid = Uuid();

    for (var file in files) {
    File k= File(file.path) ;
      request.files.add(http.MultipartFile.fromBytes(
          'files', k.readAsBytesSync(),
          filename:  uuid.v4()
));
    }
    var response = await NetworkHelper()
        .request(RequestType.post, uri, requestBody: request);
    if (response != null && response.statusCode == 200) {
      var responseJson = jsonDecode(response.body);
      // handle response
      print("this is reponseJson $responseJson");
      fileLink = responseJson["documents"][0]["fileLink"];
      print("$fileLink");

      print("after chatcontoller");
    } else {
      throw Exception('Failed to upload files');
    }
  }


  @override
  Widget build(BuildContext context) {
    final fileExtension;
    if (widget.fromMessageTab == false) {
      fileExtension = widget.document?.downloadLink?.split('.').last;
    } else {
      if (fileLink != null) {
        fileExtension = fileLink.split('.').last;
        print("file link is $fileLink");
      } else {
        fileExtension = null;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Message'),
        actions: [
          if (widget.fromMessageTab == true)
            IconButton(
              icon: Icon(Icons.attach_file),
              onPressed: () {
                _handleFileInput();
              },
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.grey[200],
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 8.0),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 231, 231, 231),
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: PopupMenuButton<int>(
                        onSelected: (int newValue) async {
                          if (mounted) {
                            setState(() {
                              widget.selectedApplicationId = newValue;
                            });
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return widget.applicationIds
                              .map<PopupMenuItem<int>>((int? value) {
                            final application = widget.applications.firstWhere(
                              (app) => app.id == value,
                              orElse: () => Application(
                                  id: null, applicationName: 'Unknown'),
                            );
                            final applicationName =
                                application.applicationName ?? 'Unknown';
                            return PopupMenuItem<int>(
                              value: value,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: value == widget.selectedApplicationId
                                      ? Colors.green.withOpacity(0.9)
                                      : Color.fromARGB(255, 231, 231, 231),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: Center(child: Text(applicationName)),
                              ),
                            );
                          }).toList();
                        },
                        offset: Offset(
                          MediaQuery.of(context).size.width / 2 - 100,
                          MediaQuery.of(context).size.height / 2 - 100,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                                child: Text(
                              "From : ${widget.applications.firstWhere((app) => app.id == widget.selectedApplicationId, orElse: () => Application(id: null, applicationName: '')).applicationName}",
                              style: TextStyle(fontSize: 20),
                            )),
                            Padding(
                                padding: const EdgeInsets.only(right: 20.0),
                                child: Image.asset(
                                  "assets/icon/change.jpg",
                                  width: 30,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  if (_isVisible && fileExtension != null)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20, bottom: 10),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 221, 221, 221),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        padding: EdgeInsets.all(10),
                        child: InkWell(
                          onTap: () async {},
                          child: Row(
                            children: [
                              fileExtension == "jpg" || fileExtension == "jpeg"
                                  ? SizedBox(
                                      height: 35,
                                      width: 35,
                                      child: Image.network(
                                        widget.document?.downloadLink ?? "",
                                        height: 35,
                                        width: 35,
                                        fit: BoxFit.fitWidth,
                                        errorBuilder: (BuildContext context,
                                            Object exception,
                                            StackTrace? stackTrace) {
                                          return Image.asset(
                                            "assets/icon/picture.png",
                                            width: 25,
                                          );
                                        },
                                      ),
                                    )
                                  : fileExtension == "png"
                                      ? Image.asset(
                                          "assets/icon/png.png",
                                          width: 25,
                                        )
                                      : fileExtension == "mp4"
                                          ? Image.asset(
                                              "assets/icon/mp4.png",
                                              width: 25,
                                            )
                                          : fileExtension == "pdf" ||
                                                  fileExtension == "PDF"
                                              ? Image.asset(
                                                  "assets/icon/pdf.png",
                                                  width: 25,
                                                )
                                              : fileExtension == "docx"
                                                  ? Image.asset(
                                                      "assets/icon/docx.png",
                                                      width: 25,
                                                    )
                                                  : Image.asset(
                                                      "assets/icon/docs.png",
                                                      width: 25,
                                                    ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget.fromMessageTab == false)
                                      Text(
                                        '${widget.document?.description == null || widget.document?.description == "" ? widget.document?.fileLink : widget.document?.description}',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16),
                                      ),
                                    if (widget.fromMessageTab == true)
                                      Text(
                                        'FileName',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16),
                                      ),
                                    Text(
                                      '$fileExtension',
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 95, 95, 95),
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isVisible = false;
                                    });
                                  },
                                  child: Text(
                                    "remove",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            Color.fromARGB(255, 28, 105, 168)),
                                  ))
                            ],
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 55),
                        child: IconButton(
                          onPressed: () {
                            _sendWhatsAppMessage(
                              
                               Uri.encodeComponent(  _controller.text), widget.mobileNumber);
                          },
                          icon: Image.asset(
                            "assets/icon/whatsappIcon.png",
                            width: 35,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 1.0, horizontal: 16),
                        child: ElevatedButton(
                          style: ButtonStyle(
                              fixedSize:
                                  MaterialStateProperty.all(Size(200, 40)),
                              backgroundColor: buttonCOlor),
                          child: Text('Send',style: TextStyle(color: Colors.white),),
                          onPressed: () async {
                            final selectedApplication =
                                widget.applications.firstWhere(
                              (app) => app.id == widget.selectedApplicationId,
                              orElse: () => Application(
                                  id: null, applicationName: 'Unknown'),
                            );
                            var success;
                            if (widget.fromMessageTab == true) {
                              success = await sendMessage(
                                  widget.mobileNumber,
                                  _controller.text,
                                  selectedApplication,
                                  fileLink,
                                  fileExtension,
                                  _isVisible);
                            } else {
                              success = await sendMessage(
                                  widget.mobileNumber,
                                  _controller.text,
                                  selectedApplication,
                                  widget.document?.downloadLink,
                                  fileExtension,
                                  _isVisible);
                            }

                            if (success == true) {
                              print(
                                  "${widget.document?.downloadLink} is downloadlonk\n\n\n\\n\n\n\\n\\n\n\\n\\n\n\\n\n\n\n\n\n\\n\n\n/n/n//n//n//n/n/ ");
                              Navigator.of(context).pop();
                            } else {
                              SnapPeUI().toastError();
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _sendWhatsAppMessage(message, mobileNumber) async {
  var url = NetworkConstants.getWhatsappUrl(mobileNumber, message);
  if (await canLaunch(url)) {
    await launch(url, enableJavaScript: true, enableDomStorage: true);
  }
}

Future<bool?> sendMessage(
    mobileNumber,
    messageText,
    Application selectedApplication,
    downloadUrl,
    fileExtension,
    _isVisible) async {
  print(
      "${selectedApplication.applicationName} is application name and $downloadUrl \n\\n\n\\n\\n\n and $messageText");
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  String messageType;
  var url = Uri.parse(
    'https://${Globals.DomainPointer}/snappe-services/rest/v1/SnapPeWA/merchants/$clientGroupName/applications/${selectedApplication.applicationName}/send-message',
  );
  if (fileExtension == "jpg" || fileExtension == "jpeg") {
    messageType = "image";
  } else if (fileExtension == null || fileExtension == "") {
    messageType = "text";
  } else {
    messageType = "document";
  }
  if (_isVisible == false) {
    messageType = "text";
    downloadUrl = null;
  }
  var body = jsonEncode({
    "message_type": messageType,
    "application": selectedApplication.toJson(),
    "message_text": messageText,
    "url": downloadUrl,
    "mobile_number": mobileNumber
  });
  var response =
      await NetworkHelper().request(RequestType.post, url, requestBody: body);
  if (response != null && response.statusCode == 200) {
    // Handle successful response
    return true;
  } else {
    // Handle error response
    return false;
  }
}
