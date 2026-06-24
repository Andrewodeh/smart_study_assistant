import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/exam_viewmodel.dart';
import '../models/subject.dart';
import '../viewmodels/subject_viewmodel.dart';
import '../widgets/subject_picker_field.dart';
import '../services/notification_service.dart';

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
        heroTag: 'exams_fab',
        onPressed: () {
          _showAddDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  //  Add Exam Dialog
  void _showAddDialog(BuildContext context) {
    final subjects =
        Provider.of<SubjectViewModel>(context, listen: false).allSubjects;

    showDialog(
      context: context,
      builder: (_) => _ExamFormDialog(
        title: 'Add Exam',
        confirmLabel: 'Add',
        subjects: subjects,
        onSubmit: (subject, date) {
          Provider.of<ExamViewModel>(context, listen: false)
              .addExam(subject, date);
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, dynamic exam) {
    final subjects =
        Provider.of<SubjectViewModel>(context, listen: false).allSubjects;

    showDialog(
      context: context,
      builder: (_) => _ExamFormDialog(
        title: 'Edit Exam',
        confirmLabel: 'Save',
        subjects: subjects,
        initialSubject: exam.subject as String,
        initialDate: exam.examDate as DateTime,
        onSubmit: (subject, date) {
          Provider.of<ExamViewModel>(context, listen: false)
              .updateExam(exam.id, subject, date);
        },
      ),
    );
  }
}

/// Add/Edit exam dialog with a filterable subject selector.
///
/// The subject field is an [Autocomplete] populated from the user's saved
/// subjects: typing filters the list by name or code, and the user can still
/// type a custom subject if it isn't in the list.
class _ExamFormDialog extends StatefulWidget {
  final String title;
  final String confirmLabel;
  final List<Subject> subjects;
  final String? initialSubject;
  final DateTime? initialDate;
  final void Function(String subject, DateTime date) onSubmit;

  const _ExamFormDialog({
    required this.title,
    required this.confirmLabel,
    required this.subjects,
    required this.onSubmit,
    this.initialSubject,
    this.initialDate,
  });

  @override
  State<_ExamFormDialog> createState() => _ExamFormDialogState();
}

class _ExamFormDialogState extends State<_ExamFormDialog> {
  late String _subject = widget.initialSubject ?? '';
  late DateTime? _selectedDate = widget.initialDate;
  String? _error;

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  void _submit() {
    if (_subject.trim().isEmpty) {
      setState(() => _error = 'Please choose or enter a subject.');
      return;
    }
    if (_selectedDate == null) {
      setState(() => _error = 'Please select a date.');
      return;
    }
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (_selectedDate!.isBefore(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exam date cannot be in the past.')),
      );
      return;
    }
    final bool isAdding = widget.initialSubject == null;
    final messenger = ScaffoldMessenger.of(context);
    widget.onSubmit(_subject.trim(), _selectedDate!);
    if (isAdding) {
      NotificationService.showInstantNotification(
        title: 'Exam Added',
        body: '${_subject.trim()} exam was added successfully.',
      ).ignore();
      NotificationService.scheduleExamReminder(
        subject: _subject.trim(),
        examDate: _selectedDate!,
      ).ignore();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Exam added successfully.'),
          duration: Duration(seconds: 5),
        ),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Filterable subject selector ──
            SubjectPickerField(
              subjects: widget.subjects,
              initialValue: widget.initialSubject,
              onChanged: (v) => setState(() {
                _subject = v;
                _error = null;
              }),
            ),

            const SizedBox(height: 14),

            // ── Date picker ──
            OutlinedButton.icon(
              onPressed: () async {
                final today = DateTime(DateTime.now().year,
                    DateTime.now().month, DateTime.now().day);
                final picked = await showDatePicker(
                  context: context,
                  firstDate: today,
                  lastDate: DateTime(2035),
                  initialDate: (_selectedDate != null &&
                          !_selectedDate!.isBefore(today))
                      ? _selectedDate!
                      : today,
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                    _error = null;
                  });
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedDate == null
                    ? 'Select Date'
                    : 'Date: ${_formatDate(_selectedDate!)}',
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
