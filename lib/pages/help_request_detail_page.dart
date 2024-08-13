import 'package:flutter/material.dart';
import 'mock_service.dart';
import 'video_call_page.dart';

class HelpRequestDetailPage extends StatefulWidget {
  final String requestId;

  HelpRequestDetailPage({required this.requestId});

  @override
  _HelpRequestDetailPageState createState() => _HelpRequestDetailPageState();
}

class _HelpRequestDetailPageState extends State<HelpRequestDetailPage> {
  final MockService _mockService = MockService();
  late BuildContext _scaffoldContext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('도움 요청 상세'),
      ),
      body: Builder(
        builder: (BuildContext scaffoldContext) {
          _scaffoldContext = scaffoldContext;
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('요청 제목', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('요청 설명...'),
                SizedBox(height: 20),
                ElevatedButton(
                  child: Text('전화 연결'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _showConnectionConfirmDialog,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showConnectionConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('연결 확인'),
          content: Text('연결하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('연결'),
              onPressed: () {
                Navigator.of(context).pop();
                _connectToRequest();
              },
            ),
          ],
        );
      },
    );
  }

  void _connectToRequest() async {
    try {
      final result = await _mockService.assignRequest(widget.requestId);
      if (result['success']) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoCallPage(
              roomId: widget.requestId, // roomId로 requestId를 사용
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(_scaffoldContext).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(_scaffoldContext).showSnackBar(
        SnackBar(content: Text('연결 중 오류가 발생했습니다.')),
      );
    }
  }
}
