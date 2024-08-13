import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';

class HelpRequestService {
  final String baseUrl = 'http://34.22.110.59:5500'; // 백엔드 서버 URL
  final uuid = Uuid();

  Future<String> createHelpRequest(String description) async {
    final String roomId = uuid.v4(); // UUID 생성
    final response = await http.post(
      Uri.parse('$baseUrl/help-request'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'description': description,
        'roomId': roomId,
      }),
    );

    if (response.statusCode == 200) {
      return roomId;
    } else {
      throw Exception('Failed to create help request');
    }
  }

  Future<List<Map<String, dynamic>>> getUnassignedHelpRequests() async {
    final response = await http.get(Uri.parse('$baseUrl/unassigned-help-requests'));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load unassigned help requests');
    }
  }
}
