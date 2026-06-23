import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/assignment_model.dart';
import '../models/subject.dart';
import '../viewmodels/assignment_viewmodel.dart';
import '../viewmodels/subject_viewmodel.dart';
import '../widgets/page_container.dart';
import '../widgets/subject_picker_field.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AssignmentsContent();
  }
}

class _AssignmentsContent extends StatelessWidget {
  const _AssignmentsContent();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AssignmentViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      body: PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage your pending assignments and submission deadlines.',
              style: TextStyle(fontSize: 13.5, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: vm.assignments.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: vm.assignments.length,
                      itemBuilder: (context, index) {
                        final assignment = vm.assignments[index];
                        final daysLeft = vm.getDaysLeft(assignment.dueDate);

                        return _buildAssignmentCard(
                          context: context,
                          assignment: assignment,
                          daysLeft: daysLeft,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'assignments_fab',
        onPressed: () => _showAssignmentDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.task_alt, size: 42, color: AppColors.primary),
            SizedBox(height: 12),
            Text(
              'No Assignments Yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Click + to add your first assignment.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentCard({
    required BuildContext context,
    required AssignmentModel assignment,
    required int daysLeft,
  }) {
    final vm = Provider.of<AssignmentViewModel>(context, listen: false);

    Color statusColor;
    String statusText;

    if (assignment.isCompleted) {
      statusColor = AppColors.success;
      statusText = 'Completed';
    } else if (daysLeft < 0) {
      statusColor = AppColors.danger;
      statusText = 'Overdue';
    } else if (daysLeft == 0) {
      statusColor = AppColors.warning;
      statusText = 'Due Today';
    } else {
      statusColor = daysLeft <= 3 ? AppColors.warning : AppColors.success;
      statusText = '$daysLeft days left';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Checkbox(
          value: assignment.isCompleted,
          onChanged: (_) {
            vm.toggleCompleted(assignment.id);
          },
        ),
        title: Text(
          assignment.title,
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
            decoration: assignment.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (assignment.subject.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.book_outlined,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          assignment.subject,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                'Due: ${assignment.dueDate.day}/${assignment.dueDate.month}/${assignment.dueDate.year}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              statusText,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showAssignmentDialog(context, assignment: assignment);
                } else if (value == 'delete') {
                  NotificationService.cancelAssignmentReminder(assignment.id);
                  vm.deleteAssignment(assignment.id);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignmentDialog(
    BuildContext context, {
    AssignmentModel? assignment,
  }) {
    final subjects =
        Provider.of<SubjectViewModel>(context, listen: false).allSubjects;

    showDialog(
      context: context,
      builder: (_) => _AssignmentFormDialog(
        subjects: subjects,
        assignment: assignment,
      ),
    );
  }
}

/// Add/Edit assignment dialog with a filterable subject selector.
class _AssignmentFormDialog extends StatefulWidget {
  final List<Subject> subjects;
  final AssignmentModel? assignment;

  const _AssignmentFormDialog({required this.subjects, this.assignment});

  @override
  State<_AssignmentFormDialog> createState() => _AssignmentFormDialogState();
}

class _AssignmentFormDialogState extends State<_AssignmentFormDialog> {
  late final TextEditingController _titleController =
      TextEditingController(text: widget.assignment?.title ?? '');
  late String _subject = widget.assignment?.subject ?? '';
  late DateTime? _selectedDate = widget.assignment?.dueDate;
  String? _error;

  bool get _isEditing => widget.assignment != null;

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Please enter a title.');
      return;
    }
    if (_selectedDate == null) {
      setState(() => _error = 'Please select a due date.');
      return;
    }

    final vm = Provider.of<AssignmentViewModel>(context, listen: false);
    final subject = _subject.trim();

    try {
      if (_isEditing) {
        await vm.updateAssignment(
          widget.assignment!.id,
          title,
          _selectedDate!,
          subject: subject,
        );
      } else {
        final assignmentId =
            await vm.addAssignment(title, _selectedDate!, subject: subject);

        NotificationService.showInstantNotification(
          title: 'Assignment Added',
          body: '$title was added successfully.',
        );
        NotificationService.scheduleAssignmentReminder(
          assignmentId: assignmentId,
          assignmentTitle: title,
          dueDate: _selectedDate!,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (err, st) {
      // ignore: avoid_print
      print('Failed to add/update assignment: $err\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save assignment: $err')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Assignment' : 'Add Assignment'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Assignment Title',
                prefixIcon: Icon(Icons.task_alt),
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
            const SizedBox(height: 12),
            SubjectPickerField(
              subjects: widget.subjects,
              initialValue: widget.assignment?.subject,
              onChanged: (v) => setState(() {
                _subject = v;
                _error = null;
              }),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2035),
                  initialDate: _selectedDate ?? DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                    _error = null;
                  });
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedDate == null
                    ? 'Select Due Date'
                    : 'Due: ${_formatDate(_selectedDate!)}',
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
          child: Text(_isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
