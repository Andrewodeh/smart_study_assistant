import 'package:hive/hive.dart';
part 'subject.g.dart';

@HiveType(typeId: 0)
class Subject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String code;
  @HiveField(3)
  final String instructor;
  @HiveField(4)
  final int creditHours;
  @HiveField(5)
  final int colorValue;

  Subject({
    required this.id,
    required this.name,
    required this.code,
    required this.instructor,
    required this.creditHours,
    required this.colorValue,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'instructor': instructor,
        'creditHours': creditHours,
        'colorValue': colorValue,
      };

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json['id'] as String,
        name: json['name'] as String,
        code: json['code'] as String? ?? '',
        instructor: json['instructor'] as String? ?? '',
        creditHours: json['creditHours'] as int? ?? 0,
        colorValue: json['colorValue'] as int? ?? 0xFF2196F3,
      );
}
