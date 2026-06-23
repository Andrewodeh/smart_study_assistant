import 'package:hive/hive.dart';
part 'assignment_model.g.dart';

@HiveType(typeId: 2)
class AssignmentModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  DateTime dueDate;
  @HiveField(3)
  bool isCompleted;
  @HiveField(4)
  String subject;

  AssignmentModel({
    required this.id,
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
    this.subject = '',
  });
}
