import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:async';

class VideoCallPage extends StatefulWidget {
  final String requestTitle;
  final String requestDescription;

  VideoCallPage({required this.requestTitle, required this.requestDescription});

  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  RTCPeerConnection? _peerConnection;
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isInitialized = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isRemoteVideoConnected = false;
  late Timer _timer;
  int _secondsElapsed = 0;
  final TextEditingController _nameController = TextEditingController();
  String _connectionStatus = 'Initializing...';
  List<String> _logs = [];

  static const String roomId = 'ABCDE'; // Room ID 고정

  @override
  void initState() {
    super.initState();
    _initializeCall();
    _startTimer();
  }

  void _log(String message) {
    print(message); // Console logging
    setState(() {
      _logs.add("${DateTime.now()}: $message");
      if (_logs.length > 100) _logs.removeAt(0); // Limit log size
    });
  }

  Future<void> _initializeCall() async {
    if (_isInitialized) return;
    _isInitialized = true;

    _log("Initializing call...");
    await _initRenderers();
    await _requestPermissions();
    await _getUserMedia();
    _connectToSignalingServer();
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    if (statuses[Permission.camera] != PermissionStatus.granted ||
        statuses[Permission.microphone] != PermissionStatus.granted) {
      _log('Camera and Microphone permissions are required.');
    }
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    _log("Renderers initialized");
  }

  Future<void> _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      }
    };
    try {
      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;
      _log("Local media stream obtained");
    } catch (e) {
      _log("Error getting user media: $e");
    }
  }

  void _connectToSignalingServer() {
    if (_channel != null) return;

    _log("Connecting to signaling server...");
    _channel = WebSocketChannel.connect(Uri.parse('ws://34.22.110.59:5500/signal'));
    _channel!.stream.listen(_onMessageReceived, onDone: () {
      _log("WebSocket disconnected");
      setState(() {
        _isConnected = false;
        _connectionStatus = 'Disconnected';
      });
    }, onError: (error) {
      _log("WebSocket error: $error");
      setState(() {
        _isConnected = false;
        _connectionStatus = 'Error: $error';
      });
    });

    _createPeerConnection().then((_) {
      _log("Joined room: $roomId");
    });
  }

  Future<void> _createPeerConnection() async {
    if (_peerConnection != null) return;

    _log("Creating peer connection...");
    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
      'sdpSemantics': 'unified-plan', // Unified Plan으로 설정
    };

    _peerConnection = await createPeerConnection(configuration);

    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate != null && _channel != null) {
        _channel!.sink.add(json.encode({
          'type': 'candidate',
          'data': candidate.toMap(),
          'roomId': roomId
        }));
        _log('ICE Candidate sent');
      }
    };

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.track.kind == 'video') {
        setState(() {
          _remoteRenderer.srcObject = event.streams[0];
          _isRemoteVideoConnected = true;
        });
        _log('Track event: remote video track added');
      }
    };

    if (_localStream != null) {
      for (var track in _localStream!.getTracks()) {
        _peerConnection!.addTrack(track, _localStream!);
      }
      _log('Local stream tracks added to peer connection');
    }
  }

  void _onMessageReceived(message) async {
    var data = json.decode(message);
    if (data['roomId'] != roomId) return;

    if (data['type'] == 'offer') {
      try {
        await _peerConnection!.setRemoteDescription(RTCSessionDescription(data['data']['sdp'], data['data']['type']));
        var answer = await _peerConnection!.createAnswer();
        await _peerConnection!.setLocalDescription(answer);
        _channel!.sink.add(json.encode({
          'type': 'answer',
          'data': answer.toMap(),
          'roomId': roomId
        }));
        _log('SDP Answer created and sent');
      } catch (e) {
        _log('Error handling offer: $e');
      }
    } else if (data['type'] == 'answer') {
      try {
        await _peerConnection!.setRemoteDescription(RTCSessionDescription(data['data']['sdp'], data['data']['type']));
        _log('SDP Answer set as remote description');
      } catch (e) {
        _log('Error handling answer: $e');
      }
    } else if (data['type'] == 'candidate') {
      try {
        _peerConnection!.addCandidate(RTCIceCandidate(
            data['data']['candidate'],
            data['data']['sdpMid'],
            data['data']['sdpMLineIndex']
        ));
        _log('ICE Candidate added');
      } catch (e) {
        _log('Error adding ICE candidate: $e');
      }
    }
  }

  void _createOffer() async {
    try {
      if (_peerConnection == null) await _createPeerConnection();

      var offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      if (_channel != null) {
        _channel!.sink.add(json.encode({
          'type': 'offer',
          'data': offer.toMap(),
          'roomId': roomId
        }));
        _log('SDP Offer created and sent');
      }
    } catch (e) {
      _log('Error creating offer: $e');
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _localStream?.getAudioTracks().forEach((track) {
        track.enabled = !_isMuted;
      });
    });
  }

  void _toggleVideo() {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
      _localStream?.getVideoTracks().forEach((track) {
        track.enabled = _isVideoEnabled;
      });
    });
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
    _nameController.dispose();
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
                      child: RTCVideoView(_localRenderer, mirror: true),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    top: 16,
                    child: Text(
                      _connectionStatus,
                      style: TextStyle(color: Colors.white, backgroundColor: Colors.black54),
                    ),
                  ),
                  if (!_isRemoteVideoConnected)
                    Center(child: CircularProgressIndicator()),
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
                  Text('Room ID: $roomId'),
                  Text('Remote video connected: $_isRemoteVideoConnected'),
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
            Expanded(
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) => Text(_logs[index], style: TextStyle(fontSize: 10)),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCircularIconButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  color: _isMuted ? Colors.red : Colors.blue,
                  onPressed: _toggleMute,
                ),
                _buildCircularIconButton(
                  icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                  color: _isVideoEnabled ? Colors.blue : Colors.red,
                  onPressed: _toggleVideo,
                ),
                _buildCircularIconButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  onPressed: () => Navigator.of(context).pop(),
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
        shape: CircleBorder(),
        backgroundColor: color,
        padding: EdgeInsets.all(20),
      ),
      onPressed: onPressed,
    );
  }
}
