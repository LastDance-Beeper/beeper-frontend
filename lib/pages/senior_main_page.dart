import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:beeper/services/auth_service.dart';

class SeniorMainPage extends StatefulWidget {
  @override
  _SeniorMainPageState createState() => _SeniorMainPageState();
}

class _SeniorMainPageState extends State<SeniorMainPage> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '마이크 버튼을 눌러 말씀해주세요.';
  String _processedText = '';
  bool _showConfirmation = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speech.initialize(
      onStatus: (status) => print('onStatus: $status'),
      onError: (errorNotification) => print('onError: $errorNotification'),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: _onSpeechResult,
          listenFor: Duration(seconds: 30),
          localeId: "ko-KR",  // 한국어 설정
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      _processText();
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _text = result.recognizedWords;
    });
  }

  void _processText() async {
    setState(() => _text = '요청을 처리 중입니다...');
    final token = Provider.of<AuthService>(context, listen: false).token;
    final url = Uri.parse('https://your-backend-url.com/api/process-request');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'text': _text}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _processedText = responseData['processedText'];
          _showConfirmation = true;
        });
      } else {
        throw Exception('요청 처리에 실패했습니다.');
      }
    } catch (error) {
      print(error);
      setState(() => _text = '오류가 발생했습니다. 다시 시도해주세요.');
    }
  }

  void _sendHelpRequest() async {
    final token = Provider.of<AuthService>(context, listen: false).token;
    final url = Uri.parse('https://your-backend-url.com/api/send-help-request');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'request': _processedText}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('도움 요청이 전송되었습니다. 잠시만 기다려주세요.')),
        );
        // TODO: Implement waiting screen or logic
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_text, style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            if (_showConfirmation) ...[
              Text(_processedText, style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('도움 요청하기'),
                onPressed: _sendHelpRequest,
              ),
            ],
            SizedBox(height: 20),
            FloatingActionButton(
              onPressed: _listen,
              child: Icon(_isListening ? Icons.mic : Icons.mic_none),
            ),
          ],
        ),
      ),
    );
  }
}
