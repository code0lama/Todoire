import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'main.dart';

class CalendarPage extends StatefulWidget {
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(context),
          SizedBox(height: 20),
          Container( margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
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
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF4A4380),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
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
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF4A4380),
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        elevation: 8.0,
        child: Container(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.list_alt_outlined, color: Colors.white.withOpacity(0.7), size: 30),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => TaskScreen()),
                  );
                },
              ),
              SizedBox(width: 40),
              IconButton(
                icon: Icon(Icons.calendar_today_outlined, color: Colors.white, size: 28),
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
    final String displayDateString = 'Today, $formattedDate';

    return Container(
      padding: EdgeInsets.only(
        top: topPadding + 15,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: Color(0xFF4A4380),
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
                icon: Icon(Icons.grid_view_rounded, color: Colors.white, size: 28),
                onPressed: () {},
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
                      icon: Icon(Icons.search, color: Colors.white.withOpacity(0.8)),
                      hintText: 'Search',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, color: Colors.white, size: 28),
                color: Colors.white,
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
                      // Add sort logic here
                        break;
                    }
                  });
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
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
                  PopupMenuItem<String>(
                    value: 'show_completed',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Color(0xFF4A4380)),
                        SizedBox(width: 12),
                        Text('Show Completed'),
                        Spacer(),
                        if (_showCompleted)
                          Icon(Icons.check, color: Color(0xFF4A4380)),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'sort',
                    child: Row(
                      children: [
                        Icon(Icons.sort, color: Color(0xFF4A4380)),
                        SizedBox(width: 12),
                        Text('Sort'),
                      ],
                    ),
                  ),
                ]                    ,
              )],
          ),
          SizedBox(height: 20),
          Text(displayDateString,
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          SizedBox(height: 5),
          Text('Calendar',
              style: TextStyle(
                  color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
