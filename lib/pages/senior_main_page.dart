import 'package:beeper/pages/video_call_page.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'dart:async';

import 'senior_video_call_page.dart';

class SeniorMainPage extends StatefulWidget {
  @override
  _SeniorMainPageState createState() => _SeniorMainPageState();
}

class _SeniorMainPageState extends State<SeniorMainPage>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '마이크 버튼을 눌러 말씀해주세요.';
  String _processedText = '';
  bool _showConfirmation = false;
  bool _isButtonDisabled = true;
  late AnimationController _animationController;
  List<double> _waveHeights = List.filled(5, 20);

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initSpeech() async {
    await _speech.initialize(
      onStatus: (status) => print('onStatus: $status'),
      onError: (errorNotification) => print('onError: $errorNotification'),
    );
  }

  void _startListening() {
    _speech.listen(
      onResult: _onSpeechResult,
      listenFor: Duration(seconds: 30),
      localeId: "ko-KR",
      cancelOnError: true,
      partialResults: true,
    );
    setState(() {
      _isListening = true;
      _text = '듣고 있습니다...';
    });
    _animateWave();
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
    _processText();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _text = result.recognizedWords;
    });
  }

  void _animateWave() {
    if (!_isListening) return;
    setState(() {
      for (int i = 0; i < _waveHeights.length; i++) {
        _waveHeights[i] = 20 + 20 * _animationController.value;
      }
    });
    Future.delayed(Duration(milliseconds: 50), _animateWave);
  }

  void _processText() async {
    setState(() {
      _text = '요청을 분석 중입니다...';
      _isButtonDisabled = true;
    });

    await Future.delayed(Duration(seconds: 2)); // 분석 시간 시뮬레이션

    setState(() {
      _processedText = "버스표 무인발권기의 사용에 도움이 필요합니다";
      _showConfirmation = true;
      _text = '요약이 완료되었습니다';
      _isButtonDisabled = false;
    });
  }

  void _sendHelpRequest() async {
    // 실제 구현에서는 서버로부터 requestId를 받아와야 합니다.
    // 여기서는 임시로 고정된 값을 사용합니다.
    String requestId = 'dummy-request-id-12345';

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => WaitingScreen(requestId: requestId),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Beeper - 도움 요청')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '어르신 메인',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 40),
                  GestureDetector(
                    onTapDown: (_) => _startListening(),
                    onTapUp: (_) => _stopListening(),
                    onTapCancel: () => _stopListening(),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.red : Colors.blue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (_isListening)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                            (index) => AnimatedContainer(
                          duration: Duration(milliseconds: 50),
                          margin: EdgeInsets.symmetric(horizontal: 2),
                          width: 5,
                          height: _waveHeights[index],
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                  Text(
                    _text,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  if (_showConfirmation) ...[
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _processedText,
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isButtonDisabled ? null : _sendHelpRequest,
                      child: Text('도움 요청하기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WaitingScreen extends StatefulWidget {
  final String requestId; // requestId 추가

  WaitingScreen({required this.requestId}); // 생성자 수정

  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  @override
  void initState() {
    super.initState();
    _simulateWaiting();
  }

  void _simulateWaiting() {
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SeniorVideoCallPage(roomId: widget.requestId),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                '도우미를 찾고 있습니다...',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '도우미가 배정되면 화상통화에 연결됩니다',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  '요청 취소',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DummyVideoCallScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('화상 통화')),
      body: Center(
        child: Text('화상 통화 연결됨 (더미 화면)', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
