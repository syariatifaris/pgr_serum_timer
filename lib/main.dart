import 'package:flutter/material.dart';
import 'package:pgr_serum_timer/pages/timer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PGR Serum Timer',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: TimerPage(title: 'PGR Serum Timer'),
    );
  }
}
