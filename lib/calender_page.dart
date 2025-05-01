import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'TaskModel.dart';
import 'main.dart';

class CalendarPage extends StatefulWidget {
  final TaskModel taskModel;

  const CalendarPage({super.key, required this.taskModel});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  bool _showLabels = true;
  bool _showCompleted = true;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF4A4380);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(context),
          SizedBox(height: 20),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
              ],
            ),
            child: TableCalendar(
              focusedDay: focusedDay,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2060, 12, 31),
              selectedDayPredicate: (day) => isSameDay(selectedDay, day),
              onDaySelected: (selected, focused) {
                setState(() {
                  selectedDay = selected;
                  focusedDay = focused;
                });
              },
              eventLoader: (day) {
                return widget.taskModel.tasks.where((task) {
                  final DateTime taskDate = task['date'];
                  return isSameDay(taskDate, day);
                }).toList();
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: primaryColor, // Purple dot
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                markersAlignment: Alignment.bottomCenter,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ),
          SizedBox(height: 20),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Tasks for ${selectedDay != null ? DateFormat('EEEE dd-MM-yyyy').format(selectedDay!) : 'Today'}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(child: _buildTaskCardsForSelectedDate()),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: primaryColor,
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        elevation: 8.0,
        child: Container(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.list_alt_outlined,
                    color: Colors.white.withOpacity(0.7), size: 30),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TaskScreen(widget.taskModel)),
                  );
                },
              ),
              SizedBox(width: 40),
              IconButton(
                icon: Icon(Icons.calendar_today_outlined,
                    color: Colors.white, size: 28),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    double topPadding = MediaQuery.of(context).padding.top;
    final now = DateTime.now();
    final formattedDate = DateFormat('d MMM').format(now);

    return Container(
      padding: EdgeInsets.only(
          top: topPadding + 15, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: Color(0xFF4A4380),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.grid_view_rounded,
                    color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      icon: Icon(Icons.search,
                          color: Colors.white.withOpacity(0.8)),
                      hintText: 'Search Tasks...',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.8)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, color: Colors.white, size: 28),
                onSelected: (String result) {
                  setState(() {
                    if (result == 'show_label') _showLabels = !_showLabels;
                    if (result == 'show_completed')
                      _showCompleted = !_showCompleted;
                  });
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'show_label',
                    child: Row(
                      children: [
                        Icon(Icons.label_outline, color: Color(0xFF4A4380)),
                        SizedBox(width: 12),
                        Text('Show Label'),
                        Spacer(),
                        if (_showLabels)
                          Icon(Icons.check, color: Color(0xFF4A4380)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'show_completed',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: Color(0xFF4A4380)),
                        SizedBox(width: 12),
                        Text('Show Completed'),
                        Spacer(),
                        if (_showCompleted)
                          Icon(Icons.check, color: Color(0xFF4A4380)),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
          SizedBox(height: 20),
          Text('Today, $formattedDate',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          SizedBox(height: 5),
          Text('Calendar',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTaskCardsForSelectedDate() {
    final Color primaryColor = Color(0xFF4A4380);
    final selectedDate = this.selectedDay ?? DateTime.now();

    final tasks = widget.taskModel.tasks.where((task) {
      final taskDate = task['date'] as DateTime;
      return isSameDay(taskDate, selectedDate);
    }).toList();

    if (tasks.isEmpty) {
      return Center(child: Text("No tasks for this date."));
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final labelColor = _getLabelColor(task['label']);
        return Card(
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
            title: Text(
              task['title'],
              style: TextStyle(
                color: primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              DateFormat('dd MMM yyyy').format(task['date']),
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            trailing: _showLabels
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: labelColor.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      task['label'],
                      style: TextStyle(
                        color: labelColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }

  Color _getLabelColor(String label) {
    switch (label) {
      case 'Study':
        return Colors.teal;
      case 'Sports':
        return Colors.orange;
      case 'Work':
        return Colors.indigo;
      case 'Personal':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}
