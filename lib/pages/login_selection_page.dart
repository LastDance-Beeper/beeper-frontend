import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Selection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginSelectionPage(),
    );
  }
}

class LoginSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // 앱바의 높이를 0으로 설정하여 숨깁니다.
        backgroundColor: Colors.transparent, // 앱바의 배경색을 투명하게 설정합니다.
        elevation: 0, // 그림자 효과를 제거합니다.
      ),
      body: SafeArea(
        child: Center( // Center 위젯으로 전체 화면을 중앙에 정렬
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '환영합니다!\n가입 이유를 선택해주세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 50), // 텍스트와 버튼 사이의 여백
                // 어르신 로그인 버튼
                SizedBox(
                  width: 250, // 버튼의 너비를 250으로 설정
                  height: 230, // 버튼의 높이를 230으로 설정
                  child: ElevatedButton(
                    onPressed: () {
                      // 어르신 로그인 페이지로 이동하는 로직을 여기에 추가하세요.

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF8E1C7), // 버튼 배경색
                      foregroundColor: Colors.black, // 버튼 텍스트 색상
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'images/login_selection_senior.png', // 어르신 아이콘 이미지
                          height: 100,
                        ),
                        SizedBox(height: 10),
                        Text(
                          '도움이 필요해요\n(어르신 로그인)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30), // 버튼 사이의 여백
                // 도우미 로그인 버튼
                SizedBox(
                  width: 250, // 버튼의 너비를 250으로 설정
                  height: 230, // 버튼의 높이를 230으로 설정
                  child: ElevatedButton(
                    onPressed: () {
                      // 도우미 로그인 페이지로 이동하는 로직을 여기에 추가하세요.
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF8E1C7), // 버튼 배경색
                      foregroundColor: Colors.black, // 버튼 텍스트 색상
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'images/login_selection_responder.png', // 도우미 아이콘 이미지
                          height: 100,
                        ),
                        SizedBox(height: 10),
                        Text(
                          '도움을 줄 수 있어요\n(도우미 로그인)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
