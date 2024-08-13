import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:async';

class SeniorVideoCallPage extends StatefulWidget {
  SeniorVideoCallPage({required String roomId});

  @override
  _SeniorVideoCallPageState createState() => _SeniorVideoCallPageState();
}

class _SeniorVideoCallPageState extends State<SeniorVideoCallPage> {
  RTCPeerConnection? _peerConnection;
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  WebSocketChannel? _channel;
  final String roomId = 'FIXED_ROOM_CODE'; // 고정된 룸 코드
  bool isConnected = false;
  bool _isMuted = false;
  bool _isFrontCamera = true;
  late Timer _timer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _requestPermissions();
    _startTimer();
  }

  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.microphone].request();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    await _getUserMedia();
    _connectToRoom();
  }

  Future<void> _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': _isFrontCamera ? 'user' : 'environment',
      }
    };
    try {
      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;
    } catch (e) {
      print('Error getting user media: $e');
    }
  }

  void _connectToRoom() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse('ws://34.22.110.59:5500/signal'));
      _channel!.stream.listen(_handleMessage, onDone: _handleWebSocketClosed, onError: _handleWebSocketError);
      _createPeerConnection();
    } catch (e) {
      print('Failed to connect to WebSocket: $e');
    }
  }

  void _handleMessage(message) async {
    var data = json.decode(message);
    if (data['roomId'] != roomId) return;

    switch (data['type']) {
      case 'offer':
        await _handleOffer(data);
        break;
      case 'answer':
        await _handleAnswer(data);
        break;
      case 'candidate':
        await _handleCandidate(data);
        break;
    }
  }

  Future<void> _handleOffer(data) async {
    await _peerConnection!.setRemoteDescription(RTCSessionDescription(data['data']['sdp'], data['data']['type']));
    var answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    _sendMessage('answer', answer.toMap());
  }

  Future<void> _handleAnswer(data) async {
    await _peerConnection!.setRemoteDescription(RTCSessionDescription(data['data']['sdp'], data['data']['type']));
  }

  Future<void> _handleCandidate(data) async {
    await _peerConnection!.addCandidate(RTCIceCandidate(
      data['data']['candidate'],
      data['data']['sdpMid'],
      data['data']['sdpMLineIndex'],
    ));
  }

  void _handleWebSocketClosed() {
    print('WebSocket closed');
    setState(() => isConnected = false);
  }

  void _handleWebSocketError(error) {
    print('WebSocket error: $error');
    setState(() => isConnected = false);
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection({
      'iceServers': [{'urls': 'stun:stun.l.google.com:19302'}],
      'sdpSemantics': 'unified-plan',
    });

    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate != null) {
        _sendMessage('candidate', candidate.toMap());
      }
    };

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.track.kind == 'video') {
        setState(() => _remoteRenderer.srcObject = event.streams[0]);
      }
    };

    _localStream?.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    var offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    _sendMessage('offer', offer.toMap());
  }

  void _sendMessage(String type, Map<String, dynamic> data) {
    _channel?.sink.add(json.encode({
      'type': type,
      'data': data,
      'roomId': roomId,
    }));
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _localStream?.getAudioTracks().forEach((track) {
        track.enabled = !_isMuted;
      });
    });
  }

  void _switchCamera() async {
    setState(() => _isFrontCamera = !_isFrontCamera);
    await _localStream?.dispose();
    await _getUserMedia();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() => _secondsElapsed++);
    });
  }

  String _formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.close();
    _localStream?.dispose();
    _channel?.sink.close();
    _timer.cancel();
    super.dispose();
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
                  RTCVideoView(_remoteRenderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Container(
                      width: 100,
                      height: 150,
                      child: RTCVideoView(_localRenderer, mirror: _isFrontCamera),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                '통화 시간: ${_formatDuration(_secondsElapsed)}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                  onPressed: _toggleMute,
                ),
                _buildButtonWithText(
                  icon: _isFrontCamera ? Icons.camera_front : Icons.camera_rear,
                  color: Colors.blue,
                  text: _isFrontCamera ? '후면 카메라' : '전면 카메라',
                  onPressed: _switchCamera,
                ),
                _buildButtonWithText(
                  icon: Icons.call_end,
                  color: Colors.red,
                  text: '통화 종료',
                  onPressed: () => Navigator.of(context).pop(),
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
