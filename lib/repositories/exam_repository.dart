import 'package:hive_flutter/hive_flutter.dart';
import '../models/exam_model.dart';

abstract class ExamRepository {
  Future<List<ExamModel>> getExams();
  Future<void> addExam(ExamModel exam);
  Future<void> deleteExam(String id);
}

class HiveExamRepository implements ExamRepository {
  static const String _boxName = 'exams_box';

  Future<Box<ExamModel>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<ExamModel>(_boxName);
    }
    return Hive.box<ExamModel>(_boxName);
  }

  @override
  Future<List<ExamModel>> getExams() async {
    final box = await _getBox();
    final list = box.values.toList();
    list.sort((a, b) => a.examDate.compareTo(b.examDate));
    return list;
  }

  @override
  Future<void> addExam(ExamModel exam) async {
    final box = await _getBox();
    await box.put(exam.id, exam);
  }

  @override
  Future<void> deleteExam(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }
}