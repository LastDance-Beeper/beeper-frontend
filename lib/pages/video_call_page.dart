import 'package:flutter/material.dart';
import 'dart:async';

class VideoCallPage extends StatefulWidget {
  final String requestTitle;
  final String requestDescription;

  VideoCallPage({required this.requestTitle, required this.requestDescription, required String roomId});

  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  late Timer _timer;
  int _secondsElapsed = 0;
  final TextEditingController _nameController = TextEditingController();
  bool _isMuted = false;
  bool _isVideoOn = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _nameController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  String _formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 5,  // 화상 통화 영역 확장
              child: Stack(
                children: [
                  Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Text('상대방 화면', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Container(
                      width: 100,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.blue[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text('내 화면', style: TextStyle(fontSize: 14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '통화 시간: ${_formatDuration(_secondsElapsed)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '도움 요청: ${widget.requestTitle}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.requestDescription,
                    style: TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: '성함 입력',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCircularIconButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  color: _isMuted ? Colors.red : Colors.blue,
                  onPressed: () {
                    setState(() {
                      _isMuted = !_isMuted;
                    });
                  },
                ),
                _buildCircularIconButton(
                  icon: _isVideoOn ? Icons.videocam : Icons.videocam_off,
                  color: _isVideoOn ? Colors.blue : Colors.red,
                  onPressed: () {
                    setState(() {
                      _isVideoOn = !_isVideoOn;
                    });
                  },
                ),
                _buildCircularIconButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      child: Icon(icon, color: Colors.white),
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(), backgroundColor: color,
        padding: EdgeInsets.all(20),
      ),
      onPressed: onPressed,
    );
  }
}
