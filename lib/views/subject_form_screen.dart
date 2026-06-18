import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../viewmodels/subject_viewmodel.dart';

// ----------------------------
// One screen that handles BOTH adding and editing a subject:
//   - subject == null  -> ADD mode
//   - subject != null  -> EDIT mode (fields are pre-filled)
// It uses the same ViewModel instance passed from the list screen, so all
// the data logic still lives in the ViewModel.
// ----------------------------
class SubjectFormScreen extends StatefulWidget {
  final SubjectViewModel viewModel;
  final Subject? subject;

  const SubjectFormScreen({
    super.key,
    required this.viewModel,
    this.subject,
  });

  @override
  State<SubjectFormScreen> createState() => _SubjectFormScreenState();
}

class _SubjectFormScreenState extends State<SubjectFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _instructorController = TextEditingController();
  final TextEditingController _creditController = TextEditingController();

  // The colors the user can choose for a subject.
  final List<int> _colors = [
    0xFF2196F3, // blue
    0xFFF44336, // red
    0xFF4CAF50, // green
    0xFFFF9800, // orange
    0xFF9C27B0, // purple
    0xFF009688, // teal
  ];
  int _selectedColor = 0xFF2196F3;

  @override
  void initState() {
    super.initState();
    // If we are editing, fill the fields with the existing values.
    if (widget.subject != null) {
      final Subject s = widget.subject!;
      _nameController.text = s.name;
      _codeController.text = s.code;
      _instructorController.text = s.instructor;
      _creditController.text =
          s.creditHours > 0 ? s.creditHours.toString() : '';
      _selectedColor = s.colorValue;
    }
  }

  // Save the form (add or update depending on the mode).
  Future<void> _save() async {
    final String name = _nameController.text;
    final String code = _codeController.text;
    final String instructor = _instructorController.text;
    final int creditHours = int.tryParse(_creditController.text.trim()) ?? 0;

    bool ok;
    if (widget.subject == null) {
      ok = await widget.viewModel.addSubject(
        name: name,
        code: code,
        instructor: instructor,
        creditHours: creditHours,
        colorValue: _selectedColor,
      );
    } else {
      ok = await widget.viewModel.updateSubject(
        widget.subject!,
        name: name,
        code: code,
        instructor: instructor,
        creditHours: creditHours,
        colorValue: _selectedColor,
      );
    }

    if (!mounted) return;

    if (!ok) {
      // The name was empty -> show a message and stay on the form.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subject name cannot be empty')),
      );
      return;
    }

    Navigator.pop(context, true); // tell the list screen to refresh
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.subject != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Subject' : 'Add Subject'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Subject name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Course code (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _instructorController,
              decoration: const InputDecoration(
                labelText: 'Instructor (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _creditController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Credit hours (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Color'),
            const SizedBox(height: 8),
            // A row of color circles to pick from.
            Wrap(
              spacing: 12,
              children: _colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor: Color(color),
                    radius: 20,
                    child: _selectedColor == color
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }
}
