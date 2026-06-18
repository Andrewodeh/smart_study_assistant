// ----------------------------
// Model class (represents one study subject)
// This is the "M" in MVVM: pure data, no UI, no logic.
// ----------------------------
class Subject {
  final String id;
  final String name;
  final String code;
  final String instructor;
  final int creditHours;
  final int colorValue; // stored as an ARGB int so it saves easily

  Subject({
    required this.id,
    required this.name,
    this.code = '',
    this.instructor = '',
    this.creditHours = 0,
    this.colorValue = 0xFF2196F3, // default blue
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
