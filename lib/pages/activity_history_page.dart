import 'package:flutter/material.dart';

class ActivityHistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> activities = [
    {
      'date': '2023-08-15',
      'duration': '30분',
      'title': '청소 도움',
      'summary': '방 청소를 도와드렸습니다.',
      'seniorName': '김철수'
    },
    {
      'date': '2023-08-14',
      'duration': '45분',
      'title': '말동무',
      'summary': '대화를 나누었습니다.',
      'seniorName': '이영희'
    },
    // 더 많은 활동 내역...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('활동 내역'),
      ),
      body: ListView.builder(
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ListTile(
            title: Text(activity['title']),
            subtitle: Text('${activity['date']} - ${activity['duration']}'),
            onTap: () => _showActivityDetail(context, activity),
          );
        },
      ),
    );
  }

  void _showActivityDetail(BuildContext context, Map<String, dynamic> activity) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('활동 상세 내역'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('통화 일자: ${activity['date']}'),
              Text('통화 시간: ${activity['duration']}'),
              Text('요청 내용: ${activity['title']}'),
              Text('요약: ${activity['summary']}'),
              Text('어르신 성함: ${activity['seniorName']}'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('닫기'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
