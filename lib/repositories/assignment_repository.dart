import 'package:hive_flutter/hive_flutter.dart';
import '../models/assignment.dart';


// Repository INTERFACE for Assignments.
abstract class AssignmentRepository {
  Future<List<Assignment>> getAssignments();
  Future<void> addAssignment(Assignment assignment);
  Future<void> updateAssignment(Assignment assignment);
  Future<void> deleteAssignment(String id);
  Future<List<Assignment>> getAssignmentsForSubject(String subjectId);
  Future<void> toggleComplete(String id);
}


// Hive implementation.


class HiveAssignmentRepository implements AssignmentRepository {
  static const String _boxName = 'assignments_box';

  Future<Box<Assignment>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Assignment>(_boxName);
    }
    return Hive.box<Assignment>(_boxName);
  }

  @override
  Future<List<Assignment>> getAssignments() async {
    final box = await _getBox();
    // Sort by due date ascending so most urgent shows first
    final list = box.values.toList();
    list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return list;
  }

  @override
  Future<void> addAssignment(Assignment assignment) async {
    final box = await _getBox();
    await box.put(assignment.id, assignment);
  }

  @override
  Future<void> updateAssignment(Assignment assignment) async {
    final box = await _getBox();
    await box.put(assignment.id, assignment);
  }

  @override
  Future<void> deleteAssignment(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  @override
  Future<List<Assignment>> getAssignmentsForSubject(String subjectId) async {
    final box = await _getBox();
    return box.values.where((a) => a.subjectId == subjectId).toList();
  }

  @override
  Future<void> toggleComplete(String id) async {
    final box = await _getBox();
    final assignment = box.get(id);
    if (assignment != null) {
      final updated = assignment.copyWith(isCompleted: !assignment.isCompleted);
      await box.put(id, updated);
    }
  }
}