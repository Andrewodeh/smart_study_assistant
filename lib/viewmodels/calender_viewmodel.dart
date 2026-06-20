import '../models/exam.dart';
import '../models/assignment.dart';
import '../repositories/exam_repository.dart';
import '../repositories/assignment_repository.dart';

// ----------------------------
// A small wrapper so the Calendar screen can treat exams and assignments
// as a unified list of "events" without caring which type they are.
// ----------------------------
class CalendarEvent {
  final String title;
  final String subtitle;  // e.g. subject name
  final String type;      // 'exam' or 'assignment'
  final DateTime date;
  final bool isCompleted; // only relevant for assignments

  CalendarEvent({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.date,
    this.isCompleted = false,
  });
}

// ----------------------------
// CalendarViewModel
// Combines Exam and Assignment data into CalendarEvent lists for the View.
// ----------------------------
class CalendarViewModel {
  final ExamRepository _examRepo;
  final AssignmentRepository _assignmentRepo;

  // All events keyed by date string 'yyyy-MM-dd' for fast lookup
  Map<String, List<CalendarEvent>> _eventMap = {};

  bool isLoading = false;

  CalendarViewModel(this._examRepo, this._assignmentRepo);

  // Called once on screen init — loads everything into _eventMap
  Future<void> loadAllEvents() async {
    isLoading = true;
    _eventMap = {};

    final exams = await _examRepo.getExams();
    final assignments = await _assignmentRepo.getAssignments();

    for (final e in exams) {
      final key = _dateKey(e.date);
      _eventMap.putIfAbsent(key, () => []).add(CalendarEvent(
        title: e.title,
        subtitle: e.subjectName.isNotEmpty ? e.subjectName : 'Exam',
        type: 'exam',
        date: e.date,
      ));
    }

    for (final a in assignments) {
      final key = _dateKey(a.dueDate);
      _eventMap.putIfAbsent(key, () => []).add(CalendarEvent(
        title: a.title,
        subtitle: a.subjectName.isNotEmpty ? a.subjectName : 'Assignment',
        type: 'assignment',
        date: a.dueDate,
        isCompleted: a.isCompleted,
      ));
    }

    isLoading = false;
  }

  // Returns events for the given day (used by TableCalendar eventLoader)
  List<CalendarEvent> getEventsForDay(DateTime day) {
    return _eventMap[_dateKey(day)] ?? [];
  }

  // True if a day has any events — used to mark dots on the calendar
  bool hasEvents(DateTime day) {
    return (_eventMap[_dateKey(day)] ?? []).isNotEmpty;
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}