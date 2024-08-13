import 'package:flutter/material.dart';
import 'dart:async';

class SeniorVideoCallPage extends StatefulWidget {
  SeniorVideoCallPage({required String roomId});

  @override
  _SeniorVideoCallPageState createState() => _SeniorVideoCallPageState();
}

class _SeniorVideoCallPageState extends State<SeniorVideoCallPage> {
  late Timer _timer;
  int _secondsElapsed = 0;
  bool _isMuted = false;
  bool _isFrontCamera = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
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
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Text('도우미 화면', style: TextStyle(fontSize: 24)),
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButtonWithText(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  color: _isMuted ? Colors.red : Colors.blue,
                  text: _isMuted ? '마이크 켜기' : '마이크 끄기',
                  onPressed: () {
                    setState(() {
                      _isMuted = !_isMuted;
                    });
                  },
                ),
                _buildButtonWithText(
                  icon: _isFrontCamera ? Icons.camera_front : Icons.camera_rear,
                  color: Colors.blue,
                  text: _isFrontCamera ? '후면 카메라' : '전면 카메라',
                  onPressed: () {
                    setState(() {
                      _isFrontCamera = !_isFrontCamera;
                    });
                  },
                ),
                _buildButtonWithText(
                  icon: Icons.call_end,
                  color: Colors.red,
                  text: '통화 종료',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonWithText({
    required IconData icon,
    required Color color,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          child: Icon(icon, color: Colors.white, size: 36),
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            backgroundColor: color,
            padding: EdgeInsets.all(24),
          ),
          onPressed: onPressed,
        ),
        SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
