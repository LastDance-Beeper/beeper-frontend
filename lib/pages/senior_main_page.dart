import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:beeper/services/help_request_service.dart';

class SeniorMainPage extends StatefulWidget {
  @override
  _SeniorMainPageState createState() => _SeniorMainPageState();
}

class _SeniorMainPageState extends State<SeniorMainPage> with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '마이크 버튼을 눌러 말씀해주세요.';
  String _processedText = '';
  bool _showConfirmation = false;
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
    setState(() => _text = '요청을 처리 중입니다...');
    try {
      final processedText = _text;  // 음성 텍스트 그대로 사용 (여기서 AI 요약 기능이 있을 수 있음)
      setState(() {
        _processedText = processedText;
        _showConfirmation = true;
      });
    } catch (error) {
      print(error);
      setState(() => _text = '오류가 발생했습니다. 다시 시도해주세요.');
    }
  }

  void _sendHelpRequest() async {
    try {
      final helpRequestService = HelpRequestService();
      final uuid = await helpRequestService.createHelpRequest(_processedText);  // UUID 생성 및 전송

      if (uuid.isNotEmpty) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => WaitingScreen(roomId: uuid), // WaitingScreen으로 UUID를 전달
        ));
      } else {
        throw Exception('도움 요청 전송에 실패했습니다.');
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('도움 요청 전송에 실패했습니다. 다시 시도해주세요.')),
      );
    }
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
                      onPressed: _sendHelpRequest,
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

class WaitingScreen extends StatelessWidget {
  final String roomId;

  WaitingScreen({required this.roomId});

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
                '도움 요청이 전송되었습니다',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '대학생 봉사자를 찾고 있습니다...',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('요청 취소'),
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
