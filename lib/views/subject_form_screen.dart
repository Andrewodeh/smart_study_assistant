import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../viewmodels/subject_viewmodel.dart';
import '../widgets/page_container.dart';

// One screen that handles BOTH adding and editing a subject:
//   - subject == null  → ADD mode
//   - subject != null  → EDIT mode (fields are pre-filled)
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

  // Save logic is unchanged — reads from controllers and selected color.
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subject name cannot be empty')),
      );
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.subject != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Subject' : 'Add Subject'),
      ),
      body: PageContainer(
        child: ListView(
          children: [
            // Page subtitle
            Text(
              isEditing
                  ? 'Update the course details for this subject.'
                  : 'Fill in the course details for your study plan.',
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),

            // Form card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildField(
                    label: 'Subject name *',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    label: 'Course code (optional)',
                    controller: _codeController,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    label: 'Instructor (optional)',
                    controller: _instructorController,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    label: 'Credit hours (optional)',
                    controller: _creditController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  _buildColorPicker(),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Save / Add button — styled via elevatedButtonTheme in main.dart
            ElevatedButton(
              onPressed: _save,
              child: Text(isEditing ? 'Save Changes' : 'Add Subject'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── Reusable field builder ───────────────────────────────────────────────

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
    );
  }

  // ─── Color picker ─────────────────────────────────────────────────────────

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SUBJECT COLOR',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          children: _colors.map((color) {
            final bool isSelected = _selectedColor == color;
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Color(color),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0F1F3D)
                        : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Color(color).withValues(alpha: 0.45),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
