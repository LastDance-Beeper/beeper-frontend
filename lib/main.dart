import 'package:flutter/material.dart';

void main() {
  runApp(BeeperApp());
}

class BeeperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beeper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BeeperHomePage(),
    );
  }
}

class BeeperHomePage extends StatefulWidget {
  @override
  _BeeperHomePageState createState() => _BeeperHomePageState();
}

class _BeeperHomePageState extends State<BeeperHomePage> {
  String _message = "Welcome to Beeper!";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beeper'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _message,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _message = "Button Pressed!";
                });
              },
              child: Text('Press Me'),
            ),
          ],
        ),
      ),
    );
  }
}
