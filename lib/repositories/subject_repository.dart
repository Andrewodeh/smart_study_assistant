import '../models/subject.dart';
import 'package:hive_flutter/hive_flutter.dart';
// ----------------------------
// Repository INTERFACE (the "contract" for data handling).
// The ViewModel only ever talks to this interface, never to storage
// directly. This is the key idea behind "Data Handling in MVVM":
// the rest of the app does not care HOW or WHERE data is stored.
// ----------------------------
abstract class SubjectRepository {
  Future<List<Subject>> getSubjects();
  Future<void> addSubject(Subject subject);
  Future<void> updateSubject(Subject subject);
  Future<void> deleteSubject(String id);
  Future<List<Subject>> searchSubjects(String query);
}

// ----------------------------
// Hive implementation.
// Handles each subject as a distinct key-value pair inside Hive.
// ----------------------------
class HiveSubjectRepository implements SubjectRepository {
  static const String _boxName = 'subjects_box';

  // Helper method to make sure the box is open before reading/writing
  Future<Box<Subject>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Subject>(_boxName);
    }
    return Hive.box<Subject>(_boxName);
  }

  @override
  Future<List<Subject>> getSubjects() async {
    final box = await _getBox();
    return box.values.toList();
  }

  @override
  Future<void> addSubject(Subject subject) async {
    final box = await _getBox();
    // Save using the subject id as the unique database key
    await box.put(subject.id, subject);
  }

  @override
  Future<void> updateSubject(Subject subject) async {
    final box = await _getBox();
    // In Hive, putting data on an existing key overwrites/updates it
    await box.put(subject.id, subject);
  }

  @override
  Future<void> deleteSubject(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  @override
  Future<List<Subject>> searchSubjects(String query) async {
    final box = await _getBox();
    final String lower = query.toLowerCase();
    
    // Filters items directly out of the local memory box
    return box.values.where((s) {
      return s.name.toLowerCase().contains(lower) ||
          s.code.toLowerCase().contains(lower) ||
          s.instructor.toLowerCase().contains(lower);
    }).toList();
  }
}