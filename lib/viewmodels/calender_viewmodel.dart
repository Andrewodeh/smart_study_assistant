import '../models/exam_model.dart';
import '../models/assignment_model.dart';
import '../repositories/exam_repository.dart';
import '../repositories/assignment_repository.dart';

class CalendarViewModel {
  final ExamRepository _examRepo;
  final AssignmentRepository _assignmentRepo;

  CalendarViewModel(this._examRepo, this._assignmentRepo);

  // Combines exams and assignments for a specific day
  Future<List<dynamic>> getEventsForDay(DateTime day) async {
    final List<ExamModel> exams = await _examRepo.getExams();
    final List<AssignmentModel> assignments = await _assignmentRepo.getAssignments();

    // Filter to find matching dates
    final dayExams = exams.where((e) => _isSameDay(e.examDate, day));
    final dayAssignments = assignments.where((a) => _isSameDay(a.dueDate, day));

    return [...dayExams, ...dayAssignments];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}