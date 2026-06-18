import '../models/subject.dart';
import '../repositories/subject_repository.dart';

// ----------------------------
// ViewModel for the Subjects feature (the "VM" in MVVM).
// It holds the data and ALL the logic (validation, building objects,
// searching). The View (screen) never does any of this itself — it only
// calls these methods and then calls setState() to rebuild.
// ----------------------------
class SubjectViewModel {
  final SubjectRepository _repository;

  SubjectViewModel(this._repository);

  // The list the UI shows (already filtered by the search box).
  List<Subject> subjects = [];

  // The current search text ('' means "show everything").
  String searchQuery = '';

  bool isLoading = false;

  // Load subjects from the repository (called from the screen's initState).
  Future<void> loadSubjects() async {
    isLoading = true;
    if (searchQuery.isEmpty) {
      subjects = await _repository.getSubjects();
    } else {
      subjects = await _repository.searchSubjects(searchQuery);
    }
    isLoading = false;
  }

  // Add a new subject. Returns false if the name is empty (simple validation).
  Future<bool> addSubject({
    required String name,
    required String code,
    required String instructor,
    required int creditHours,
    required int colorValue,
  }) async {
    if (name.trim().isEmpty) {
      return false;
    }
    final Subject subject = Subject(
      // A simple unique id: the current time in milliseconds.
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      code: code.trim(),
      instructor: instructor.trim(),
      creditHours: creditHours,
      colorValue: colorValue,
    );
    await _repository.addSubject(subject);
    await loadSubjects();
    return true;
  }

  // Update an existing subject. Returns false if the name is empty.
  Future<bool> updateSubject(
    Subject original, {
    required String name,
    required String code,
    required String instructor,
    required int creditHours,
    required int colorValue,
  }) async {
    if (name.trim().isEmpty) {
      return false;
    }
    final Subject updated = original.copyWith(
      name: name.trim(),
      code: code.trim(),
      instructor: instructor.trim(),
      creditHours: creditHours,
      colorValue: colorValue,
    );
    await _repository.updateSubject(updated);
    await loadSubjects();
    return true;
  }

  // Delete a subject by its id.
  Future<void> deleteSubject(String id) async {
    await _repository.deleteSubject(id);
    await loadSubjects();
  }

  // Run a search and reload the list.
  Future<void> search(String query) async {
    searchQuery = query;
    await loadSubjects();
  }
}
