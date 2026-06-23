import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/exam_viewmodel.dart';

class ExamsScreen extends StatelessWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            ),
          ],
        ),
      ),

      body: vm.exams.isEmpty
          ? const Center(
              child: Text("No Exams Yet", style: TextStyle(fontSize: 18)),
            )
          : ListView.builder(
              itemCount: vm.exams.length,
              itemBuilder: (context, index) {
                final exam = vm.exams[index];
                final days = vm.getDaysLeft(exam.examDate);
                final isNear = days <= 5;

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
                    color: isNear ? Colors.red.shade50 : null,
                    margin: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isNear ? Colors.red : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.book),
                              const SizedBox(width: 8),

                              Expanded(
                                child: Text(
                                  exam.subject,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showEditDialog(context, exam);
                                },
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
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, dynamic exam) {
    final subjectController = TextEditingController(text: exam.subject);

    DateTime selectedDate = exam.examDate;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Exam"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: "Subject",
                prefixIcon: Icon(Icons.book),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: const Text("Change Date"),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2035),
                  initialDate: selectedDate,
                );

                if (picked != null) {
                  selectedDate = picked;
                }
              },
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
              Provider.of<ExamViewModel>(
                context,
                listen: false,
              ).updateExam(exam.id, subjectController.text, selectedDate);

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
