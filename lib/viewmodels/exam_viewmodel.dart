import 'package:flutter/material.dart';
import '../models/exam_model.dart';
import '../repositories/exam_repository.dart';

class ExamViewModel extends ChangeNotifier {
  final ExamRepository _repo;
  final List<ExamModel> _exams = [];

  List<ExamModel> get exams => _exams;

  ExamViewModel([ExamRepository? repo]) : _repo = repo ?? HiveExamRepository() {
    _loadFromRepo();
  }

  Future<void> _loadFromRepo() async {
    final loaded = await _repo.getExams();
    _exams
      ..clear()
      ..addAll(loaded);
    notifyListeners();
  }

  Future<void> addExam(String subject, DateTime examDate) async {
    final exam = ExamModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subject: subject,
      examDate: examDate,
    );
    await _repo.addExam(exam);
    _exams.add(exam);
    notifyListeners();
  }

  Future<void> updateExam(String id, String newSubject, DateTime newDate) async {
    final index = _exams.indexWhere((e) => e.id == id);
    if (index != -1) {
      final updated = ExamModel(id: id, subject: newSubject, examDate: newDate);
      await _repo.deleteExam(id);
      await _repo.addExam(updated);
      _exams[index] = updated;
      notifyListeners();
    }
  }

  int get examCount => _exams.length;

  Future<void> deleteExam(String id) async {
    await _repo.deleteExam(id);
    _exams.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  int getDaysLeft(DateTime date) {
    return date.difference(DateTime.now()).inDays;
  }

  List<ExamModel> getUpcomingExams() {
    final List<ExamModel> sorted = List.from(_exams);
    sorted.sort((a, b) => a.examDate.compareTo(b.examDate));
    return sorted.take(3).toList();
  }
}
