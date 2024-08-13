import 'dart:async';
import 'dart:math';

class MockService {
  // 모의 로그인
  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(Duration(seconds: 1)); // API 호출 지연 시뮬레이션
    return {
      'token': 'mock_token_${Random().nextInt(1000)}',
      'userId': 'user_${Random().nextInt(100)}',
      'userType': Random().nextBool() ? 'senior' : 'student',
    };
  }

  // 모의 음성 처리
  Future<String> processVoiceRequest(String text) async {
    await Future.delayed(Duration(seconds: 2)); // API 호출 지연 시뮬레이션
    return "당신의 요청 '$text'를 처리했습니다. 도움이 필요하신 것 같습니다.";
  }

  // 모의 도움 요청 전송
  Future<bool> sendHelpRequest(String request) async {
    await Future.delayed(Duration(seconds: 1)); // API 호출 지연 시뮬레이션
    return true; // 항상 성공으로 처리
  }

  // 모의 학생 대시보드 데이터
  Future<Map<String, dynamic>> getStudentDashboard() async {
    await Future.delayed(Duration(seconds: 1)); // API 호출 지연 시뮬레이션
    return {
      'volunteerHours': Random().nextInt(50) + 10,
      'recentActivities': [
        {'title': '김철수 어르신 도움', 'date': '2023-08-10', 'duration': 2},
        {'title': '이영희 어르신 도움', 'date': '2023-08-08', 'duration': 1.5},
      ],
      'helpRequests': [
        {'title': '장보기 도움 필요', 'description': '근처 마트에서 장보기를 도와주실 분 찾습니다.'},
        {'title': '컴퓨터 사용 도움', 'description': '이메일 보내는 방법을 알려주실 분 찾습니다.'},
      ],
    };
  }
}
