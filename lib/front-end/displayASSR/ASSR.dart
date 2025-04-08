import 'package:flutter/material.dart';

class ASSR extends StatelessWidget {
  final int frequency;
  final int seconds;

  ASSR({required this.frequency, required this.seconds});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ASSR 화면")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("선택된 주파수: $frequency Hz", style: TextStyle(fontSize: 20)),
            SizedBox(height: 12),
            Text("작동 시간: $seconds 초", style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
