import 'dart:convert';

UnitModel unitFromJson(String str) => UnitModel.fromJson(json.decode(str));

String unitToJson(UnitModel data) => json.encode(data.toJson());

class UnitModel {
  UnitModel({
    required this.status,
    required this.messages,
    required this.units,
  });

  String status;
  List<dynamic> messages;
  List<Unit> units;

  factory UnitModel.fromJson(Map<String, dynamic> json) => UnitModel(
        status: json["status"],
        messages: [],
        units: List<Unit>.from(json["units"].map((x) => Unit.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "messages": [],
        "units": List<dynamic>.from(units.map((x) => x)),
      };
}

class Unit {
  Unit({
    required this.id,
    required this.name,
  });

  int id;
  String name;

  factory Unit.fromJson(Map<String, dynamic> json) => Unit(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
