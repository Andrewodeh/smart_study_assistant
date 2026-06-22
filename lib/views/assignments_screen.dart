import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/assignment_model.dart';
import '../viewmodels/assignment_viewmodel.dart';
import '../widgets/page_container.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AssignmentViewModel(),
      child: const _AssignmentsContent(),
    );
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
            Icon(Icons.task_alt, size: 42, color: Color(0xFF2E7D5E)),
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
      statusColor = const Color(0xFF2E7D5E);
      statusText = 'Completed';
    } else if (daysLeft < 0) {
      statusColor = Colors.red;
      statusText = 'Overdue';
    } else if (daysLeft == 0) {
      statusColor = Colors.orange;
      statusText = 'Due Today';
    } else {
      statusColor = daysLeft <= 3 ? Colors.orange : const Color(0xFF2E7D5E);
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
          child: Text(
            'Due: ${assignment.dueDate.day}/${assignment.dueDate.month}/${assignment.dueDate.year}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
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
    final titleController = TextEditingController(
      text: assignment?.title ?? '',
    );

    DateTime? selectedDate = assignment?.dueDate;
    final isEditing = assignment != null;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Assignment' : 'Add Assignment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Assignment Title',
                  prefixIcon: Icon(Icons.task_alt),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2035),
                    initialDate: selectedDate ?? DateTime.now(),
                  );

                  if (pickedDate != null) {
                    selectedDate = pickedDate;
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('Select Due Date'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty ||
                    selectedDate == null) {
                  return;
                }

                final vm = Provider.of<AssignmentViewModel>(
                  context,
                  listen: false,
                );

                if (isEditing) {
                  vm.updateAssignment(
                    assignment.id,
                    titleController.text.trim(),
                    selectedDate!,
                  );
                } else {
                  vm.addAssignment(titleController.text.trim(), selectedDate!);
                }

                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }
}
