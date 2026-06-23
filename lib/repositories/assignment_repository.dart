import 'package:hive_flutter/hive_flutter.dart';
import '../models/assignment_model.dart';

abstract class AssignmentRepository {
  Future<List<AssignmentModel>> getAssignments();
  Future<void> addAssignment(AssignmentModel assignment);
  Future<void> deleteAssignment(String id);
  Future<void> setComplete(String id, bool isCompleted);
}

class HiveAssignmentRepository implements AssignmentRepository {
  static const String _boxName = 'assignments_box';

  Future<Box<AssignmentModel>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<AssignmentModel>(_boxName);
    }
    return Hive.box<AssignmentModel>(_boxName);
  }

  @override
  Future<List<AssignmentModel>> getAssignments() async {
    final box = await _getBox();
    final list = box.values.toList();
    list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return list;
  }

  @override
  Future<void> addAssignment(AssignmentModel assignment) async {
    final box = await _getBox();
    await box.put(assignment.id, assignment);
  }

  @override
  Future<void> deleteAssignment(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  @override
  Future<void> setComplete(String id, bool isCompleted) async {
    final box = await _getBox();
    final a = box.get(id);
    if (a != null) {
      a.isCompleted = isCompleted;
      await box.put(id, a);
    }
  }
}