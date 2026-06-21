import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:provider/provider.dart';
import '../viewmodels/exam_viewmodel.dart';
=======
import '../widgets/page_container.dart';
>>>>>>> 188ccf4 (Add smart study assistant screens and services)

class ExamsScreen extends StatelessWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final vm = Provider.of<ExamViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.school),
            SizedBox(width: 8),
            Text(
              "Exams Countdown",
              style: TextStyle(fontWeight: FontWeight.bold),
=======
    return Scaffold(
      appBar: AppBar(title: const Text('Exams')),
      body: PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Track your upcoming exams and test schedules.',
              style: TextStyle(fontSize: 13.5, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            _buildComingSoonCard(
              icon: Icons.assignment_outlined,
              iconBgColor: const Color(0xFFFEF2F2),
              iconColor: const Color(0xFFC0392B),
              message: 'Exam tracking will be available here. '
                  'Your teammate is currently building this feature.',
>>>>>>> 188ccf4 (Add smart study assistant screens and services)
            ),
          ],
        ),
      ),
<<<<<<< HEAD

      body: vm.exams.isEmpty
          ? const Center(
              child: Text("No Exams Yet", style: TextStyle(fontSize: 18)),
            )
          : ListView.builder(
              itemCount: vm.exams.length,
              itemBuilder: (context, index) {
                final exam = vm.exams[index];
                final days = vm.getDaysLeft(exam.examDate);

                return Dismissible(
                  key: Key(exam.id),

                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),

                  onDismissed: (_) {
                    vm.deleteExam(exam.id);
                  },

                  child: Card(
                    margin: const EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.book),
                              const SizedBox(width: 8),
                              Text(
                                exam.subject,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          //  Date
                          Row(
                            children: [
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 8),
                              Text(
                                "${exam.examDate.day}/${exam.examDate.month}/${exam.examDate.year}",
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          //  Countdown
                          Row(
                            children: [
                              const Icon(Icons.timer),
                              const SizedBox(width: 8),
                              Text(
                                "$days Days Left",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: days <= 5 ? Colors.red : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

      //  Add Exam Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  //  Add Exam Dialog
  void _showAddDialog(BuildContext context) {
    final subjectController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Exam"),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subject input
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: "Subject",
                prefixIcon: Icon(Icons.book),
              ),
            ),

            const SizedBox(height: 10),

            // Date picker
            ElevatedButton.icon(
              onPressed: () async {
                selectedDate = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2035),
                  initialDate: DateTime.now(),
                );
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text("Select Date"),
            ),
          ],
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () {
              if (subjectController.text.isNotEmpty && selectedDate != null) {
                Provider.of<ExamViewModel>(
                  context,
                  listen: false,
                ).addExam(subjectController.text, selectedDate!);

                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
=======
    );
  }

  Widget _buildComingSoonCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ],
            ),
>>>>>>> 188ccf4 (Add smart study assistant screens and services)
          ),
        ],
      ),
    );
  }
}
