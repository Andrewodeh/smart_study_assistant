import 'package:flutter/material.dart';
import '../models/subject.dart';

/// A filterable subject selector built on [Autocomplete].
///
/// Typing filters the saved [subjects] by name or code; selecting one fills
/// the field. The user can also type a custom subject that isn't in the list.
/// [onChanged] reports the current text (whether typed or selected).
class SubjectPickerField extends StatelessWidget {
  final List<Subject> subjects;
  final String? initialValue;
  final ValueChanged<String> onChanged;

  const SubjectPickerField({
    super.key,
    required this.subjects,
    required this.onChanged,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Subject>(
      initialValue: TextEditingValue(text: initialValue ?? ''),
      displayStringForOption: (s) => s.name,
      optionsBuilder: (value) {
        final q = value.text.trim().toLowerCase();
        if (q.isEmpty) return subjects;
        return subjects.where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.code.toLowerCase().contains(q));
      },
      onSelected: (s) => onChanged(s.name),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Subject',
            hintText: subjects.isEmpty
                ? 'Type a subject (no subjects saved yet)'
                : 'Search or type a subject',
            prefixIcon: const Icon(Icons.book),
            suffixIcon:
                subjects.isEmpty ? null : const Icon(Icons.arrow_drop_down),
          ),
          onChanged: onChanged,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220, maxWidth: 320),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final s = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 12,
                      backgroundColor: Color(s.colorValue),
                    ),
                    title: Text(s.name),
                    subtitle: s.code.isEmpty ? null : Text(s.code),
                    onTap: () => onSelected(s),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
