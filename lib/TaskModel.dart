// lib/task_model.dart
import 'package:flutter/foundation.dart';

// *** ADD the enum definition HERE ***
enum SortCriteria { dueDate, label }

class TaskModel extends ChangeNotifier {
  List<Map<String, dynamic>> _tasks = [
    // Example initial data:
    // { 'id': '1', 'title': 'Finish Report', 'date': DateTime.now().add(const Duration(days: 1)), 'label': 'Work' },
    // { 'id': '2', 'title': 'Go Jogging', 'date': DateTime.now(), 'label': 'Sports' },
  ];

  List<Map<String, dynamic>> get tasks => List.unmodifiable(_tasks);

  int countByLabel(String label) {
    return _tasks.where((task) => task['label'] == label).length;
  }

  void addTask({required String title, required DateTime date, required String label}) {
    String id = DateTime.now().millisecondsSinceEpoch.toString() + title.hashCode.toString();
    _tasks.add({
      'id': id,
      'title': title,
      'date': date,
      'label': label,
    });
    notifyListeners();
  }

  void removeTaskAt(int index) {
    if (index >= 0 && index < _tasks.length) {
      _tasks.removeAt(index);
      notifyListeners();
    } else {
      print("Error: Attempted to remove task at invalid index $index");
    }
  }

  void insertTask(int index, Map<String, dynamic> taskData) {
    if (index >= 0 && index <= _tasks.length) {
      _tasks.insert(index, taskData);
      notifyListeners();
    } else {
      print("Error: Attempted to insert task at invalid index $index");
    }
  }

  // Sort method now uses the enum defined in THIS file
  void sortTasks(SortCriteria criteria) {
    switch (criteria) {
      case SortCriteria.dueDate:
        _tasks.sort((a, b) {
          DateTime dateA = a['date'] as DateTime;
          DateTime dateB = b['date'] as DateTime;
          return dateA.compareTo(dateB);
        });
        break;
      case SortCriteria.label:
        _tasks.sort((a, b) {
          String labelA = a['label'] as String? ?? '';
          String labelB = b['label'] as String? ?? '';
          int labelCompare = labelA.compareTo(labelB);
          if (labelCompare == 0) {
            DateTime dateA = a['date'] as DateTime;
            DateTime dateB = b['date'] as DateTime;
            return dateA.compareTo(dateB);
          }
          return labelCompare;
        });
        break;
    }
    notifyListeners();
  }
}