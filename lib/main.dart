import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
void main() {
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
  final Color primaryColor =Color(0xFF4A4380); // head color
  final Color searchBarColor = Colors.white30; // for search
  final Color addbutton = Color(0xFF4A4380);     // for add button
  final Color bottomNavBarColor = Color(0xFF4A4380); // for bot nav bar
  final Color iconColor = Colors.white;        // for header icons+text
  final Color bottomIconColor = Colors.white; //  nav bar button
  final Color checkColor = Color(0xFF4A4380); // Color for the check icon in menu
  bool _showLabels = true;
  bool _showCompleted = true;
  void _handleSort() {
    print("Sort action triggered!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Center(
              child: Text(
                'Hon mnhot l details',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // With lama
        },
        child: Icon(Icons.add, size: 30, color: Colors.white),
        backgroundColor: addbutton, // Use color from State
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
          top: topPadding + 15, left: 20, right: 20, bottom: 20
      ),
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
                icon: Icon(Icons.grid_view_rounded, color: iconColor, size: 28),
                onPressed: () {}, //with lama or khulud
              ),
              Expanded(
                child: GestureDetector(
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
                        icon: Icon(Icons.search, color: iconColor.withOpacity(0.8)),
                        hintText: 'Search',
                        hintStyle: TextStyle(color: iconColor.withOpacity(0.8)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  onTap: () {
                    //later
                  },
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, color: iconColor, size: 28),
                color: Colors.white, // Menu background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
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
                    checkColor: checkColor,
                  ),
                  _buildPopupMenuItem(
                    context: context,
                    icon: Icons.check_circle_outline,
                    title: 'Show Completed',
                    value: 'show_completed',
                    showCheck: _showCompleted,
                    checkColor: checkColor,
                  ),
                  _buildPopupMenuItem(
                    context: context,
                    icon: Icons.sort,
                    title: 'Sort',
                    value: 'sort',
                  ),
                ],
              ),

            ],
          ),
          SizedBox(height: 20),
          Text(
            displayDateString,
            style: TextStyle(color: iconColor.withOpacity(0.8), fontSize: 14),
          ),
          SizedBox(height: 5),
          Text(
            'My tasks',
            style: TextStyle(
                color: iconColor, fontSize: 28, fontWeight: FontWeight.bold),
          ),
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
          Icon(icon, color: Color(0xFF4A4380)), // Menu item icon color
          SizedBox(width: 12),
          Text(title),
          Spacer(),
          if (showCheck)
            Icon(Icons.check,),
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
              icon: Icon(Icons.list_alt_outlined, color: bottomIconColor, size: 30),
              onPressed: () {},
            ),
            SizedBox(width: 40),
            IconButton(
              icon: Icon(Icons.calendar_today_outlined, color: bottomIconColor, size: 28),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}