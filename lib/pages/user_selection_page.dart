import 'package:flutter/material.dart';

class UserSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 40),
              Text(
                '환영합니다!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                '가입 이유를 선택해주세요',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 40),
              _buildSelectionCard(
                context,
                '도움이 필요해요\n(어르신 로그인)',
                'images/login_selection_senior.png',
                '/senior_main',
              ),
              SizedBox(height: 20),
              _buildSelectionCard(
                context,
                '도움을 줄 수 있어요\n(도우미 로그인)',
                'images/login_selection_responder.png',
                '/helper_login',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCard(BuildContext context, String title, String imagePath, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFFFFF9C4),  // 밝은 노란색
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Image.asset(imagePath, width: 100, height: 100),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
