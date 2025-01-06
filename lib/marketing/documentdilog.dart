import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'addpromotionsfunctions.dart';

import '../models/model_document.dart';
import '../widgets/vedioplayerwidget.dart';

class DocumentDialog extends StatefulWidget {
    final List<Document> initialSelectedDocuments;
  final Function(List<Document>) onSave;
   
  DocumentDialog({required this.initialSelectedDocuments,required this.onSave,});
  @override
  _DocumentDialogState createState() => _DocumentDialogState();
}

class _DocumentDialogState extends State<DocumentDialog> {
  List<Document> _selectedDocuments = [];
  late Future<List<Document>> _documentsFuture;
  var k;

  @override
  void initState() {
    super.initState();
    _documentsFuture = AddPromotionsFunctions.fetchDocuments();
    print(widget.initialSelectedDocuments);
    setState(() {
      print("initally selected dox"+widget.initialSelectedDocuments.toString());
      _selectedDocuments=widget.initialSelectedDocuments;
      k=widget.initialSelectedDocuments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Select Documents',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20.0),
            FutureBuilder<List<Document>>(
              future: _documentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No documents found');
                } else {
                  return Container(
                    height: MediaQuery.of(context).size.height*0.7,
                    child: GridView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15.0,
                        mainAxisSpacing: 15.0,
                        mainAxisExtent: 130,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Document document = snapshot.data![index];
                        return GestureDetector(
                          onTap: () {
                            if (!isIdThere(document.id!)) {
                              setState(() {
                                _selectedDocuments.add(document);
                              });
                            }else{
                              setState(() {
                             _selectedDocuments.removeWhere((selectedDoc) => selectedDoc.id == document.id);
                              });
                            }
                      print(_selectedDocuments);
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Card(
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Column(
                                    children: [
                                      Builder(
                                        builder: (context) {
                                          if (document.fileLink!.toLowerCase().endsWith("jpeg") ||
                                              document.fileLink!.toLowerCase().endsWith("png") ||
                                              document.fileLink!.toLowerCase().endsWith("gif")) {
                                            return Image.network(
                                              document.downloadLink!,
                                              width: 60,
                                              height: 60,
                                            );
                                          } else if (document.fileLink!.toLowerCase().endsWith("mp4")) {
                                            return VideoPlayerWidget(
                                              videoUrl: document.downloadLink!,
                                            );
                                          } else {
                                            return Icon(getDocumentTypeFromLink(document.downloadLink!));
                                          }
                                        },
                                      ),
                                      SizedBox(height: 8.0),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 7),
                                        child: SizedBox(
                                          height: 35,
                                          
                                          width: 75,
                                          child: Text(document.description!,)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                  
                  
                          isIdThere(document.id!)
                                  ? Container(
                                      height: 90,
                                      width: 90,
                                      color: Colors.green.withOpacity(0.2),
                                    )
                                  : Container()
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
       
       
       
       
       
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                ElevatedButton(
                  onPressed: () {
                    widget.onSave(_selectedDocuments);
                    Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                ),
                SizedBox(width: 8.0),
                // TextButton(
                //   onPressed: () {
                //    // widget.onCanel(k);
                //     Navigator.of(context).pop();
                    
                //   },
                //   child: Text('Cancel'),
                // ),
              ],
            )   ],
        ),
      ),
    );
  }

  IconData getDocumentTypeFromLink(String fileLink) {
    // Implement logic to determine document type based on file link
    // For example, check file extension or any other patterns
    if (fileLink.endsWith('.mp4')) {
      return Icons.play_arrow;
    } else if (fileLink.endsWith('.jpeg') || fileLink.endsWith('.jpg') || fileLink.endsWith('.png')) {
      return Icons.image;
    } else if (fileLink.endsWith('.docx')) {
      return Icons.insert_drive_file;
    } else if (fileLink.endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    }  else if (fileLink.endsWith('.txt')) {
      return Icons.text_snippet;
    } 
    else {
      return Icons.file_copy;
    }
  }

 bool isIdThere(int id) {
  for (int i = 0; i < _selectedDocuments.length; i++) {
    if (_selectedDocuments[i].id == id) {
      return true;
    }
  }
  return false; // Return false if not found after checking all elements
}
 
}

