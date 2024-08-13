import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

class VideoCallPage extends StatefulWidget {
  final String roomId;

  VideoCallPage({Key? key, required this.roomId}) : super(key: key);

  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  RTCPeerConnection? _peerConnection;
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  WebSocketChannel? _channel;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _requestPermissions();
    _joinRoom(widget.roomId);
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    if (statuses[Permission.camera] != PermissionStatus.granted ||
        statuses[Permission.microphone] != PermissionStatus.granted) {
      print('Camera and Microphone permissions are required.');
    }
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    await _getUserMedia();
  }

  Future<void> _getUserMedia() async {
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({'video': true, 'audio': true});
      _localRenderer.srcObject = _localStream;
      print('User media stream initialized');
    } catch (e) {
      print('Error initializing user media: $e');
    }
  }

  void _joinRoom(String roomId) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse('ws://34.22.110.59:5500/signal'));

      _peerConnection = await createPeerConnection({
        'iceServers': [{'urls': 'stun:stun.l.google.com:19302'}],
        'sdpSemantics': 'unified-plan',
      });

      _peerConnection!.onIceCandidate = (candidate) {
        if (candidate != null && _channel != null) {
          _channel!.sink.add(json.encode({
            'type': 'candidate',
            'data': candidate.toMap(),
            'roomId': roomId,
          }));
          print('ICE Candidate sent');
        }
      };

      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.track.kind == 'video') {
          setState(() {
            _remoteRenderer.srcObject = event.streams[0];
          });
          print('Track event: remote video track added');
        }
      };

      if (_localStream != null) {
        for (var track in _localStream!.getTracks()) {
          _peerConnection!.addTrack(track, _localStream!);
        }
        print('Local stream tracks added to peer connection');
      }

      _channel!.stream.listen((message) async {
        var data = json.decode(message);
        if (data['roomId'] != roomId) return;

        if (data['type'] == 'offer') {
          await _peerConnection!.setRemoteDescription(RTCSessionDescription(data['data']['sdp'], data['data']['type']));
          var answer = await _peerConnection!.createAnswer();
          await _peerConnection!.setLocalDescription(answer);
          _channel!.sink.add(json.encode({
            'type': 'answer',
            'data': answer.toMap(),
            'roomId': roomId,
          }));
          print('SDP Answer created and sent');
        } else if (data['type'] == 'answer') {
          await _peerConnection!.setRemoteDescription(RTCSessionDescription(data['data']['sdp'], data['data']['type']));
          print('SDP Answer set as remote description');
        } else if (data['type'] == 'candidate') {
          _peerConnection!.addCandidate(RTCIceCandidate(
              data['data']['candidate'], data['data']['sdpMid'], data['data']['sdpMLineIndex']));
          print('ICE Candidate added');
        }
      }, onDone: () {
        print('WebSocket closed');
        setState(() {
          isConnected = false;
        });
      }, onError: (error) {
        print('WebSocket error: $error');
        setState(() {
          isConnected = false;
        });
      });

      setState(() {
        isConnected = true;
        print('WebSocket connected to room $roomId');
      });
    } catch (error) {
      print('Failed to connect to WebSocket: $error');
      setState(() {
        isConnected = false;
      });
    }
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.close();
    _localStream?.dispose();
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WebRTC Call')),
      body: Column(
        children: [
          Expanded(child: RTCVideoView(_localRenderer)),
          Expanded(child: RTCVideoView(_remoteRenderer)),
        ],
      ),
    );
  }
}
