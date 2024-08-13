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
    return "키오스크 사용 도움 요청이 필요하신 것 같습니다.";
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
        {'title': '김철수 어르신 도움', 'date': '2023-08-10', 'duration': 28},
        {'title': '이영희 어르신 도움', 'date': '2023-08-08', 'duration': 44},
        {'title': '홍길동 어르신 도움', 'date': '2023-08-08', 'duration': 32},
      ],
      'helpRequests': [
        {'title': '장보기 도움 필요', 'description': '키오스크 사용 도움이 필요합니다.'},
        {'title': '장보기 도움 필요', 'description': '버스 표 발권 도움이 필요합니다.'},
        {'title': '컴퓨터 사용 도움', 'description': '이메일 보내는 방법을 알고 싶어 하십니다.'},
      ],
    };
  }

  Future<Map<String, dynamic>> assignRequest(String requestId) async {
    // 서버 호출 시뮬레이션
    await Future.delayed(Duration(seconds: 1));

    // 랜덤하게 성공 또는 실패 반환
    if (DateTime.now().millisecondsSinceEpoch % 2 == 0) {
      return {
        'success': true,
        'message': '연결 중입니다...'
      };
    } else {
      return {
        'success': false,
        'message': '이미 배정된 요청입니다.'
      };
    }
  }
}
