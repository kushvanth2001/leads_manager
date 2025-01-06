

import 'dart:convert';
import 'dart:io';
// import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import '../helper/SharedPrefsHelper.dart';
import '../helper/networkHelper.dart';
import '../models/model_document.dart';
import '../../../domainvariables.dart';
class AddPromotionsFunctions{

   static  List<String> getColumnNamesFromExcel(String filePath) {
  List<String> columns = [];

  try {
    var k;
    var excel = k;
    // Excel.decodeBytes(File(filePath).readAsBytesSync());

    if (excel.tables.isNotEmpty) {
      // Assuming the first table in the Excel sheet is the one you're interested in
      var table = excel.tables[excel.tables.keys.first]!;

      // Assuming the first row in the table contains the column names
      if (table.maxColumns > 0) {
        // Extracting column names from the first row
        for (var col in table.row(0)) {
          columns.add(col?.value.toString() ?? '');
        }
      }
    }
  } catch (e) {
    print('Error reading Excel file: $e');
  }

  return columns;
}


 static Future<String> findFilePath(String fileName) async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;

      // List all files in the app documents directory
      List<FileSystemEntity> files = Directory(appDocPath).listSync();

      // Search for the file by name
      for (var file in files) {
        if (file is File && file.path.endsWith(fileName)) {
          return file.path;
        }
      }
    } catch (e) {
      print('Error finding file: $e');
    }

    return '';
  }
 static Future<List<String>> fetchContacts(String listName) async {
   String? token = await SharedPrefsHelper().getToken();
    String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";
    try {
      print("listname"+listName);
      final response = await NetworkHelper().request(
        RequestType.get,
        Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services-pt/rest/v1/merchant/$clientGroupName/contacts?list_name=$listName&limit=1&page_no=0&sort_order=asc',
        ),
        requestBody: "",
      );

      if (response != null && response.statusCode == 200) {
        final parsed = json.decode(response.body);

        if (parsed != null && parsed is Map<String, dynamic>) {
          // Process the response here
          // Example: Parse the response into a list of Contact objects
          final Map<String,dynamic> contactsheaders = parsed['contacts']!=[]?parsed['contacts'][0]:[];
        print(contactsheaders.keys.toList());
          return contactsheaders.keys.toList();
        } else {
          print('Invalid response format');
          throw Exception('Invalid response format');
        }
      } else {
        print('Failed to load contacts');
        throw Exception('Failed to load contacts');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw e;
    }
  }
 static Future<List<Document>> fetchDocuments() async {
    String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";
    try {
      final response = await NetworkHelper().request(
        RequestType.get,
        Uri.parse('https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/documents'),
        requestBody: "",
      );

      if (response != null && response.statusCode == 200) {
        final parsed = json.decode(response.body);

        if (parsed != null && parsed is Map<String, dynamic>) {
          final List<dynamic> documentsData = parsed['documents'];

          if (documentsData != null && documentsData.isNotEmpty) {
            final List<Document> documents = documentsData.map<Document>((doc) {
              return Document.fromJson(doc);
            }).toList();

            return documents;
          } else {
            print('No documents found');
            return [];
          }
        } else {
          print('Invalid response format');
          throw Exception('Invalid response format');
        }
      } else {
        print('Failed to load documents');
        throw Exception('Failed to load documents');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw e;
    }
  }
void _requestPermission() async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.
      status = await Permission.storage.request();
    }

   
  }

  

 List<dynamic> _selectedFiles = [];

  String? fileType;
  void handleFileInput() async {
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

     uploadFilesAndGetDocuments(_selectedFiles);
    } else {
      // User canceled file selection or no files were picked
      // Handle this case as appropriate for your app
    }
  } catch (e) {
    // Handle error
    print('Error picking files: $e');
  }
}



static Future <Document> uploadFilesAndGetDocuments(List<dynamic> files) async {




 
    var clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
    var uri = Uri.parse(
        "https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/files/upload?bucket=taskBucket");
    var request = http.MultipartRequest('POST', uri);
    for (var file in files) {
      request.files.add(http.MultipartFile.fromBytes(
          'files', file.toUint8List(),
          filename: file.fileName));
    }
    var response = await NetworkHelper()
        .request(RequestType.post, uri, requestBody: request);
    if (response != null && response.statusCode == 200) {
      var responseJson = jsonDecode(response.body);
      // handle response
      print("this is reponseJson $responseJson");
      var document = responseJson["documents"][0];
   document["downloadLink"]=document["fileLink"];
   return Document.fromJson(document);
      print("+"+document.toString());
    } else {
      throw Exception('Failed to upload files');
    }
  }
  static String replaceMapPatterns(Map<String, dynamic> patternMap, String textController) {
  String originalText = textController;

  // Replace each key with its corresponding value in the text, only if the value is not null
  patternMap.forEach((key, value) {
    if (value != null) {
      originalText = originalText.replaceAll(key, "{{${value.toString()}}}");
    }
  });

  return originalText;
}

}
