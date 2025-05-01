import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/rendering.dart';
import 'calender_page.dart';
import 'login-screen.dart';
import 'onboarding-screen.dart';
import 'signup-screen.dart';
import 'dashboard-screen.dart';

void main() {
  debugPaintSizeEnabled = false;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/taskscreen': (context) =>  TaskScreen(),
        // Added dashboard route
      },
      title: 'Todoire',
    );
  }
}

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  // --- State Variables ---
  final Color primaryColor = Color(0xFF4A4380);
  final Color searchBarColor = Colors.white30;
  final Color addbutton = Color(0xFF4A4380);
  final Color bottomNavBarColor = Color(0xFF4A4380);
  final Color iconColor = Colors.white;
  final Color bottomIconColor = Colors.white;
  final Color checkColor = Color(0xFF4A4380);

  bool _showLabels = true;       // Controls label visibility
  bool _showCompleted = true;    // Controls if completed tasks are shown
  Set<int> completedTasks = {};  // Stores original indices of completed tasks
  List<Map<String, dynamic>> tasks = []; // Master list of all tasks

  // --- Methods ---

  void _handleSort() {
    // Add sorting logic here if needed in the future
    print("Sort action triggered!");
    // Example: Sort by date
    // setState(() {
    //   tasks.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    //   // !! Important: After sorting, `completedTasks` indices might become invalid
    //   // if they aren't tied to a stable ID. Consider using unique IDs per task
    //   // and updating `completedTasks` to store IDs instead of indices if sorting is implemented.
    // });
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
      isScrollControlled: true, // Allows sheet to take more height
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          // Add padding to avoid keyboard overlap
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder( // Needed for date/label updates inside sheet
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min, // Take only needed height
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
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() { // Use setModalState to update sheet UI
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
                            : DateFormat('EEEE, dd MMM yyyy').format(selectedDate!), // Format date nicely
                        style: TextStyle(color: selectedDate == null ? Colors.grey[600] : Colors.black),
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
                      setModalState(() { // Use setModalState
                        selectedLabel = value;
                      });
                    },
                    hint: Text('Select a label'), // Add hint text
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: (newTask.trim().isNotEmpty && selectedDate != null && selectedLabel != null)
                          ? () { // Enable button only when fields are filled
                        setState(() { // Use main setState to update the main list
                          tasks.add({
                            'title': newTask.trim(),
                            'date': selectedDate!,
                            'label': selectedLabel!,
                            // 'id': DateTime.now().millisecondsSinceEpoch.toString(), // Consider adding unique ID
                          });
                        });
                        Navigator.pop(context); // Close the bottom sheet
                      }
                          : null, // Disable button if conditions not met
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(14),
                        backgroundColor: Color(0xFF4A4380),
                        disabledBackgroundColor: Colors.grey, // Style for disabled state
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

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    // Filter tasks based on _showCompleted status BEFORE building the list
    List<Map<String, dynamic>> displayedTaskEntries = tasks
        .asMap() // Get tasks with their original indices {0: task1, 1: task2, ...}
        .entries // Convert to iterable entries [MapEntry(0, task1), MapEntry(1, task2), ...]
        .where((entry) {
      int originalIndex = entry.key;
      bool isCompleted = completedTasks.contains(originalIndex);
      // Keep task if: showing completed tasks OR the task is not completed
      return _showCompleted || !isCompleted;
    })
        .map((entry) => {
      'originalIndex': entry.key, // Store the original index
      'taskData': entry.value,    // Store the task map itself
    })
        .toList(); // Convert back to a List

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(
        children: [
          _buildHeader(context), // Build the top header section
          Expanded(
            child: displayedTaskEntries.isEmpty
                ? Center(child: Text(_showCompleted ? 'No tasks yet. Tap + to add one!' : 'No pending tasks.')) // Different message based on filter
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10), // Adjusted padding
              itemCount: displayedTaskEntries.length, // Use the filtered list length
              itemBuilder: (context, displayedIndex) {
                // Get the original index and task data for this item in the filtered list
                final entry = displayedTaskEntries[displayedIndex];
                final int originalIndex = entry['originalIndex'] as int;
                final Map<String, dynamic> taskData = entry['taskData'] as Map<String, dynamic>;
                final bool isCurrentlyCompleted = completedTasks.contains(originalIndex); // Check completion using original index

                return Dismissible(
                  // Key needs to be unique, using original index helps
                  key: ValueKey('task_$originalIndex'), // More robust key
                  direction: DismissDirection.endToStart, // Allow swipe from right to left only
                  onDismissed: (direction) {
                    // --- Deletion Logic ---
                    final removedTaskData = Map<String, dynamic>.from(taskData); // Copy data before removal
                    final bool wasCompleted = completedTasks.contains(originalIndex); // Store completion state before removal

                    setState(() {
                      // 1. Remove from the master tasks list
                      //    Find the actual current index in `tasks` to remove reliably.
                      int indexInMasterList = tasks.indexWhere((t) => t == taskData); // Find by reference or unique ID if available
                      if (indexInMasterList != -1) {
                        tasks.removeAt(indexInMasterList);
                      } else {
                        print("Error: Task to delete not found in master list.");
                        // Optionally show an error message to the user
                        return; // Prevent further action if task not found
                      }


                      // 2. Update `completedTasks` set:
                      //    Remove the original index if present.
                      //    Adjust indices greater than the removed task's index in the MASTER list.
                      Set<int> updatedCompletedTasks = {};
                      if (completedTasks.contains(originalIndex)){
                        completedTasks.remove(originalIndex); // Remove it first
                      }

                      // Adjust remaining indices based on the index where removal happened in `tasks`
                      for (int completedIdx in completedTasks) {
                        if (completedIdx > indexInMasterList) { // Use index from master list for comparison
                          updatedCompletedTasks.add(completedIdx - 1);
                        } else {
                          updatedCompletedTasks.add(completedIdx);
                        }
                      }
                      completedTasks = updatedCompletedTasks; // Assign the updated set
                    });
                    // --- End Deletion ---

                    // --- Show SnackBar with Undo ---
                    ScaffoldMessenger.of(context).removeCurrentSnackBar(); // Remove any existing snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("'${removedTaskData['title']}' deleted"), // Show task title
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating, // Optional: Make it float
                        action: SnackBarAction(
                          label: "UNDO",
                          textColor: Colors.white,
                          onPressed: () {
                            // --- Undo Logic ---
                            setState(() {
                              // 1. Re-insert the task into the master list. Try original index, clamped for safety.
                              int insertIndex = originalIndex;
                              if (insertIndex > tasks.length) insertIndex = tasks.length;
                              if (insertIndex < 0) insertIndex = 0; // Clamp index

                              tasks.insert(insertIndex, removedTaskData);

                              // 2. Restore completion status & adjust `completedTasks` indices
                              //    Shift indices >= insertion point upwards.
                              Set<int> restoredCompletedTasks = {};
                              for (int completedIdx in completedTasks) {
                                if (completedIdx >= insertIndex) {
                                  restoredCompletedTasks.add(completedIdx + 1);
                                } else {
                                  restoredCompletedTasks.add(completedIdx);
                                }
                              }
                              // Add the original index back if it was completed
                              if (wasCompleted) {
                                restoredCompletedTasks.add(insertIndex);
                              }
                              completedTasks = restoredCompletedTasks; // Assign the restored set
                            });
                            // --- End Undo ---
                          },
                        ),
                      ),
                    );
                  },
                  // Background shown during swipe
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(16), // Match card shape
                    ),
                    margin: EdgeInsets.symmetric(vertical: 10), // Match card's vertical margin
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  // The actual task card
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 10), // Increased vertical margin makes cards distinct
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10), // Increased vertical padding
                      leading: Checkbox(
                        value: isCurrentlyCompleted, // Use completion status based on original index
                        onChanged: (bool? value) {
                          setState(() {
                            // Update `completedTasks` using the ORIGINAL index
                            if (value == true) {
                              completedTasks.add(originalIndex);
                            } else {
                              completedTasks.remove(originalIndex);
                            }
                            // If filtering is active, removing completion might instantly hide the task if _showCompleted is false
                          });
                        },
                        activeColor: checkColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), // Slightly rounded checkbox
                      ),
                      title: Text(
                        taskData['title'],
                        style: TextStyle(
                          color: primaryColor, // Use primary color for title
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          decoration: isCurrentlyCompleted
                              ? TextDecoration.lineThrough // Apply strikethrough if completed
                              : TextDecoration.none,
                          decorationColor: primaryColor.withOpacity(0.7), // Optional: Dimmer strikethrough
                          decorationThickness: 1.5,
                        ),
                      ),
                      subtitle: Text(
                        DateFormat('dd MMM yyyy').format(taskData['date']), // Format date nicely
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      trailing: _showLabels ? Container( // Conditionally display label based on _showLabels flag
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: getLabelColor(taskData['label']).withOpacity(0.25), // More defined background
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          taskData['label'],
                          style: TextStyle(
                            color: getLabelColor(taskData['label']), // Keep label text color solid
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ) : null, // Show nothing if labels are hidden
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // --- Floating Action Button ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskBottomSheet(context);
        },
        child: Icon(Icons.add, size: 30, color: Colors.white),
        backgroundColor: addbutton,
        shape: CircleBorder(), // Make it circular
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Dock it in the middle
      // --- Bottom Navigation Bar ---
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  // --- Helper Widgets ---

  Widget _buildHeader(BuildContext context) {
    double topPadding = MediaQuery.of(context).padding.top; // Get safe area top padding
    final now = DateTime.now();
    final formattedDate = DateFormat('d MMM').format(now); // Format like "30 Apr"
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
        boxShadow: [ // Optional: Add a subtle shadow
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: Icon(Icons.grid_view_rounded, color: iconColor, size: 28),
                  tooltip: 'Menu (Placeholder)', // Add tooltip
                  onPressed: () {
                    // Placeholder for potential side menu or other action
                  }),
              Expanded( // Allow search bar to take available space
                child: Container(
                  height: 40, // Give search bar a fixed height
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: searchBarColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        icon: Icon(Icons.search, color: iconColor.withOpacity(0.8)),
                        hintText: 'Search Tasks...', // More specific hint
                        hintStyle: TextStyle(color: iconColor.withOpacity(0.7)),
                        border: InputBorder.none, // Remove underline
                        contentPadding: EdgeInsets.only(bottom: 10) // Adjust vertical alignment
                    ),
                    // Add TextEditingController and onChanged for actual search functionality later
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, color: iconColor, size: 28),
                tooltip: 'More Options',
                color: Colors.white, // Background color of the menu
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                elevation: 4,
                onSelected: (String result) {
                  // Update state based on selection, triggering a rebuild
                  setState(() {
                    switch (result) {
                      case 'show_label':
                        _showLabels = !_showLabels;
                        break;
                      case 'show_completed':
                        _showCompleted = !_showCompleted;
                        break;
                      case 'sort':
                        _handleSort(); // Call the sort handler
                        break;
                    }
                  });
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  _buildPopupMenuItem( // Build menu item using helper
                      context: context,
                      icon: Icons.label_outline,
                      title: 'Show Labels',
                      value: 'show_label',
                      showCheck: _showLabels, // Pass current state for checkmark
                      checkColor: checkColor),
                  _buildPopupMenuItem(
                      context: context,
                      icon: Icons.check_circle_outline,
                      title: 'Show Completed',
                      value: 'show_completed',
                      showCheck: _showCompleted, // Pass current state
                      checkColor: checkColor),
                  PopupMenuDivider(), // Optional divider
                  _buildPopupMenuItem(
                      context: context,
                      icon: Icons.sort,
                      title: 'Sort',
                      value: 'sort',
                      showCheck: false), // Sort doesn't need a checkmark
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(displayDateString,
              style: TextStyle(
                  color: iconColor.withOpacity(0.8), fontSize: 14)),
          SizedBox(height: 5),
          Text('My Tasks',
              style: TextStyle(
                  color: iconColor, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- Single Definition for PopupMenuItem Builder ---
  // --- Updated PopupMenuItem Builder ---
  PopupMenuItem<String> _buildPopupMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required bool showCheck, // Required parameter
    Color? checkColor,
  }) {
    final Color activeColor = primaryColor; // Color for icons and potentially text
    final Color textColor = Colors.black87; // Or use primaryColor if you prefer purple text

    return PopupMenuItem<String>(
      value: value,
      // Add padding within each menu item for better spacing
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: activeColor, // Use the defined active color
            size: 22, // Slightly smaller icon size
          ),
          SizedBox(width: 16), // Increase spacing between icon and text
          Text(
            title,
            style: TextStyle(
              color: textColor, // Use defined text color
              fontSize: 16, // Slightly larger text
              // fontWeight: FontWeight.w500, // Optional: Make text slightly bolder
            ),
          ),
          Spacer(), // Pushes the check icon to the far right
          if (showCheck)
            Padding( // Add padding around the check icon if needed
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(
                Icons.check,
                color: checkColor ?? activeColor, // Use active color for check
                size: 22,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomAppBar(
      color: bottomNavBarColor,
      shape: CircularNotchedRectangle(), // Creates the notch for the FAB
      notchMargin: 8.0, // Space around the FAB
      elevation: 8.0, // Shadow below the bar
      child: Container(
        height: 65, // Standard height
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround, // Space items evenly
          children: [
            IconButton(
                icon: Icon(Icons.list_alt_outlined, color: bottomIconColor, size: 30),
                tooltip: 'Tasks',
                onPressed: () {
                  // Already on tasks screen, or navigate here if needed
                }),
            SizedBox(width: 40), // Placeholder to create space for the central FAB
            IconButton(
              icon: Icon(Icons.calendar_today_outlined, color: bottomIconColor, size: 28),
              tooltip: 'Calendar',
              onPressed: () {
                // Navigate to the Calendar Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalendarPage()), // Make sure CalendarPage is defined/imported
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

