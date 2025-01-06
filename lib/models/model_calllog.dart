class CallLogModel {
  final String number;
  final String name;
  final String duration;
  final String type;
  final int date;

  CallLogModel( {
  required  this.duration,
    required this.number,
    required this.name,
    required this.type,
    required this.date,
  });

  factory CallLogModel.fromJson(Map<String, dynamic> json) {
    return CallLogModel(
      number: json['number']??"",
      name: json['name']??"",
      type: json['type']??"",
      date: json['date']??"", duration: json['duration']??"",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'type': type,
      'date': date,
    };
  }
}