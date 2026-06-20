import 'package:hive/hive.dart';

part 'assignment.g.dart';

@HiveType(typeId: 2)
class Assignment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String subjectId;

  @HiveField(3)
  final String subjectName;

  @HiveField(4)
  final DateTime dueDate;

  @HiveField(5)
  final String description;

  @HiveField(6)
  bool isCompleted;

  Assignment({
    required this.id,
    required this.title,
    required this.subjectId,
    this.subjectName = '',
    required this.dueDate,
    this.description = '',
    this.isCompleted = false,
  });

  // Days remaining until due (negative = overdue)
  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }

  bool get isOverdue => !isCompleted && daysRemaining < 0;

  Assignment copyWith({
    String? title,
    String? subjectId,
    String? subjectName,
    DateTime? dueDate,
    String? description,
    bool? isCompleted,
  }) {
    return Assignment(
      id: id,
      title: title ?? this.title,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      dueDate: dueDate ?? this.dueDate,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}