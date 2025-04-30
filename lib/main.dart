import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/rendering.dart';
import 'calender_page.dart';

void main() {
  debugPaintSizeEnabled = false;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TaskScreen(),
      title: 'Todoire',
    );
  }
}

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final Color primaryColor = Color(0xFF4A4380);
  final Color searchBarColor = Colors.white30;
  final Color addbutton = Color(0xFF4A4380);
  final Color bottomNavBarColor = Color(0xFF4A4380);
  final Color iconColor = Colors.white;
  final Color bottomIconColor = Colors.white;
  final Color checkColor = Color(0xFF4A4380);
  bool _showLabels = true;
  bool _showCompleted = true;
  int? selectedTaskIndex;
  Set<int> completedTasks = {};
  List<Map<String, dynamic>> tasks = [];

  void _handleSort() {
    print("Sort action triggered!");
  }

  Color getLabelColor(String label) {
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

  void _showAddTaskBottomSheet(BuildContext context) {
    String newTask = '';
    DateTime? selectedDate;
    String? selectedLabel;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'What would you like to do?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      newTask = value;
                    },
                  ),
                  SizedBox(height: 15),
                  GestureDetector(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        selectedDate == null
                            ? 'Select a date'
                            : DateFormat('EEEE dd-MM-yyyy').format(selectedDate!),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Label',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value: selectedLabel,
                    items: ['Study', 'Sports', 'Work', 'Personal']
                        .map((label) => DropdownMenuItem(
                      value: label,
                      child: Text(label),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedLabel = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        if (newTask.trim().isNotEmpty &&
                            selectedDate != null &&
                            selectedLabel != null) {
                          setState(() {
                            tasks.add({
                              'title': newTask.trim(),
                              'date': selectedDate,
                              'label': selectedLabel,
                              'completed': false,
                            });
                          });
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(14),
                        backgroundColor: Color(0xFF4A4380),
                      ),
                      child: Icon(Icons.arrow_upward, color: Colors.white),
                    ),
                  )
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: tasks.isEmpty
                ? Center(child: Text('No tasks yet. Tap + to add one!'))
                : ListView.builder(
              padding: EdgeInsets.all(20),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                    leading: Checkbox(
                      value: completedTasks.contains(index),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            completedTasks.add(index);
                          } else {
                            completedTasks.remove(index);
                          }
                        });
                      },
                      activeColor: checkColor,
                    ),
                    title: Text(
                      tasks[index]['title'],
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        decoration: completedTasks.contains(index)
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(
                      '${DateFormat('dd MMM yyyy').format(tasks[index]['date'])}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: getLabelColor(tasks[index]['label']).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tasks[index]['label'],
                        style: TextStyle(
                          color: getLabelColor(tasks[index]['label']),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskBottomSheet(context);
        },
        child: Icon(Icons.add, size: 30, color: Colors.white),
        backgroundColor: addbutton,
        shape: CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }
  Widget _buildHeader(BuildContext context) {
    double topPadding = MediaQuery.of(context).padding.top;
    final now = DateTime.now();
    final formattedDate = DateFormat('d MMM').format(now);
    final String displayDateString = 'Today, $formattedDate';

    return Container(
      padding: EdgeInsets.only(
          top: topPadding + 15, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: Icon(Icons.grid_view_rounded,
                      color: iconColor, size: 28),
                  onPressed: () {}),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: searchBarColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      icon: Icon(Icons.search,
                          color: iconColor.withAlpha((0.8 * 255).toInt())),
                      hintText: 'Search',
                      hintStyle: TextStyle(
                          color: iconColor.withAlpha((0.8 * 255).toInt())),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, color: iconColor, size: 28),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                elevation: 4,
                onSelected: (String result) {
                  setState(() {
                    switch (result) {
                      case 'show_label':
                        _showLabels = !_showLabels;
                        break;
                      case 'show_completed':
                        _showCompleted = !_showCompleted;
                        break;
                      case 'sort':
                        _handleSort();
                        break;
                    }
                  });
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  _buildPopupMenuItem(
                      context: context,
                      icon: Icons.label_outline,
                      title: 'Show Label',
                      value: 'show_label',
                      showCheck: _showLabels,
                      checkColor: checkColor),
                  _buildPopupMenuItem(
                      context: context,
                      icon: Icons.check_circle_outline,
                      title: 'Show Completed',
                      value: 'show_completed',
                      showCheck: _showCompleted,
                      checkColor: checkColor),
                  _buildPopupMenuItem(
                      context: context,
                      icon: Icons.sort,
                      title: 'Sort',
                      value: 'sort'),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(displayDateString,
              style: TextStyle(
                  color: iconColor.withAlpha((0.8 * 255).toInt()),
                  fontSize: 14)),
          SizedBox(height: 5),
          Text('My tasks',
              style: TextStyle(
                  color: iconColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    bool showCheck = false,
    Color? checkColor,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF4A4380)),
          SizedBox(width: 12),
          Text(title),
          Spacer(),
          if (showCheck) Icon(Icons.check, color: checkColor),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomAppBar(
      color: bottomNavBarColor,
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
                    color: bottomIconColor, size: 30),
                onPressed: () {}),
            SizedBox(width: 40),
            IconButton(
              icon: Icon(Icons.calendar_today_outlined,
                  color: bottomIconColor, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalendarPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
