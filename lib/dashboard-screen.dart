import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'TaskModel.dart';

class DashboardScreen extends StatelessWidget {
  final TaskModel taskModel;

  const DashboardScreen({super.key, required this.taskModel});

  final Color purpleColor = const Color(0xFF4A4380);

  @override
  Widget build(BuildContext context) {
    String currentDate = DateFormat('EEEE, d MMM').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              color: purpleColor,
              padding: const EdgeInsets.only(
                  top: 80, left: 30, right: 30, bottom: 30),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color(0xFF4A4380)),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentDate,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const Text(
                        "Dashboard",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/signup');
                    },
                  ),
                ],
              ),
            ),

            // View Buttons
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildViewButton(
                      Icons.list, "List", const Color(0xFF4A4380), context),
                  const SizedBox(width: 20),
                  _buildViewButton(Icons.calendar_today_outlined, "Calendar",
                      const Color(0xFF4A4380), context),
                ],
              ),
            ),

            // Labels Section
            _buildSectionTitle("Labels"),
            _buildLabelGrid([
              _TagData(
                  "Study", Colors.deepPurple, taskModel.countByLabel("Study")),
              _TagData(
                  "Sports", Colors.lightBlue, taskModel.countByLabel("Sports")),
              _TagData("Work", Colors.yellow, taskModel.countByLabel("Work")),
              _TagData("Personal", Colors.amber[700]!,
                  taskModel.countByLabel("Personal")),
            ]),

            // Status Section
            _buildSectionTitle("Status"),
            _buildStatusList(),
          ],
        ),
      ),
    );
  }

  Widget _buildViewButton(
      IconData icon, String label, Color iconColor, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (label == 'List') {
          Navigator.pushReplacementNamed(context, '/taskscreen');
        } else if (label == 'Calendar') {
          Navigator.pushReplacementNamed(context, '/calender');
        }
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(24),
            child: Icon(icon, color: iconColor, size: 36),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }

  Widget _buildLabelGrid(List<_TagData> tags) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _buildLabelBox(tags[0]),
                const SizedBox(height: 20),
                _buildLabelBox(tags[2]),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                _buildLabelBox(tags[1]),
                const SizedBox(height: 20),
                _buildLabelBox(tags[3]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelBox(_TagData tag) {
    final Color labelColor;
    switch (tag.name) {
      case 'Study':
        labelColor = Colors.teal;
        break;
      case 'Sports':
        labelColor = Colors.orange;
        break;
      case 'Work':
        labelColor = Colors.indigo;
        break;
      case 'Personal':
        labelColor = Colors.pink;
        break;
      default:
        labelColor = tag.color;
    }

    return SizedBox(
      height: 120,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: labelColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.label, color: labelColor),
            const SizedBox(height: 10),
            Text(
              tag.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: labelColor,
              ),
            ),
            Text(
              '${tag.count} tasks',
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statusChip("To do", Colors.red),
          _statusChip("Doing", Colors.orange),
          _statusChip("Done", Colors.green),
        ],
      ),
    );
  }

  Widget _statusChip(String label, Color color) {
    return Chip(
      backgroundColor: Colors.white,
      avatar: CircleAvatar(backgroundColor: color, radius: 6),
      label: Text(label),
    );
  }
}

class _TagData {
  final String name;
  final Color color;
  final int count;

  _TagData(this.name, this.color, this.count);
}
