import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../viewmodels/calender_viewmodel.dart';

class CalendarScreen extends StatefulWidget {
  final CalendarViewModel viewModel;
  const CalendarScreen({super.key, required this.viewModel});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<CalendarEvent> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await widget.viewModel.loadAllEvents();
    setState(() {
      _selectedEvents = widget.viewModel.getEventsForDay(_selectedDay);
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedEvents = widget.viewModel.getEventsForDay(selectedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Calendar'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: widget.viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Calendar widget ──
                TableCalendar<CalendarEvent>(
                  firstDay: DateTime.utc(2025, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: _onDaySelected,
                  // Load events for each day so dots get shown
                  eventLoader: (day) =>
                      widget.viewModel.getEventsForDay(day),
                  calendarStyle: CalendarStyle(
                    // Dot below days that have events
                    markerDecoration: const BoxDecoration(
                      color: Colors.indigo,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: Colors.indigo,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),

                const Divider(height: 1),

                // ── Event count badge ──
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        '${_selectedEvents.length} event(s) on '
                        '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Event list ──
                Expanded(
                  child: _selectedEvents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.event_available,
                                  size: 48, color: Colors.grey.shade300),
                              const SizedBox(height: 8),
                              Text(
                                'No events on this day',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _selectedEvents.length,
                          itemBuilder: (context, index) {
                            final event = _selectedEvents[index];
                            return _EventTile(event: event);
                          },
                        ),
                ),
              ],
            ),
      // Pull-to-refresh via FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: _loadAll,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}

// ── Single event card ──
class _EventTile extends StatelessWidget {
  final CalendarEvent event;
  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final isExam = event.type == 'exam';
    final color = isExam ? Colors.red.shade700 : Colors.teal.shade600;
    final icon = isExam ? Icons.school : Icons.assignment;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          event.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: event.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Text(event.subtitle),
        trailing: Chip(
          label: Text(
            isExam ? 'Exam' : 'Assignment',
            style: const TextStyle(fontSize: 11, color: Colors.white),
          ),
          backgroundColor: color,
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}