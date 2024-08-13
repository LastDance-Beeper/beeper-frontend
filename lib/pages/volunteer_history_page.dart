import 'package:flutter/material.dart';
import 'package:beeper/pages/activity_detail_page.dart';

class VolunteerHistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> _volunteerHistory = [
    {'title': '김철수 어르신 도움', 'date': '2023-08-10', 'duration': 2},
    {'title': '이영희 어르신 도움', 'date': '2023-08-08', 'duration': 1.5},
    // 더 많은 내역 추가...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('봉사 내역'),
      ),
      body: ListView.builder(
        itemCount: _volunteerHistory.length,
        itemBuilder: (context, index) {
          final activity = _volunteerHistory[index];
          return ListTile(
            title: Text(activity['title']),
            subtitle: Text('${activity['date']} | ${activity['duration']}시간'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivityDetailPage(activity: activity),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
