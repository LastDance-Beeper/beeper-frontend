import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:beeper/services/auth_service.dart';
import 'package:beeper/pages/user_selection_page.dart';
import 'package:beeper/pages/senior_main_page.dart';
import 'package:beeper/pages/student_dashboard_page.dart';
import 'package:beeper/pages/helper_login_page.dart';
import 'package:beeper/pages/helper_signup_page.dart';
import 'package:beeper/pages/tag_edit_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/help_request_detail_page.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
        '/help_request_detail': (context) => HelpRequestDetailPage(requestId: '', title: '', description: '',),
      },
    );
  }
}
