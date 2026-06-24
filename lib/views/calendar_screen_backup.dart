import 'package:flutter/material.dart';
import '../widgets/page_container.dart';
import '../repositories/exam_repository.dart';
import '../repositories/assignment_repository.dart';
import '../models/exam_model.dart';
import '../models/assignment_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final HiveExamRepository _examRepo = HiveExamRepository();
  final HiveAssignmentRepository _assignmentRepo = HiveAssignmentRepository();

  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  Map<String, List<dynamic>> _events = {};
  bool _loading = true;
  String? _lastError;

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  // Palette
  static const Color _navy = Color(0xFF6C4DF6); // primary violet
  static const Color _border = Color(0xFFE7E5F0);
  static const Color _muted = Color(0xFF6B6880);
  static const Color _examColor = Color(0xFFE53E5A);
  static const Color _assignmentColor = Color(0xFF16A974);

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _loading = true);
    try {
      final exams = await _examRepo.getExams();
      final assignments = await _assignmentRepo.getAssignments();

      final Map<String, List<dynamic>> map = {};

      void addEvent(DateTime dt, dynamic e) {
        map.putIfAbsent(_keyForDate(dt), () => []).add(e);
      }

      for (final e in exams) {
        addEvent(e.examDate, e);
      }
      for (final a in assignments) {
        addEvent(a.dueDate, a);
      }

      if (!mounted) return;
      setState(() {
        _events = map;
        _loading = false;
        _lastError = null;
      });
    } catch (err, st) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _lastError = '$err';
      });
      // ignore: avoid_print
      print('Error loading calendar events: $err\n$st');
    }
  }

  String _keyForDate(DateTime d) => '${d.year}-${d.month}-${d.day}';

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int _daysInMonth(DateTime m) {
    final next =
        (m.month == 12) ? DateTime(m.year + 1) : DateTime(m.year, m.month + 1);
    return next.subtract(const Duration(days: 1)).day;
  }

  void _goToToday() {
    setState(() {
      _focusedMonth = DateTime.now();
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsForSelected = _events[_keyForDate(_selectedDate)] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            tooltip: 'Today',
            onPressed: _goToToday,
            icon: const Icon(Icons.today_outlined),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadEvents,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'View your study schedule, exam dates, and assignment deadlines.',
              style: TextStyle(fontSize: 13.5, color: _muted),
            ),
            const SizedBox(height: 16),
            if (_lastError != null) _buildErrorBanner(),
            _buildMonthHeader(),
            const SizedBox(height: 12),
            _buildCalendarCard(),
            const SizedBox(height: 16),
            _buildLegend(),
            const SizedBox(height: 16),
            _buildSelectedDateLabel(),
            const SizedBox(height: 10),
            Expanded(child: _buildEventsList(eventsForSelected)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFC0392B), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Could not load events: $_lastError',
              style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    final label =
        '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _navy,
          ),
        ),
        Row(
          children: [
            _circleIconButton(
              icon: Icons.chevron_left,
              onTap: () => setState(() => _focusedMonth =
                  DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
            ),
            const SizedBox(width: 8),
            _circleIconButton(
              icon: Icons.chevron_right,
              onTap: () => setState(() => _focusedMonth =
                  DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(side: BorderSide(color: _border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 20, color: _navy),
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Weekday headers
          Row(
            children: const [
              _WeekdayLabel('Sun'),
              _WeekdayLabel('Mon'),
              _WeekdayLabel('Tue'),
              _WeekdayLabel('Wed'),
              _WeekdayLabel('Thu'),
              _WeekdayLabel('Fri'),
              _WeekdayLabel('Sat'),
            ],
          ),
          const SizedBox(height: 8),
          _loading
              ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              : GridView.count(
                  crossAxisCount: 7,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  children: _buildDayCells(),
                ),
        ],
      ),
    );
  }

  List<Widget> _buildDayCells() {
    final first = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final firstWeekday = first.weekday % 7; // make Sunday=0
    final totalDays = _daysInMonth(_focusedMonth);
    final today = DateTime.now();

    final cells = <Widget>[];

    for (int i = 0; i < firstWeekday; i++) {
      cells.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= totalDays; day++) {
      final dt = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final dayEvents = _events[_keyForDate(dt)] ?? const [];
      final isSelected = _isSameDay(_selectedDate, dt);
      final isToday = _isSameDay(today, dt);

      final hasExam = dayEvents.any((e) => e is ExamModel);
      final hasAssignment = dayEvents.any((e) => e is AssignmentModel);

      cells.add(
        GestureDetector(
          onTap: () => setState(() => _selectedDate = dt),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? _navy
                  : (isToday ? const Color(0xFFEDE9FE) : Colors.transparent),
              borderRadius: BorderRadius.circular(10),
              border: isToday && !isSelected
                  ? Border.all(color: const Color(0xFFB9A9FB))
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hasExam)
                      _dot(isSelected ? Colors.white : _examColor),
                    if (hasExam && hasAssignment) const SizedBox(width: 3),
                    if (hasAssignment)
                      _dot(isSelected ? Colors.white : _assignmentColor),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return cells;
  }

  Widget _dot(Color color) => Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _buildLegend() {
    return Row(
      children: [
        _dot(_examColor),
        const SizedBox(width: 6),
        const Text('Exam', style: TextStyle(fontSize: 12.5, color: _muted)),
        const SizedBox(width: 20),
        _dot(_assignmentColor),
        const SizedBox(width: 6),
        const Text('Assignment',
            style: TextStyle(fontSize: 12.5, color: _muted)),
      ],
    );
  }

  Widget _buildSelectedDateLabel() {
    final d = _selectedDate;
    final label = '${_monthNames[d.month - 1]} ${d.day}, ${d.year}';
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: _navy,
      ),
    );
  }

  Widget _buildEventsList(List<dynamic> events) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (events.isEmpty) {
      return SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_available_outlined,
                  size: 36, color: Color(0xFFCBD5E1)),
              SizedBox(height: 10),
              Text('No events on this day.',
                  style: TextStyle(color: _muted, fontSize: 13.5)),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: events.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final e = events[idx];
        if (e is ExamModel) {
          return _eventTile(
            icon: Icons.school_outlined,
            color: _examColor,
            badge: 'Exam',
            title: e.subject,
            subtitle: _formatTime(e.examDate),
          );
        } else if (e is AssignmentModel) {
          return _eventTile(
            icon: Icons.assignment_outlined,
            color: _assignmentColor,
            badge: e.isCompleted ? 'Completed' : 'Assignment',
            title: e.title,
            subtitle: 'Due ${e.dueDate.day}/${e.dueDate.month}/${e.dueDate.year}',
            trailing: Icon(
              e.isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color: e.isCompleted ? _assignmentColor : const Color(0xFFCBD5E1),
              size: 20,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _eventTile({
    required IconData icon,
    required Color color,
    required String badge,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12.5, color: _muted),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing,
          ],
        ],
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String text;
  const _WeekdayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}
