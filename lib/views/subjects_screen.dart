import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subject.dart';
import '../viewmodels/subject_viewmodel.dart';
import '../widgets/page_container.dart';
import 'subject_form_screen.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final TextEditingController _searchController = TextEditingController();

  // The shared, Hive-backed view model registered in main.dart. Reading it
  // here (instead of creating a local one) means subjects added on this screen
  // are immediately reflected on the dashboard and in the exam/assignment
  // subject pickers, all from the same local store.
  SubjectViewModel get _viewModel => context.read<SubjectViewModel>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String query) async {
    await _viewModel.search(query);
  }

  Future<void> _openAddForm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubjectFormScreen(viewModel: _viewModel),
      ),
    );
  }

  Future<void> _openEditForm(Subject subject) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubjectFormScreen(viewModel: _viewModel, subject: subject),
      ),
    );
  }

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
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE53E3E),
            ),
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
    final vm = context.watch<SubjectViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Subjects')),
      body: PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page subtitle
            const Text(
              'Manage your study subjects and course details.',
              style: TextStyle(fontSize: 13.5, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),

            // Search field
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search subjects…',
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Subject list or empty state
            Expanded(
              child: vm.subjects.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: vm.subjects.length,
                      itemBuilder: (context, index) {
                        final Subject subject = vm.subjects[index];
                        return _buildSubjectCard(subject);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'subjects_fab',
        onPressed: _openAddForm,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ─── Subject list card ────────────────────────────────────────────────────

  Widget _buildSubjectCard(Subject subject) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: Color(subject.colorValue),
          radius: 22,
          child: Text(
            subject.name.isNotEmpty ? subject.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text(
          subject.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        subtitle: _buildSubtitle(subject).isNotEmpty
            ? Text(
                _buildSubtitle(subject),
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12.5,
                ),
              )
            : null,
        onTap: () => _openEditForm(subject),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline,
            color: Color(0xFFE53E3E),
            size: 20,
          ),
          onPressed: () => _confirmDelete(subject),
        ),
      ),
    );
  }

  // ─── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.book_outlined,
              color: Color(0xFF94A3B8),
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No subjects yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap + to add your first subject.',
            style: TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  // ─── Subtitle builder (logic unchanged) ──────────────────────────────────

  String _buildSubtitle(Subject subject) {
    final List<String> parts = [];
    if (subject.code.isNotEmpty) parts.add(subject.code);
    if (subject.instructor.isNotEmpty) parts.add(subject.instructor);
    if (subject.creditHours > 0) parts.add('${subject.creditHours} cr');
    return parts.join('  •  ');
  }
}
