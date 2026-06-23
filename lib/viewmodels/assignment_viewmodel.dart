import 'package:flutter/material.dart';
import '../models/assignment_model.dart';
import '../repositories/assignment_repository.dart';

class AssignmentViewModel extends ChangeNotifier {
  final AssignmentRepository _repo;
  final List<AssignmentModel> _assignments = [];

  List<AssignmentModel> get assignments => _assignments;

  AssignmentViewModel([AssignmentRepository? repo]) : _repo = repo ?? HiveAssignmentRepository() {
    _loadFromRepo();
  }

  Future<void> _loadFromRepo() async {
    final loaded = await _repo.getAssignments();
    _assignments
      ..clear()
      ..addAll(loaded);
    notifyListeners();
  }

  Future<String> addAssignment(String title, DateTime dueDate,
      {String subject = ''}) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final assignment =
        AssignmentModel(id: id, title: title, dueDate: dueDate, subject: subject);
    await _repo.addAssignment(assignment);
    _assignments.add(assignment);
    notifyListeners();
    return id;
  }

  Future<void> updateAssignment(String id, String title, DateTime dueDate,
      {String subject = ''}) async {
    final index = _assignments.indexWhere((a) => a.id == id);
    if (index != -1) {
      final updated = AssignmentModel(
          id: id,
          title: title,
          dueDate: dueDate,
          isCompleted: _assignments[index].isCompleted,
          subject: subject);
      await _repo.deleteAssignment(id);
      await _repo.addAssignment(updated);
      _assignments[index] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteAssignment(String id) async {
    await _repo.deleteAssignment(id);
    _assignments.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  Future<void> toggleCompleted(String id) async {
    final index = _assignments.indexWhere((a) => a.id == id);
    if (index != -1) {
      final current = _assignments[index];
      final newValue = !current.isCompleted;
      current.isCompleted = newValue;
      await _repo.setComplete(id, newValue);
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
