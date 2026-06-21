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

  void deleteExam(String id) {
    _exams.removeWhere((exam) => exam.id == id);
    notifyListeners();
  }

  void updateExam(String id, String subject, DateTime examDate) {
    final index = _exams.indexWhere((e) => e.id == id);

    if (index != -1) {
      _exams[index].subject = subject;
      _exams[index].examDate = examDate;

      notifyListeners();
    }
  }

  int getDaysLeft(DateTime examDate) {
    return examDate.difference(DateTime.now()).inDays;
  }
}
