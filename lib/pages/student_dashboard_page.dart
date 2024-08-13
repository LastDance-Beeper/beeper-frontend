import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:beeper/services/auth_service.dart';

import 'mock_service.dart';

class StudentDashboardPage extends StatefulWidget {
  @override
  _StudentDashboardPageState createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  final MockService _mockService = MockService();
  int _volunteerHours = 0;
  List<Map<String, dynamic>> _recentActivities = [];
  List<Map<String, dynamic>> _helpRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final responseData = await _mockService.getStudentDashboard();
      setState(() {
        _volunteerHours = responseData['volunteerHours'];
        _recentActivities = List<Map<String, dynamic>>.from(responseData['recentActivities']);
        _helpRequests = List<Map<String, dynamic>>.from(responseData['helpRequests']);
      });
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터 로딩에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beeper - 학생 대시보드'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // TODO: Navigate to profile page
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            Text('총 봉사 시간: $_volunteerHours 시간',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('최근 활동', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ..._recentActivities.map((activity) => Card(
              child: ListTile(
                title: Text(activity['title']),
                subtitle: Text('${activity['date']} | ${activity['duration']}시간'),
              ),
            )),
            SizedBox(height: 20),
            Text('새로운 도움 요청', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ..._helpRequests.map((request) => Card(
              child: ListTile(
                title: Text(request['title']),
                subtitle: Text(request['description']),
                trailing: ElevatedButton(
                  child: Text('수락'),
                  onPressed: () {
                    // TODO: Implement help request acceptance
                    _acceptHelpRequest(request);
                  },
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _acceptHelpRequest(Map<String, dynamic> request) {
    // 실제로는 여기서 API 호출을 통해 요청을 수락하고 처리해야 합니다.
    // 지금은 MockService를 사용하므로, 간단한 알림만 표시합니다.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${request['title']} 요청을 수락했습니다.')),
    );
    // 수락 후 화상 통화 페이지로 이동
    Navigator.pushNamed(context, '/video_call');
  }
}
