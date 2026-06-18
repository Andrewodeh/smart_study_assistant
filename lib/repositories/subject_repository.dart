import 'dart:convert'; // for json.encode / json.decode
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subject.dart';

// ----------------------------
// Repository INTERFACE (the "contract" for data handling).
// The ViewModel only ever talks to this interface, never to storage
// directly. This is the key idea behind "Data Handling in MVVM":
// the rest of the app does not care HOW or WHERE data is stored.
//
// Task 5 can later create a HiveSubjectRepository that implements this
// same interface, and nothing in the ViewModel or UI has to change.
// ----------------------------
abstract class SubjectRepository {
  Future<List<Subject>> getSubjects();
  Future<void> addSubject(Subject subject);
  Future<void> updateSubject(Subject subject);
  Future<void> deleteSubject(String id);
  Future<List<Subject>> searchSubjects(String query);
}

// ----------------------------
// SharedPreferences implementation.
// Stores the whole list as one JSON string under a single key.
// (Same shared_preferences style used in the professor's examples.)
// ----------------------------
class SharedPrefsSubjectRepository implements SubjectRepository {
  static const String _key = 'subjects';

  // Read the raw JSON from storage and turn it into Subject objects.
  Future<List<Subject>> _readAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null || data.isEmpty) {
      return [];
    }
    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((e) => Subject.fromJson(e)).toList();
  }

  // Save a list of Subject objects back to storage as JSON.
  Future<void> _writeAll(List<Subject> subjects) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String data = json.encode(subjects.map((s) => s.toJson()).toList());
    await prefs.setString(_key, data);
  }

  @override
  Future<List<Subject>> getSubjects() async {
    return await _readAll();
  }

  @override
  Future<void> addSubject(Subject subject) async {
    final List<Subject> subjects = await _readAll();
    subjects.add(subject);
    await _writeAll(subjects);
  }

  @override
  Future<void> updateSubject(Subject subject) async {
    final List<Subject> subjects = await _readAll();
    final int index = subjects.indexWhere((s) => s.id == subject.id);
    if (index != -1) {
      subjects[index] = subject;
      await _writeAll(subjects);
    }
  }

  @override
  Future<void> deleteSubject(String id) async {
    final List<Subject> subjects = await _readAll();
    subjects.removeWhere((s) => s.id == id);
    await _writeAll(subjects);
  }

  // Search by name, code, or instructor (case-insensitive).
  @override
  Future<List<Subject>> searchSubjects(String query) async {
    final List<Subject> subjects = await _readAll();
    final String lower = query.toLowerCase();
    return subjects.where((s) {
      return s.name.toLowerCase().contains(lower) ||
          s.code.toLowerCase().contains(lower) ||
          s.instructor.toLowerCase().contains(lower);
    }).toList();
  }
}
