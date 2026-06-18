import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../repositories/subject_repository.dart';
import '../viewmodels/subject_viewmodel.dart';
import 'subject_form_screen.dart';

// ----------------------------
// The Subjects screen (the "V" in MVVM).
// It owns NO logic. It creates a ViewModel, calls its methods, and calls
// setState() to rebuild from whatever the ViewModel currently holds.
// ----------------------------
class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  // Create the ViewModel and hand it a repository.
  // (Swap SharedPrefsSubjectRepository() for HiveSubjectRepository() later.)
  final SubjectViewModel _viewModel =
      SubjectViewModel(SharedPrefsSubjectRepository());

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  // Helper: ask the ViewModel to load, then rebuild.
  Future<void> _loadSubjects() async {
    await _viewModel.loadSubjects();
    setState(() {});
  }

  Future<void> _onSearchChanged(String query) async {
    await _viewModel.search(query);
    setState(() {});
  }

  // Open the form to ADD a new subject.
  Future<void> _openAddForm() async {
    final bool? saved = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectFormScreen(viewModel: _viewModel),
      ),
    );
    if (saved == true) {
      await _loadSubjects();
    }
  }

  // Open the form to EDIT an existing subject.
  Future<void> _openEditForm(Subject subject) async {
    final bool? saved = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SubjectFormScreen(viewModel: _viewModel, subject: subject),
      ),
    );
    if (saved == true) {
      await _loadSubjects();
    }
  }

  // Ask for confirmation, then delete.
  Future<void> _confirmDelete(Subject subject) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete "${subject.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _viewModel.deleteSubject(subject.id);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subjects')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Search box
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                labelText: 'Search subjects',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // List of subjects
            Expanded(
              child: _viewModel.subjects.isEmpty
                  ? const Center(child: Text('No subjects yet'))
                  : ListView.builder(
                      itemCount: _viewModel.subjects.length,
                      itemBuilder: (context, index) {
                        final Subject subject = _viewModel.subjects[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Color(subject.colorValue),
                              child: Text(
                                subject.name.isNotEmpty
                                    ? subject.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(subject.name),
                            subtitle: Text(_buildSubtitle(subject)),
                            onTap: () => _openEditForm(subject), // tap = edit
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(subject),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddForm,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Build the small grey line shown under the subject name.
  String _buildSubtitle(Subject subject) {
    final List<String> parts = [];
    if (subject.code.isNotEmpty) parts.add(subject.code);
    if (subject.instructor.isNotEmpty) parts.add(subject.instructor);
    if (subject.creditHours > 0) parts.add('${subject.creditHours} cr');
    return parts.join('  •  ');
  }
}
