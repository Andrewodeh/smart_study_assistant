import 'package:hive/hive.dart';

part 'exam.g.dart';

@HiveType(typeId: 1)
class Exam extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String subjectId;

  @HiveField(3)
  final String subjectName;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String location;

  @HiveField(6)
  final String notes;

  Exam({
    required this.id,
    required this.title,
    required this.subjectId,
    this.subjectName = '',
    required this.date,
    this.location = '',
    this.notes = '',
  });

  // Days remaining until the exam (negative = already passed)
  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final examDay = DateTime(date.year, date.month, date.day);
    return examDay.difference(today).inDays;
  }

  bool get isPast => daysRemaining < 0;

  Exam copyWith({
    String? title,
    String? subjectId,
    String? subjectName,
    DateTime? date,
    String? location,
    String? notes,
  }) {
    return Exam(
      id: id,
      title: title ?? this.title,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      date: date ?? this.date,
      location: location ?? this.location,
      notes: notes ?? this.notes,
    );
  }
}