import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'package:beeper/services/auth_service.dart';

class VideoCallPage extends StatefulWidget {
  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _isMuted = false;
  bool _isCameraOff = false;

  @override
  void initState() {
    super.initState();
    initRenderers();
    _getUserMedia();
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      },
    };

    MediaStream stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    _localRenderer.srcObject = stream;
    _localStream = stream;

    // TODO: Implement signaling to start the call
  }

  void _createPeerConnection() async {
    Map<String, dynamic> configuration = {
      "iceServers": [
        {"url": "stun:stun.l.google.com:19302"},
      ]
    };

    final Map<String, dynamic> offerSdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": true,
      },
      "optional": [],
    };

    _peerConnection = await createPeerConnection(configuration, offerSdpConstraints);

    _peerConnection!.addStream(_localStream!);

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      // TODO: Send candidate to remote peer
    };

    _peerConnection!.onAddStream = (MediaStream stream) {
      _remoteRenderer.srcObject = stream;
    };

    // TODO: Implement signaling to exchange SDP and ICE candidates
  }

  void _toggleMute() {
    if (_localStream != null) {
      bool enabled = _localStream!.getAudioTracks()[0].enabled;
      _localStream!.getAudioTracks()[0].enabled = !enabled;
      setState(() {
        _isMuted = !enabled;
      });
    }
  }

  void _toggleCamera() {
    _localStream?.getVideoTracks()[0].enabled = _isCameraOff;
    setState(() {
      _isCameraOff = !_isCameraOff;
    });
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.dispose();
    _peerConnection?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Beeper - 화상 통화')),
        body: OrientationBuilder(
        builder: (context, orientation) {
      return Container(
          child: Stack(
          children: <Widget>[
          Positioned(
          left: 0.0,
          right: 0.0,
          top: 0.0,
          bottom: 0.0,
          child: Container(
          margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height,
    child: RTCVideoView(_remoteRenderer),
    decoration: BoxDecoration(color: Colors.black54),
    ),
    ),
    Positioned(
    left: 20.0,
    top: 20.0,
    child: Container(
    width: orientation == Orientation.portrait ? 90.0 : 120.0,
    height: orientation == Orientation.portrait ? 120.0 : 90.0,
    child: RTCVideoView(_localRenderer, mirror: true),
    decoration: BoxDecoration(color: Colors.black54),
    ),
    ),
    Positioned(
    bottom: 20.0,
    left: 0.0,
    right: 0.0,
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
    FloatingActionButton(
    heroTag: 'mute',
    onPressed: _toggleMute,
    child: Icon(_isMuted ? Icons.mic_off : Icons.mic),
    ),
    FloatingActionButton(
    heroTag: 'camera',
    onPressed: _toggleCamera,
    child: Icon(_isCameraOff ? Icons.videocam_off : Icons.videocam),
    ),
    FloatingActionButton(
      heroTag: 'end_call',
      onPressed: () {
        Navigator.pop(context);
      },
      backgroundColor: Colors.red,
      child: Icon(Icons.call_end),
    ),
      ],
    ),
    ),
          ],
          ),
      );
        },
        ),
    );
  }
}
