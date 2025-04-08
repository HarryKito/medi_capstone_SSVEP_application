import 'package:flutter/material.dart';
import 'dart:async';

class Entire extends StatefulWidget {
  final int frequency;
  final int seconds;
  final Color color;

  Entire({
    required this.frequency,
    required this.seconds,
    required this.color,
  });

  @override
  _EntireState createState() => _EntireState();
}

class _EntireState extends State<Entire> {
  late Color backgroundColor;
  Timer? _blinkTimer;
  Timer? _stopTimer;

  @override
  void initState() {
    super.initState();
    backgroundColor = Colors.white;
    startBlinking();
    stopAfterDuration();
  }

  void startBlinking() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer.periodic(
      Duration(milliseconds: (1000 ~/ widget.frequency)),
      (timer) {
        setState(() {
          backgroundColor =
              (backgroundColor == Colors.white) ? widget.color : Colors.white;
        });
      },
    );
  }

  void stopAfterDuration() {
    _stopTimer = Timer(Duration(seconds: widget.seconds), () {
      _blinkTimer?.cancel();
      if (mounted) {
        Navigator.pop(context); // 자동으로 뒤로 가기
      }
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _stopTimer?.cancel();
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
