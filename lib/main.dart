import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/rendering.dart';
import 'calender_page.dart';
import 'login-screen.dart';
import 'onboarding-screen.dart';
import 'signup-screen.dart';
import 'dashboard-screen.dart';
import 'TaskModel.dart';
import 'package:flutter/foundation.dart';

void main() {
  debugPaintSizeEnabled = false;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final TaskModel taskModelInstance = TaskModel();

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) =>

            DashboardScreen(taskModel: taskModelInstance),
        '/taskscreen': (context) => TaskScreen(taskModelInstance),
        '/calender': (context) => CalendarPage(taskModel: taskModelInstance),
      },
      title: 'Todoire',
    );
  }
}

class TaskScreen extends StatefulWidget {
  final TaskModel taskModel;

  const TaskScreen(this.taskModel, {Key? key}) : super(key: key);

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  // --- State Variables ---
  final Color primaryColor = const Color(0xFF4A4380);
  final Color searchBarColor = Colors.white30;
  final Color addbutton = const Color(0xFF4A4380);
  final Color bottomNavBarColor = const Color(0xFF4A4380);
  final Color iconColor = Colors.white;
  final Color bottomIconColor = Colors.white;
  final Color checkColor = const Color(0xFF4A4380);

  bool _showLabels = true;
  bool _showCompleted = true;
  Set<int> completedTasks = {};
  SortCriteria _currentSort = SortCriteria.dueDate;
  List<String> _completedTaskIdsBeforeSort = [];

  List<Map<String, dynamic>> get tasks => widget.taskModel.tasks;

  @override
  void initState() {
    super.initState();
    widget.taskModel.addListener(_onTaskModelChanged);
  }

  @override
  void dispose() {
    widget.taskModel.removeListener(_onTaskModelChanged);
    super.dispose();
  }

  void _onTaskModelChanged() {
    _recalculateCompletedIndices();
    if (mounted) {
      setState(() {});
    }
  }

  void _recalculateCompletedIndices() {
    Set<int> newCompletedTasks = {};
    List<Map<String, dynamic>> currentTasks = widget.taskModel.tasks;

    if (_completedTaskIdsBeforeSort.isNotEmpty) {
      for (int i = 0; i < currentTasks.length; i++) {
        if (currentTasks[i]['id'] != null &&
            _completedTaskIdsBeforeSort.contains(currentTasks[i]['id'])) {
          newCompletedTasks.add(i);
        }
      }
    } else {
      newCompletedTasks = Set.from(completedTasks);
    }
    if (!setEquals(completedTasks, newCompletedTasks)) {
      completedTasks = newCompletedTasks;
    }
    _completedTaskIdsBeforeSort = [];
  }

