import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:beeper/services/auth_service.dart';
import 'package:beeper/pages/user_selection_page.dart';
import 'package:beeper/pages/senior_main_page.dart';
import 'package:beeper/pages/student_dashboard_page.dart';
import 'package:beeper/pages/video_call_page.dart';
import 'package:beeper/pages/helper_login_page.dart';
import 'package:beeper/pages/helper_signup_page.dart';

void main() {
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
        '/video_call': (context) => VideoCallPage(),
        '/helper_login': (context) => HelperLoginPage(),
        '/helper_signup': (context) => HelperSignupPage(),
      },
    );
  }
}
