// ux.dart
// user 인터페이스 모듈입니다.

// BlinkingBox - Blinking by specific hz
// Not included blinking timer algorithm.
import 'package:flutter/material.dart';
import 'dart:async';

class BlinkingBox extends StatefulWidget {
  final int frequency; // 주파수 (Hz)
  final bool isActive; // Blinking 여부

  const BlinkingBox({Key? key, required this.frequency, required this.isActive})
      : super(key: key);

  @override
  _BlinkingBoxState createState() => _BlinkingBoxState();
}

class _BlinkingBoxState extends State<BlinkingBox> {
  bool isBlack = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startBlinking();
  }

  void _startBlinking() {
    _timer?.cancel();
    // 기존 타이머 종료

    if (widget.isActive && widget.frequency > 0) {
      int interval = (1000 ~/ widget.frequency); // 주파수 간격 (ms)
      _timer = Timer.periodic(Duration(milliseconds: interval), (timer) {
        setState(() {
          isBlack = !isBlack;
        });
      });
    }
  }

  @override
  void didUpdateWidget(covariant BlinkingBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.frequency != widget.frequency ||
        oldWidget.isActive != widget.isActive) {
      _startBlinking();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      color: isBlack ? Colors.black : Colors.white,
      alignment: Alignment.center,
      child: Text(
        '${widget.frequency} Hz',
        style: TextStyle(
          color: isBlack ? Colors.white : Colors.black,
          fontSize: 24,
        ),
      ),
    );
  }
}
