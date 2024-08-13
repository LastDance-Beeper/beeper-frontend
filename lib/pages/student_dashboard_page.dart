import 'package:beeper/pages/activity_history_page.dart';
import 'package:beeper/pages/tag_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:beeper/services/real_time_notification_service.dart';
import 'package:beeper/services/help_request_service.dart';
import 'package:beeper/pages/video_call_page.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import '../services/auth_service.dart';
import 'student_help_list_page.dart';
import 'student_profile_page.dart';

class StudentDashboardPage extends StatefulWidget {
  @override
  _StudentDashboardPageState createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  bool _isActive = true;
  bool _notificationsEnabled = true;
  List<String> _notificationTags = ['청소', '말동무', '산책'];
  final RealTimeNotificationService _notificationService = RealTimeNotificationService();
  final HelpRequestService _helpRequestService = HelpRequestService();
  List<Map<String, dynamic>> _helpRequests = [];
  late Timer _refreshTimer;

  @override
  void initState() {
    super.initState();
    _notificationService.initialize(context);
    _fetchHelpRequests();
    _refreshTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _fetchHelpRequests();
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  Future<void> _fetchHelpRequests() async {
    try {
      final requests = await _helpRequestService.getUnassignedHelpRequests();
      setState(() {
        _helpRequests = requests;
      });
    } catch (e) {
      print('Error fetching help requests: $e');
    }
  }

  void _acceptHelpRequest(String roomId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VideoCallPage(roomId: roomId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('대시보드'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => _showMenu(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchHelpRequests,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            _buildActiveStatusSection(),
            SizedBox(height: 20),
            _buildNotificationTagsSection(),
            SizedBox(height: 20),
            _buildHelpRequestsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveStatusSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '활성 상태',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                        Icons.circle,
                        color: _isActive ? Colors.green : Colors.red,
                        size: 12
                    ),
                    SizedBox(width: 8),
                    Text(
                        _isActive ? '요청 대기' : '자리 비움',
                        style: TextStyle(
                            fontSize: 16,
                            color: _isActive ? Colors.green : Colors.red
                        )
                    ),
                  ],
                ),
                Switch(
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                    // TODO: Implement server-side status update
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
            Text(
              _isActive ? '실시간 도움 요청 알림을 받습니다' : '알림을 받지 않습니다',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTagsSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '내가 알림받는 태그',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  child: Text('태그 수정'),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TagEditPage()),
                    );
                    if (result != null) {
                      setState(() {
                        _notificationTags = result;
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _notificationTags.map((tag) => Chip(
                label: Text('#$tag'),
                backgroundColor: Colors.lightBlue[100],
                labelStyle: TextStyle(color: Colors.blue[800]),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpRequestsSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '새로운 도움 요청',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            if (_helpRequests.isEmpty)
              Text('현재 새로운 도움 요청이 없습니다.')
            else
              ..._helpRequests.map((request) => ListTile(
                title: Text(request['title']),
                subtitle: Text(request['description']),
                trailing: ElevatedButton(
                  child: Text('배정'),
                  onPressed: () {
                    _acceptHelpRequest(request['roomId']);
                  },
                ),
              )),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.person),
                title: Text('내 프로필'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StudentProfilePage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.history),
                title: Text('활동 내역 조회'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ActivityHistoryPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.verified),
                title: Text('봉사 인증'),
                onTap: () async {
                  Navigator.pop(context);
                  const url = 'https://example.com/volunteer-certification';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not launch $url')),
                    );
                  }
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('로그아웃'),
                onTap: () async {
                  Navigator.pop(context);
                  await Provider.of<AuthService>(context, listen: false).logout();
                  Navigator.of(context).pushReplacementNamed('/');
                },
              ),
            ],
          ),
        );
      },
    );
  }

}
