import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:beeper/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentDashboardPage extends StatefulWidget {
  @override
  _StudentDashboardPageState createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  int _volunteerHours = 0;
  List<Map<String, dynamic>> _recentActivities = [];
  List<Map<String, dynamic>> _helpRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    final token = Provider.of<AuthService>(context, listen: false).token;
    final url = Uri.parse('https://your-backend-url.com/api/student-dashboard');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _volunteerHours = responseData['volunteerHours'];
          _recentActivities = List<Map<String, dynamic>>.from(responseData['recentActivities']);
          _helpRequests = List<Map<String, dynamic>>.from(responseData['helpRequests']);
        });
      } else {
        throw Exception('Failed to load dashboard data');
      }
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
            Text('총 봉사 시간: $_volunteerHours 시간', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('최근 활동', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ..._recentActivities.map((activity) => ListTile(
              title: Text(activity['title']),
              subtitle: Text('${activity['date']} | ${activity['duration']}시간'),
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
                    Navigator.pushNamed(context, '/video_call');
                  },
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
