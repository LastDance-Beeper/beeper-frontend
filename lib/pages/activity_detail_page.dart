import 'package:flutter/material.dart';

class ActivityDetailPage extends StatelessWidget {
  final Map<String, dynamic> activity;

  ActivityDetailPage({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('활동 상세 내용'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(activity['title'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('활동 시간: ${activity['date']} | ${activity['duration']}시간'),
            SizedBox(height: 10),
            Text('어르신 성함: ${activity['seniorName'] ?? '정보 없음'}'),
            SizedBox(height: 20),
            Text('요약 내용:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(activity['summary'] ?? '요약 내용이 없습니다.'),
            SizedBox(height: 20),
            Text('관련 태그:', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: (activity['tags'] as List<String>? ?? []).map((tag) => Chip(label: Text(tag))).toList(),
            ),
            SizedBox(height: 20),
            Text('메모:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(activity['memo'] ?? '메모가 없습니다.'),
          ],
        ),
      ),
    );
  }
}
