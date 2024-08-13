import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:beeper/services/auth_service.dart';

class UserSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Beeper',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 50),
              ElevatedButton(
                child: Text('어르신'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/senior_main');
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('대학생'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/student_dashboard');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
