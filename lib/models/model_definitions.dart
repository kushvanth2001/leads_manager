import 'dart:convert';

import '../helper/SharedPrefsHelper.dart';
import '../helper/networkHelper.dart';
import '../../../domainvariables.dart';

class Definitions {
  final String name;
  final String? value;
  final int? from;
  final int? to;
  final String matchMode;
  final int id;

  Definitions({
    required this.name,
    required this.value,
    this.from,
    this.to,
    required this.matchMode,
    required this.id,
  });

  factory Definitions.fromJson(Map<String, dynamic> json) {
    return Definitions(
      name: json['name'],
      value: json['value'],
      from: json['from'],
      to: json['to'],
      matchMode: json['matchMode'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'from': from,
      'to': to,
      'matchMode': matchMode,
      'id': id,
    };
  }
  
    static Future<List<Definitions>> fetchDefinitions(int id) async {
       String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";
    try {
      final response = await NetworkHelper().request(
        RequestType.get,
        Uri.parse('https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/reports/$id/definitions'),
        requestBody: "",
      );
      if (response != null && response.statusCode == 200) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
        final parsed = jsonDecode(response.body)['reportDefinitions'];
           List<Definitions>  defs=[];

for(int i=0;i<parsed.length;i++){
  defs.add(Definitions.fromJson(parsed[i]));
}
        return defs;

      } else {
        print('Failed to load definitions ${response?.statusCode}');
        throw Exception('Failed to load definitions');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw e;
    }
  }

   static Future<bool> postDefinitions(List<Definitions> definition,int id) async {
   List<Map<String,dynamic>>  defs=[];

for(int i=0;i<definition.length;i++){
  defs.add(definition[i].toJson());
}
print(defs);
        String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";
    try {
      final response = await NetworkHelper().request(
        RequestType.post,
        Uri.parse('https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/reports/$id/definitions'),
        requestBody: json.encode({"reportDefinitions":defs}),
      );

      if (response!.statusCode == 200) {
        return true;
      } else {
        print('Failed to post definitions ${response?.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception occurred during POST request: $e');
      return false;
    }
  }

  }