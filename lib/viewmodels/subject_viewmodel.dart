import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../repositories/subject_repository.dart';

class SubjectViewModel extends ChangeNotifier {
  final SubjectRepository _repository;
  List<Subject> _allSubjects = [];
  List<Subject> subjects = [];

  SubjectViewModel(this._repository) {
    loadSubjects();
  }

  /// Full subject list, unaffected by the current search filter.
  List<Subject> get allSubjects => List.unmodifiable(_allSubjects);

  /// Total number of saved subjects (ignores any active search filter).
  int get totalCount => _allSubjects.length;

  Future<void> loadSubjects() async {
    _allSubjects = await _repository.loadAll();
    subjects = List.from(_allSubjects);
    notifyListeners();
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      subjects = List.from(_allSubjects);
      notifyListeners();
      return;
    }
    final String q = query.toLowerCase();
    subjects = _allSubjects
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.code.toLowerCase().contains(q) ||
            s.instructor.toLowerCase().contains(q))
        .toList();
    notifyListeners();
  }

  Future<bool> addSubject({
    required String name,
    required String code,
    required String instructor,
    required int creditHours,
    required int colorValue,
  }) async {
    if (name.trim().isEmpty) return false;
    final Subject subject = Subject(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      code: code.trim(),
      instructor: instructor.trim(),
      creditHours: creditHours,
      colorValue: colorValue,
    );
    _allSubjects.add(subject);
    subjects = List.from(_allSubjects);
    await _repository.saveAll(_allSubjects);
    notifyListeners();
    return true;
  }

  Future<bool> updateSubject(
    Subject original, {
    required String name,
    required String code,
    required String instructor,
    required int creditHours,
    required int colorValue,
  }) async {
    if (name.trim().isEmpty) return false;
    final int index = _allSubjects.indexWhere((s) => s.id == original.id);
    if (index == -1) return false;
    _allSubjects[index] = Subject(
      id: original.id,
      name: name.trim(),
      code: code.trim(),
      instructor: instructor.trim(),
      creditHours: creditHours,
      colorValue: colorValue,
    );
    subjects = List.from(_allSubjects);
    await _repository.saveAll(_allSubjects);
    notifyListeners();
    return true;
  }

  Future<void> deleteSubject(String id) async {
    _allSubjects.removeWhere((s) => s.id == id);
    subjects = List.from(_allSubjects);
    await _repository.saveAll(_allSubjects);
    notifyListeners();
  }
}