  void _handleSortSelection(SortCriteria criteria) {
    _completedTaskIdsBeforeSort = completedTasks
        .where((index) =>
            index >= 0 && index < tasks.length && tasks[index]['id'] != null)
        .map((index) => tasks[index]['id'] as String)
        .toList();

    setState(() {
      _currentSort = criteria;
    });
    widget.taskModel.sortTasks(criteria);
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
        shape: const RoundedRectangleBorder(
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
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          selectedDate == null
                              ? 'Select a date'
                              : DateFormat('EEEE, dd MMM yyyy')
                                  .format(selectedDate!),
                          style: TextStyle(
                              color: selectedDate == null
                                  ? Colors.grey[600]
                                  : Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
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
                      hint: const Text('Select a label'),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: (newTask.trim().isNotEmpty &&
                                selectedDate != null &&
                                selectedLabel != null)
                            ? () {
                                widget.taskModel.addTask(
                                  title: newTask.trim(),
                                  date: selectedDate!,
                                  label: selectedLabel!,
                                );
                                Navigator.pop(context);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(14),
                          backgroundColor: primaryColor,
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child:
                            const Icon(Icons.arrow_upward, color: Colors.white),
                      ),
                    )
                  ],
                );
              },
            ),
          );
        });
  }

  void _showSortOptionsSheet(BuildContext context) {
    /* ... unchanged ... */
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sort by',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 15),
              RadioListTile<SortCriteria>(
                title: const Text('Due Date'),
                value: SortCriteria.dueDate,
                groupValue: _currentSort,
                onChanged: (SortCriteria? value) {
                  if (value != null && value != _currentSort) {
                    _handleSortSelection(value);
                  }
                  Navigator.pop(context);
                },
                secondary:
                    Icon(Icons.calendar_today_outlined, color: primaryColor),
                activeColor: primaryColor,
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<SortCriteria>(
                title: const Text('Label'),
                value: SortCriteria.label,
                groupValue: _currentSort,
                onChanged: (SortCriteria? value) {
                  if (value != null && value != _currentSort) {
                    _handleSortSelection(value);
                  }
                  Navigator.pop(context);
                },
                secondary: Icon(Icons.label_outline, color: primaryColor),
                activeColor: primaryColor,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> displayedTaskEntries = tasks
        .asMap()
        .entries
        .where((entry) {
          int currentIndex = entry.key;
          bool isCompleted = completedTasks.contains(currentIndex);
          return _showCompleted || !isCompleted;
        })
        .map((entry) => {
              'currentIndex': entry.key,
              'taskData': entry.value,
            })
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: displayedTaskEntries.isEmpty
                ? Center(
                    child: Text(_showCompleted
                        ? 'No tasks yet. Tap + to add one!'
                        : 'No pending tasks.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    itemCount: displayedTaskEntries.length,
                    itemBuilder: (context, displayedIndex) {
                      final entry = displayedTaskEntries[displayedIndex];
                      final int currentIndex = entry['currentIndex'] as int;
                      final Map<String, dynamic> taskData =
                          entry['taskData'] as Map<String, dynamic>;
                      final bool isCurrentlyCompleted =
                          completedTasks.contains(currentIndex);
                      final String taskId = taskData['id'] ?? '';

                      return Dismissible(
                        key: ValueKey('task_$taskId'),
                        // Use stable ID for key
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          final removedTaskData =
                              Map<String, dynamic>.from(taskData);
                          final bool wasCompleted =
                              completedTasks.contains(currentIndex);
                          final int removedIndex = currentIndex;
                          final String removedTaskId = taskId; // Store ID
                          _completedTaskIdsBeforeSort = completedTasks
                              .where((idx) =>
                                  idx != removedIndex &&
                                  idx >= 0 &&
                                  idx < tasks.length)
                              .map((idx) => tasks[idx]['id'] as String)
                              .toList();
                          widget.taskModel.removeTaskAt(removedIndex);
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text("'${removedTaskData['title']}' deleted"),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                              action: SnackBarAction(
                                label: "UNDO",
                                textColor: Colors.white,
                                onPressed: () {
                                  _completedTaskIdsBeforeSort = completedTasks
                                      .where((idx) =>
                                          idx >= 0 && idx < tasks.length)
                                      .map((idx) => tasks[idx]['id'] as String)
                                      .toList();
                                  if (wasCompleted) {
                                    _completedTaskIdsBeforeSort
                                        .add(removedTaskId);
                                  }
                                  widget.taskModel.insertTask(
                                      removedIndex, removedTaskData);
                                },
                              ),
                            ),
                          );
                        },
                        background: Container(
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.centerRight,
                          child: const Icon(
                            Icons.delete_forever,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            leading: Checkbox(
                              value: isCurrentlyCompleted,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    completedTasks.add(currentIndex);
                                  } else {
                                    completedTasks.remove(currentIndex);
                                  }
                                });
                                _completedTaskIdsBeforeSort = completedTasks
                                    .where(
                                        (idx) => idx >= 0 && idx < tasks.length)
                                    .map((idx) => tasks[idx]['id'] as String)
                                    .toList();
                              },
                              activeColor: checkColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                            title: Text(
                              taskData['title'],
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                decoration: isCurrentlyCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                decorationColor: primaryColor.withOpacity(0.7),
                                decorationThickness: 1.5,
                              ),
                            ),
                            subtitle: Text(
                              DateFormat('dd MMM yyyy')
                                  .format(taskData['date']),
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[700]),
                            ),
                            trailing: _showLabels
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: getLabelColor(taskData['label'])
                                          .withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      taskData['label'],
                                      style: TextStyle(
                                        color: getLabelColor(taskData['label']),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  )
                                : null,
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
        backgroundColor: addbutton,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    /* ... unchanged ... */
    double topPadding = MediaQuery.of(context).padding.top;
    final now = DateTime.now();
    final formattedDate = DateFormat('d MMM').format(now);
    final String displayDateString = 'Today, $formattedDate';

    return Container(
      padding: EdgeInsets.only(
          top: topPadding + 15, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon:
                      Icon(Icons.grid_view_rounded, color: iconColor, size: 28),
                  tooltip: 'Dashboard',
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  }),
              Expanded(
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: searchBarColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        icon: Icon(Icons.search,
                            color: iconColor.withOpacity(0.8)),
                        hintText: 'Search Tasks...',
                        hintStyle: TextStyle(color: iconColor.withOpacity(0.7)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.only(bottom: 10)),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, color: iconColor, size: 28),
                tooltip: 'More Options',
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                elevation: 4,
                onSelected: (String result) {
                  switch (result) {
                    case 'show_label':
                      setState(() => _showLabels = !_showLabels);
                      break;
                    case 'show_completed':
                      setState(() => _showCompleted = !_showCompleted);
                      break;
                    case 'sort':
                      _showSortOptionsSheet(context);
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  _buildPopupMenuItem(
                      context: context,
                      icon: Icons.label_outline,
                      title: 'Show Labels',
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
                  const PopupMenuDivider(),
                  _buildPopupMenuItem(
                      context: context,
                      icon: Icons.sort,
                      title: 'Sort',
                      value: 'sort',
                      showCheck: false),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(displayDateString,
              style:
                  TextStyle(color: iconColor.withOpacity(0.8), fontSize: 14)),
          const SizedBox(height: 5),
          Text('My Tasks',
              style: TextStyle(
                  color: iconColor, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    /* ... unchanged ... */
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required bool showCheck,
    Color? checkColor,
  }) {
    final Color activeColor = primaryColor;
    final Color textColor = Colors.black87;

    return PopupMenuItem<String>(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: activeColor, size: 22),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(color: textColor, fontSize: 16),
          ),
          const Spacer(),
          if (showCheck)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child:
                  Icon(Icons.check, color: checkColor ?? activeColor, size: 22),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomAppBar(
      color: bottomNavBarColor,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      elevation: 8.0,
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                icon: Icon(Icons.list_alt_outlined,
                    color: bottomIconColor, size: 30),
                tooltip: 'Tasks',
                onPressed: () {}),
            const SizedBox(width: 40),
            IconButton(
              icon: Icon(Icons.calendar_today_outlined,
                  color: bottomIconColor, size: 28),
              tooltip: 'Calendar',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/calender');
              },
            ),
          ],
        ),
      ),
    );
  }
}
