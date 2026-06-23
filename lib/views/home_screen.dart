import 'package:flutter/material.dart';
import '../repositories/subject_repository.dart';
import '../viewmodels/subject_viewmodel.dart';
import '../widgets/app_logo.dart';
import '../widgets/dashboard_card.dart';
import '../viewmodels/exam_viewmodel.dart';
import 'package:provider/provider.dart';
import '../viewmodels/assignment_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int index) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SubjectViewModel _subjectViewModel = SubjectViewModel(
    SharedPrefsSubjectRepository(),
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _subjectViewModel.loadSubjects();
    setState(() {});
  }

  String _formattedDate() {
    final DateTime now = DateTime.now();
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const List<String> weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${weekdays[now.weekday - 1]}, '
        '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final int subjectCount = _subjectViewModel.subjects.length;
    final examVm = Provider.of<ExamViewModel>(context);
    final int examCount = examVm.examCount;
    final assignmentVm = Provider.of<AssignmentViewModel>(context);
    final pendingAssignments = assignmentVm.assignments
        .where((assignment) => !assignment.isCompleted)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Quick Access'),
                      const SizedBox(height: 14),
                      _buildQuickAccessGrid(
                        subjectCount,
                        pendingAssignments.length,
                        examCount,
                      ),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Upcoming Exams'),
                      const SizedBox(height: 12),
                      _buildPlaceholderCard(
                        'No upcoming exams yet.',
                        Icons.assignment_outlined,
                      ),
                      const SizedBox(height: 28),
                      _buildSectionTitle('Pending Assignments'),
                      const SizedBox(height: 12),
                      pendingAssignments.isEmpty
                          ? _buildPlaceholderCard(
                              'No pending assignments yet.',
                              Icons.task_outlined,
                            )
                          : Column(
                              children: pendingAssignments.map((assignment) {
                                return _buildAssignmentPreviewCard(
                                  assignment.title,
                                  assignment.dueDate,
                                );
                              }).toList(),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    // Respect the status-bar height on mobile; zero on web.
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      color: const Color(0xFF0F1F3D),
      padding: EdgeInsets.fromLTRB(24, statusBarHeight + 24, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo mark + app name
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const AppLogoMark(size: 44),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Smart Study Assistant',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Plan smarter. Study better.',
                    style: TextStyle(color: Colors.white54, fontSize: 12.5),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Date chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.today_outlined,
                  color: Color(0xFFE8A020),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  _formattedDate(),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section title ────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: Color(0xFF94A3B8),
      ),
    );
  }

  // ─── Quick access 2×2 grid ────────────────────────────────────────────────

  Widget _buildQuickAccessGrid(
    int subjectCount,
    int assignmentCount,
    int examCount,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double ratio = constraints.maxWidth > 500 ? 2.0 : 1.4;
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: ratio,
          children: [
            DashboardCard(
              icon: Icons.book_rounded,
              label: 'Subjects',
              subtitle: subjectCount == 1
                  ? '1 subject'
                  : '$subjectCount subjects',
              color: const Color(0xFF2563EB),
              onTap: () => widget.onNavigate(1),
            ),
            DashboardCard(
              icon: Icons.assignment_rounded,
              label: 'Exams',
              subtitle: examCount == 1 ? '1 exam' : '$examCount exams',

              color: const Color(0xFFC0392B),
              onTap: () => widget.onNavigate(2),
            ),
            DashboardCard(
              icon: Icons.task_alt,
              label: 'Assignments',
              subtitle: assignmentCount == 1
                  ? '1 assignment'
                  : '$assignmentCount assignments',
              color: const Color(0xFF2E7D5E),
              onTap: () => widget.onNavigate(3),
            ),
            DashboardCard(
              icon: Icons.calendar_month_rounded,
              label: 'Calendar',
              subtitle: 'View calendar',
              color: const Color(0xFF475569),
              onTap: () => widget.onNavigate(4),
            ),
          ],
        );
      },
    );
  }

  // ─── Empty-state placeholder card ─────────────────────────────────────────

  Widget _buildPlaceholderCard(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFCBD5E1), size: 16),
          ),
          const SizedBox(width: 12),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentPreviewCard(String title, DateTime dueDate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.task_alt,
              color: Color(0xFF2E7D5E),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Due: ${dueDate.day}/${dueDate.month}/${dueDate.year}',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
