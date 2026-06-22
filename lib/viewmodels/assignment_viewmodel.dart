import 'package:flutter/material.dart';
import '../models/assignment_model.dart';

class AssignmentViewModel extends ChangeNotifier {
  final List<AssignmentModel> _assignments = [];

  List<AssignmentModel> get assignments => _assignments;

  void addAssignment(String title, DateTime dueDate) {
    _assignments.add(
      AssignmentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        dueDate: dueDate,
      ),
    );

    notifyListeners();
  }

  void updateAssignment(String id, String title, DateTime dueDate) {
    final index = _assignments.indexWhere((a) => a.id == id);

    if (index != -1) {
      _assignments[index].title = title;
      _assignments[index].dueDate = dueDate;
      notifyListeners();
    }
  }

  void deleteAssignment(String id) {
    _assignments.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void toggleCompleted(String id) {
    final index = _assignments.indexWhere((a) => a.id == id);

    if (index != -1) {
      _assignments[index].isCompleted = !_assignments[index].isCompleted;
      notifyListeners();
    }
  }

  int getDaysLeft(DateTime dueDate) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dueOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);

    return dueOnly.difference(todayOnly).inDays;
  }
}
