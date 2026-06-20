import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/subject.dart';
import 'models/exam.dart';
import 'models/assignment.dart';
import 'repositories/subject_repository.dart';
import 'repositories/exam_repository.dart';
import 'repositories/assignment_repository.dart';
import 'viewmodels/calender_viewmodel.dart';
import 'views/subjects_screen.dart';
import 'views/calender_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Initialise Hive ──
  await Hive.initFlutter();

  // ── 2. Register all type adapters ──
  Hive.registerAdapter(SubjectAdapter());    // typeId 0
  Hive.registerAdapter(ExamAdapter());       // typeId 1
  Hive.registerAdapter(AssignmentAdapter()); // typeId 2

  // ── 3. Open the boxes once at startup ──
  await Hive.openBox<Subject>('subjects_box');
  await Hive.openBox<Exam>('exams_box');
  await Hive.openBox<Assignment>('assignments_box');

  // ── 4. Seed test data (REMOVE when teammates finish tasks 3 & 4) ──
  await _seedTestData();

  runApp(const MyApp());
}

// Adds a few fake exams and assignments so the calendar shows events.
// Only inserts if the boxes are empty to avoid duplicates on restart.
Future<void> _seedTestData() async {
  final examBox = Hive.box<Exam>('exams_box');
  final assignBox = Hive.box<Assignment>('assignments_box');
final subjectBox = Hive.box<Subject>('subjects_box');


if (subjectBox.isEmpty) {
  await subjectBox.putAll({
    'sub_1': Subject(
      id: 'sub_1',
      name: 'Mobile App Eng',
      code: 'CS-322',
      instructor: 'Dr. John',
      creditHours: 3,
      colorValue: 0xFF2196F3,
    ),
    'sub_2': Subject(
      id: 'sub_2',
      name: 'Data Science',
      code: 'CS-440',
      instructor: 'Dr. Sara',
      creditHours: 3,
      colorValue: 0xFF4CAF50,
    ),
  });
}
  if (examBox.isEmpty) {
    final now = DateTime.now();
    await examBox.putAll({
      'exam_1': Exam(
        id: 'exam_1',
        title: 'Midterm Exam',
        subjectId: 'sub_1',
        subjectName: 'Mobile App Eng',
        date: DateTime(now.year, now.month, now.day + 3),
        location: 'Hall A',
      ),
      'exam_2': Exam(
        id: 'exam_2',
        title: 'Final Exam',
        subjectId: 'sub_2',
        subjectName: 'Data Science',
        date: DateTime(now.year, now.month, now.day + 10),
        location: 'Hall B',
      ),
      'exam_3': Exam(
        id: 'exam_3',
        title: 'Quiz 1',
        subjectId: 'sub_1',
        subjectName: 'Mobile App Eng',
        date: DateTime(now.year, now.month, now.day),  // today
      ),
    });
  }

  if (assignBox.isEmpty) {
    final now = DateTime.now();
    await assignBox.putAll({
      'assign_1': Assignment(
        id: 'assign_1',
        title: 'Lab Report #3',
        subjectId: 'sub_1',
        subjectName: 'Mobile App Eng',
        dueDate: DateTime(now.year, now.month, now.day + 3), // same day as midterm
        description: 'Submit via Moodle',
      ),
      'assign_2': Assignment(
        id: 'assign_2',
        title: 'Research Paper',
        subjectId: 'sub_2',
        subjectName: 'Data Science',
        dueDate: DateTime(now.year, now.month, now.day + 7),
        description: 'Min 10 pages, APA format',
      ),
      'assign_3': Assignment(
        id: 'assign_3',
        title: 'HW 2 - Flutter UI',
        subjectId: 'sub_1',
        subjectName: 'Mobile App Eng',
        dueDate: DateTime(now.year, now.month, now.day), // today
        isCompleted: true,
      ),
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Study Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final ExamRepository _examRepo = HiveExamRepository();
  final AssignmentRepository _assignmentRepo = HiveAssignmentRepository();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const SubjectsScreen(),
      CalendarScreen(
        viewModel: CalendarViewModel(_examRepo, _assignmentRepo),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.indigo,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Subjects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
        ],
      ),
    );
  }
}