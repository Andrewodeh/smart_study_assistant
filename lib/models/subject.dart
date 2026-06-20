import 'package:hive/hive.dart'; // 1. ADDED IMPORT

// 2. ADDED PART DIRECTIVE
part 'subject.g.dart'; 

@HiveType(typeId: 0) // 3. ADDED HIVE TYPE
class Subject extends HiveObject { // 4. MODIFIED CLASS DEFINITION
  @HiveField(0) // 5. ADDED FIELD ID
  final String id;

  @HiveField(1) // 5. ADDED FIELD ID
  final String name;

  @HiveField(2) // 5. ADDED FIELD ID
  final String code;

  @HiveField(3) // 5. ADDED FIELD ID
  final String instructor;

  @HiveField(4) // 5. ADDED FIELD ID
  final int creditHours;

  @HiveField(5) // 5. ADDED FIELD ID
  final int colorValue;

  Subject({
    required this.id,
    required this.name,
    this.code = '',
    this.instructor = '',
    this.creditHours = 0,
    this.colorValue = 0xFF2196F3,
  });
  // Convert JSON (a Map) into a Subject object.
  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      code: json['code'] ?? '',
      instructor: json['instructor'] ?? '',
      creditHours: json['creditHours'] ?? 0,
      colorValue: json['colorValue'] ?? 0xFF2196F3,
    );
  }

  // Convert a Subject object into JSON (a Map) for saving.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'instructor': instructor,
      'creditHours': creditHours,
      'colorValue': colorValue,
    };
  }

  // Return a copy with some fields changed (used when editing a subject).
  Subject copyWith({
    String? name,
    String? code,
    String? instructor,
    int? creditHours,
    int? colorValue,
  }) {
    return Subject(
      id: id, // id never changes
      name: name ?? this.name,
      code: code ?? this.code,
      instructor: instructor ?? this.instructor,
      creditHours: creditHours ?? this.creditHours,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}
