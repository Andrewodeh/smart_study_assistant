import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/exam_viewmodel.dart';
import 'views/exams_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ExamViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Exams Countdown',
      home: const ExamsScreen(),
    );
  }
}
