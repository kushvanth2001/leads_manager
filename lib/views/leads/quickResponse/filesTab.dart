import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:leads_manager/models/model_application.dart';
import 'package:universal_html/html.dart' as universal_html;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:leads_manager/models/model_document.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/utils/snapPeUI.dart';
import 'package:leads_manager/views/leads/quickResponse/template.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import '../../../domainvariables.dart';

class FilesTabContent extends StatefulWidget {
  List<Application> applications;
  final List<int?> applicationIds;
  String? selectedApplicationName;
  int? selectedApplicationId;
  List? elements;
  final String? mobileNumber;
  final String? customerName;
  final List<String?> applicationNames;

  FilesTabContent(
    this.applications,
    this.applicationIds,
    this.selectedApplicationName,
    this.selectedApplicationId,
    this.elements,
    this.mobileNumber,
    this.customerName,
    this.applicationNames,
  );

  @override
  _FilesTabContentState createState() => _FilesTabContentState();
}

class _FilesTabContentState extends State<FilesTabContent> {
  SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
  String? response;
  TextEditingController _searchController = TextEditingController();
  List<Document> _filteredDocuments = [];
  List<Document> _documents = [];
  @override
  void initState() {
    super.initState();
    fetchDocuments().then((documents) {
      if (mounted) {
        setState(() {
          _documents = documents;
          _filteredDocuments = documents;
        });
      }
    });
    response = SharedPrefsHelper().getResponse();

    _searchController.addListener(_onSearchChanged);
  }

