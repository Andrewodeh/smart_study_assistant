import 'package:hive_flutter/hive_flutter.dart';
import '../models/exam.dart';

// ----------------------------
// Repository INTERFACE for Exams.
// The ViewModel only talks to this contract, never to storage directly.
// ----------------------------
abstract class ExamRepository {
  Future<List<Exam>> getExams();
  Future<void> addExam(Exam exam);
  Future<void> updateExam(Exam exam);
  Future<void> deleteExam(String id);
  Future<List<Exam>> getExamsForSubject(String subjectId);
}

// ----------------------------
// Hive implementation.
// Each Exam is stored as a key-value pair using exam.id as the key.
// ----------------------------
class HiveExamRepository implements ExamRepository {
  static const String _boxName = 'exams_box';

  Future<Box<Exam>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Exam>(_boxName);
    }
    return Hive.box<Exam>(_boxName);
  }

  @override
  Future<List<Exam>> getExams() async {
    final box = await _getBox();
    // Sort by date ascending so nearest exams show first
    final list = box.values.toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  @override
  Future<void> addExam(Exam exam) async {
    final box = await _getBox();
    await box.put(exam.id, exam);
  }

  @override
  Future<void> updateExam(Exam exam) async {
    final box = await _getBox();
    await box.put(exam.id, exam);
  }

  @override
  Future<void> deleteExam(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  @override
  Future<List<Exam>> getExamsForSubject(String subjectId) async {
    final box = await _getBox();
    return box.values.where((e) => e.subjectId == subjectId).toList();
  }
}