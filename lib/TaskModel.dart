class TaskModel {
  List<Map<String, dynamic>> tasks = [];

  int countByLabel(String label) {
    return tasks.where((task) => task['label'] == label).length;
  }
}