  void onRefresh() {
    fetchDocuments().then((documents) {
      if (mounted) {
        setState(() {
          _documents = documents;
          _filteredDocuments = documents;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredDocuments = _documents.where((document) {
        return (document.fileLink ?? "")
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            (document.description ?? "")
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    String? clientGroupName = sharedPrefsHelper.getClientGroupNameTest();
    var data = jsonDecode(response ?? "{}");
    String? firstName;
    for (var merchant in data["merchants"]) {
      if (merchant["clientGroupName"] == clientGroupName) {
        firstName = merchant["user"]["firstName"];
        break;
      }
    }
    SnapPeUI snapPeUI = SnapPeUI();

    void _uploadFiles(
        String? base64String, String? description, String? fileName) async {
      var clientGroupName =
          await SharedPrefsHelper().getClientGroupName() ?? "";
      var uri = Uri.parse(
          "https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/document");
      var request = http.Request('POST', uri);
      request.headers['Content-Type'] = 'application/json';
      Map<String, dynamic> file = {
        "id": null,
        "description": description,
        "fileLink": fileName,
        "downloadLink": "",
        "fileData": base64String
      };
      request.body = jsonEncode(file);
      print("request ${fileName} \n\\n\n\n\\nn\\n\n/n/n");
      var response = await NetworkHelper()
          .request(RequestType.post, uri, requestBody: request.body);
      if (response != null && response.statusCode == 200) {
        var responseJson = jsonDecode(response.body);
        // handle response
        print("this is reponseJson $responseJson");
        // widget.onRefresh();
      } else {
        print("$request");
        throw Exception('Failed to upload file');
      }
    }

    void dialogBox(String? base64String, String? fileName) {
      TextEditingController _controller = TextEditingController();

      showDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text('Add Document'),
              content: Column(
                children: [
                  if (fileName != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(fileName!),
                    ),
                  TextFormField(
                      controller: _controller,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder()))
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close')),
                TextButton(
                    onPressed: () {
                      if (base64String != null && fileName != null) {
                        _uploadFiles(
                            base64String!, _controller.text, fileName!);
                      }
                      Navigator.of(context).pop();
                    },
                    child: Text('Add'))
              ],
            );
          });
    }

    File? _selectedFile;
    var fileLink;
    String? fileType;
    Future<List<String>> _handleFileInput() async {
      try {
        if (await Permission.storage.request().isGranted) {
          print("should ask for permission");
          // User granted permission to read external storage
          final result = await FilePicker.platform.pickFiles(
            type: FileType.any,
          );
          if (result != null) {
            PlatformFile file = result.files.first;
            if (file.path != null) {
              setState(() {
                _selectedFile = File(file.path!);
              });
            }
            if (_selectedFile != null) {
              String base64String =
                  base64Encode(await _selectedFile!.readAsBytes());
              dialogBox(base64String, file.name);
              return [base64String, file.name];
            }
          }
        } else {
          // User did not grant permission to read external storage
          // Handle this case as appropriate for your app
          // _requestPermission();
          return [];
        }
      } catch (e) {
        // Handle error
      }
      return [];
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoSearchTextField(
              decoration: snapPeUI.searchBoxDecorationForChat(),
              controller: _searchController,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredDocuments.length,
              itemBuilder: (context, index) {
                final document = _filteredDocuments[index];
                final fileExtension = document.downloadLink?.split('.').last;
                bool file = true;
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 0.15, color: Colors.grey),
                      bottom: BorderSide(width: 0.15, color: Colors.grey),
                    ),
                  ),
                  child: ListTile(
                      leading: fileExtension == "jpg" || fileExtension == "jpeg"
                          ? SizedBox(
                              height: 35,
                              width: 35,
                              child: Image.network(
                                document.downloadLink ?? "",
                                height: 35,
                                width: 35,
                                fit: BoxFit.fitWidth,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  // Appropriate logging or analytics, e.g.
                                  // myAnalytics.recordError(
                                  //   'An error occurred loading "https://example.does.not.exist/image.jpg"',
                                  //   exception,
                                  //   stackTrace,
                                  // );
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
                      title: Text(
                          '${document.description == null || document.description == "" ? document.fileLink : document.description} '),
                      subtitle: Text('${document.fileLink ?? ""}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TemplatePage(
                                  "Dear ${widget.customerName},\n\nSharing ${document.description ?? document.fileLink} file with you.\n \nRegards $firstName.",
                                  widget.mobileNumber,
                                  widget.applications,
                                  widget.applicationIds,
                                  widget.selectedApplicationName,
                                  widget.selectedApplicationId,
                                  document: document,
                                  file: file,
                                  fromMessageTab: false)),
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // IconButton(
                          //   icon: Icon(Icons.file_download),
                          //   onPressed: () async {
                          //     try {
                          //       print("${document.downloadLink} link");
                          //       // first we make a request to the url
                          //       final http.Response r = await http.get(
                          //           Uri.parse(document.downloadLink ?? ""));
                          //       // we get the bytes from the body
                          //       final data = r.bodyBytes;
                          //       // and encode them to base64
                          //       final base64data = base64Encode(data);
                          //       // then we create an AnchorElement with the html package
                          //       final a = universal_html.AnchorElement(
                          //           href:
                          //               'data:application/octet-stream;base64,$base64data');
                          //       // set the name of the file we want to download
                          //       a.download = 'downloaded_file_name';
                          //       // and we click the AnchorElement which downloads the file
                          //       a.click();
                          //       // finally we remove the AnchorElement
                          //       a.remove();
                          //     } catch (e) {
                          //       print(e);
                          //     }
                          //   },
                          // ),
                          IconButton(
                            icon: Icon(Icons.file_download),
                            onPressed: () async {
                              if (await canLaunch(
                                  document.downloadLink ?? "")) {
                                await launch(document.downloadLink ?? "");
                              } else {
                                print(
                                    'Could not launch ${document.downloadLink}');
                              }
                              //   try {
                              //     print("Download button pressed");
                              //     print(
                              //         "Download link: ${document.downloadLink}");
                              //     final http.Response r = await http.get(
                              //         Uri.parse(document.downloadLink ?? ""));
                              //     print("Response status: ${r.statusCode}");
                              //     final data = r.bodyBytes;
                              //     final base64data = base64Encode(data);
                              //     final a = universal_html.AnchorElement(
                              //         href:
                              //             'data:application/octet-stream;base64,$base64data');
                              //     a.download = 'downloaded_file_name';
                              //     a.click();
                              //     a.remove();
                              //     print("File should be downloaded now");
                              //   } catch (e) {
                              //     print('Error during download: $e');
                              //   }
                            },
                          )
                        ],
                      )),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        FloatingActionButton(
          heroTag: "addButton",
          onPressed: () {
            // Add your onPressed code here!
            // dialogBox();
            _handleFileInput();
          },
          child: Icon(Icons.add),
        ),
        SizedBox(
          height: 10,
        ),
        FloatingActionButton(
          heroTag: "refreshButton",
          onPressed: () {
            // Add your onPressed code here!
            onRefresh();
            // _handleFileInput();
          },
          child: Icon(Icons.refresh),
        ),
      ]),
    );
  }
}
