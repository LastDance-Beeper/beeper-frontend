import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';

import 'dart:async';

class HelpRequestService {
  // 목업 데이터로 도움 요청 목록을 반환하는 메소드
  Future<List<Map<String, dynamic>>> getUnassignedHelpRequests() async {
    // 네트워크 지연을 시뮬레이션하기 위해 지연 추가
    await Future.delayed(Duration(seconds: 1));

    // 목업 데이터를 반환
    return [
      {
        'roomId': 'FIXED_ROOM_CODE',
        'title': '장보기 도움 필요',
        'description': '키오스크 사용 도움이 필요합니다.',
      },
      {
        'roomId': '2b3c4d5e',
        'title': '컴퓨터 사용 도움',
        'description': '이메일 보내는 방법을 알고 싶어 하십니다.',
      },
      {
        'roomId': '3c4d5e6f',
        'title': '병원 동행 요청',
        'description': '병원에 함께 가주실 분이 필요합니다.',
      },
      {
        'roomId': '4d5e6f7g',
        'title': '말동무 요청',
        'description': '대화를 나누고 싶어 하십니다.',
      },
      {
        'roomId': '5e6f7g8h',
        'title': '산책 도움 필요',
        'description': '공원에서 산책을 함께 해주실 분이 필요합니다.',
      },
    ];
  }

  createHelpRequest(String processedText) {
    return 'FIXED_ROOM_CODE';
  }
}



// class HelpRequestService {
//   final String baseUrl = 'http://34.22.110.59:5500'; // 백엔드 서버 URL
//   final uuid = Uuid();
//
//   Future<String> createHelpRequest(String description) async {
//     final String roomId = uuid.v4(); // UUID 생성
//     final response = await http.post(
//       Uri.parse('$baseUrl/help-request'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         'description': description,
//         'roomId': roomId,
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       return roomId;
//     } else {
//       throw Exception('Failed to create help request');
//     }
//   }
//
//   Future<List<Map<String, dynamic>>> getUnassignedHelpRequests() async {
//     final response = await http.get(Uri.parse('$baseUrl/unassigned-help-requests'));
//
//     if (response.statusCode == 200) {
//       List<dynamic> body = json.decode(response.body);
//       return body.cast<Map<String, dynamic>>();
//     } else {
//       throw Exception('Failed to load unassigned help requests');
//     }
//   }
// }

