import 'package:flutter/material.dart';
import 'package:beeper/services/real_time_notification_service.dart';
import 'package:beeper/services/help_request_service.dart';
import 'dart:async';

import 'video_call_page.dart';

class StudentDashboardPage extends StatefulWidget {
  @override
  _StudentDashboardPageState createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  bool _isActive = true;
  bool _notificationsEnabled = true;
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
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
            Text(
              _notificationsEnabled ? '알림 켜짐' : '알림 꺼짐',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTagsSection() {
    // TODO: Implement notification tags section
    return Container();
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
    // TODO: Implement menu options
  }
}
