import 'package:hive/hive.dart';
part 'exam_model.g.dart';

@HiveType(typeId: 1)
class ExamModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String subject;      
  @HiveField(2)
  DateTime examDate;

  
  ExamModel({required this.id, required this.subject, required this.examDate});
}
