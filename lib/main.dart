import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:beeper/services/auth_service.dart';
import 'package:beeper/pages/user_selection_page.dart';
import 'package:beeper/pages/senior_main_page.dart';
import 'package:beeper/pages/student_dashboard_page.dart';
import 'package:beeper/pages/video_call_page.dart';
import 'package:beeper/pages/helper_login_page.dart';
import 'package:beeper/pages/helper_signup_page.dart';
import 'package:beeper/pages/tag_edit_page.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core 패키지 임포트
import 'firebase_options.dart'; // firebase_options.dart 파일 임포트

import 'pages/help_request_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 프레임워크가 초기화되도록 보장
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Firebase 초기화
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beeper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => UserSelectionPage(),
        '/senior_main': (context) => SeniorMainPage(),
        '/student_dashboard': (context) => StudentDashboardPage(),
        '/helper_login': (context) => HelperLoginPage(),
        '/helper_signup': (context) => HelperSignupPage(),
        '/tag_edit': (context) => TagEditPage(),
        '/help_request_detail': (context) => HelpRequestDetailPage(requestId: ''),
      },
    );
  }
}
