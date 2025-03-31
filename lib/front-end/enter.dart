// enter.dart
// Application 구동 시 최초 화면

import 'package:flutter/material.dart';

// Pages by Blink mode
import 'package:medi_capstone1/front-end/displaySSVEP/block.dart';
import 'package:medi_capstone1/front-end/displaySSVEP/entire.dart';
// import 'package:medi_capstone1/front-end/displaySSVEP/vr.dart'; // 현재로서는 미사용

// Check the connected bluetooth device
import 'package:medi_capstone1/HAL/front-end/checkConnection.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SSVEP Mobile'),
        actions: [
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CheckMsgScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BlockScreen()),
                );
              },
              child: Text('Block Mode'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Entire()),
                );
              },
              child: Text('Entire Mode'),
            ),
          ],
        ),
      ),
    );
  }
}
