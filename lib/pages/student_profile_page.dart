import 'package:flutter/material.dart';

class StudentProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 프로필'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/profile_image.png'), // 실제 이미지 경로로 변경 필요
              ),
            ),
            SizedBox(height: 20),
            Text(
              '홍길동',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('서울대학교 컴퓨터공학과'),
            SizedBox(height: 20),
            Text('총 봉사 시간: 20시간'),
            SizedBox(height: 20),
            Text(
              '활동 내역',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: Text('김철수 어르신 도움'),
                    subtitle: Text('2023-08-10 | 2시간'),
                  ),
                  ListTile(
                    title: Text('이영희 어르신 도움'),
                    subtitle: Text('2023-08-08 | 1.5시간'),
                  ),
                  // 더 많은 활동 내역...
                ],
              ),
            ),
            ElevatedButton(
              child: Text('프로필 수정'),
              onPressed: () {
                // TODO: 프로필 수정 기능 구현
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
