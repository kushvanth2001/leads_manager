import 'dart:convert';
import '../../../domainvariables.dart';
import '../helper/SharedPrefsHelper.dart';
import '../helper/networkHelper.dart';

class SkuUnits {
  int id;
  String name;

  SkuUnits({
    required this.id,
    required this.name,
  });

  factory SkuUnits.fromJson(Map<String, dynamic> json) => SkuUnits(
        id: json["id"]==null?"": json["id"],
        name: json["name"]==null?"":json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };


    static  Future<List<SkuUnits>> fetchUnits() async {
  String clientGroupName=await SharedPrefsHelper().getClientGroupName()??"SnapPeLeads";
  try {
    final String baseUrl ='https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/skus-units';
    final response = await NetworkHelper().request(RequestType.get, Uri.parse(baseUrl));

    if (response!.statusCode == 200) {

   final jsonData = jsonDecode(response.body);
  final List<dynamic> skuTypesData = jsonData["units"];

  return skuTypesData.map((type) => SkuUnits.fromJson(type)).toList();
    } else {
      throw Exception('Failed to fetch category types');
    }
  } catch (e) {
    throw Exception('Failed to fetch category types: $e');
  }
}
}