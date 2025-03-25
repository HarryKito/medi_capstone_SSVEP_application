// foreground.dart
// UI/UX 핵심 구성요소를 통합하는 핵심 파트입니다.
import 'package:medi_capstone1/ux.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int leftHz = 10;
  int rightHz = 50;
  bool isBlinking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SSVEP Project')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              BlinkingBox(frequency: leftHz, isActive: isBlinking),
              BlinkingBox(frequency: rightHz, isActive: isBlinking),
            ],
          ),
          SizedBox(height: 50),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isBlinking = !isBlinking;
              });
            },
            child: Text(isBlinking ? 'Stop' : 'Play'),
          ),
        ],
      ),
    );
  }
}
