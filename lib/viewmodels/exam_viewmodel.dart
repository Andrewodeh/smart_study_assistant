import 'package:flutter/material.dart';
import '../models/exam_model.dart';

class ExamViewModel extends ChangeNotifier {
  final List<ExamModel> _exams = [];

  List<ExamModel> get exams => _exams;

  void addExam(String subject, DateTime examDate) {
    _exams.add(
      ExamModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        subject: subject,
        examDate: examDate,
      ),
    );
    notifyListeners();
  }

  void updateExam(String id, String newSubject, DateTime newDate) {
    final index = _exams.indexWhere((e) => e.id == id);

    if (index != -1) {
      _exams[index] = ExamModel(id: id, subject: newSubject, examDate: newDate);

      notifyListeners();
    }
  }

  int get examCount => _exams.length;

  void deleteExam(String id) {
    _exams.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  int getDaysLeft(DateTime date) {
    return date.difference(DateTime.now()).inDays;
  }

  List<ExamModel> getUpcomingExams() {
    List<ExamModel> sorted = List.from(_exams);

    sorted.sort((a, b) => a.examDate.compareTo(b.examDate));

    return sorted.take(3).toList();
  }
}
