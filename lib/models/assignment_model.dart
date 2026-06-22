class AssignmentModel {
  final String id;
  String title;
  DateTime dueDate;
  bool isCompleted;

  AssignmentModel({
    required this.id,
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
  });
}
