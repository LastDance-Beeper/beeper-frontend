import 'package:flutter/material.dart';

class StudentHelpListPage extends StatelessWidget {
  final List<HelpRequest> helpRequests = [
    HelpRequest('김철수', '청소 도움 및 말동무', '서울시 강남구', DateTime.now().subtract(Duration(minutes: 5))),
    HelpRequest('이영희', '장보기 도움', '서울시 서초구', DateTime.now().subtract(Duration(minutes: 15))),
    HelpRequest('박지성', '컴퓨터 사용 도움', '서울시 송파구', DateTime.now().subtract(Duration(minutes: 30))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('도움 요청 목록'),
      ),
      body: ListView.builder(
        itemCount: helpRequests.length,
        itemBuilder: (context, index) {
          return HelpRequestCard(helpRequest: helpRequests[index]);
        },
      ),
    );
  }
}

class HelpRequest {
  final String name;
  final String type;
  final String location;
  final DateTime requestTime;

  HelpRequest(this.name, this.type, this.location, this.requestTime);
}

class HelpRequestCard extends StatelessWidget {
  final HelpRequest helpRequest;

  const HelpRequestCard({Key? key, required this.helpRequest}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(helpRequest.name[0]),
        ),
        title: Text(helpRequest.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(helpRequest.type),
            Text(helpRequest.location),
            Text('${_getTimeAgo(helpRequest.requestTime)} 전'),
          ],
        ),
        trailing: ElevatedButton(
          child: Text('수락'),
          onPressed: () {
            // TODO: 도움 요청 수락 로직 구현
            Navigator.pushNamed(context, '/video_call');
          },
        ),
        isThreeLine: true,
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    Duration difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간';
    } else {
      return '${difference.inDays}일';
    }
  }
}
