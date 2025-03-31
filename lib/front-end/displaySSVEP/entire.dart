import 'package:flutter/material.dart';
import 'dart:async';

class Entire extends StatefulWidget {
  @override
  _EntireState createState() => _EntireState();
}

class _EntireState extends State<Entire> {
  int frequency = 10; // 깜빡이는 주파수 (Hz)
  Color backgroundColor = Colors.white;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startBlinking();
  }

  void startBlinking() {
    _timer?.cancel(); // 기존 타이머 정리
    _timer =
        Timer.periodic(Duration(milliseconds: (1000 ~/ frequency)), (timer) {
      setState(() {
        backgroundColor =
            (backgroundColor == Colors.white) ? Colors.black : Colors.white;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // 뒤로 가기 허용
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pop(context); // 뒤로 가기 동작 수행
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Stack(
          children: [
            SizedBox.expand(), // 완전한 빈 화면
            Positioned(
              top: 40, // 화면 상단 여백
              left: 20,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.red, size: 30),
                onPressed: () {
                  Navigator.pop(context); // 뒤로 가기 버튼 동작
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
