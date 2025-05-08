import 'package:flutter/material.dart';
import 'package:medi_capstone1/front-end/displaySSVEP/entire.dart';
import 'package:medi_capstone1/front-end/displaySSVEP/SSVEP_list.dart';
import 'package:medi_capstone1/HAL/interface.dart'; // DeviceConnector

class SSVEPinterface extends StatefulWidget {
  final List<SSVEPItem> items;

  SSVEPinterface({required this.items});

  @override
  _SSVEPinterfaceState createState() => _SSVEPinterfaceState();
}

class _SSVEPinterfaceState extends State<SSVEPinterface> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startSequence();
  }

  void _startSequence() async {
    while (currentIndex < widget.items.length) {
      final item = widget.items[currentIndex];
      await _runSSVEP(item.hz, item.sec, item.color);
      setState(() => currentIndex++);
    }
    Navigator.pop(context); // 완료 후 이전 화면으로
  }

  Future<void> _runSSVEP(int hz, int sec, Color color) async {
    // Locking
    await Future.delayed(Duration.zero);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Entire(
          frequency: hz,
          seconds: sec,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item =
        currentIndex < widget.items.length ? widget.items[currentIndex] : null;

    return Scaffold(
      appBar: AppBar(title: Text("SSVEP 실행 중")),
      body: Center(
        child: item == null
            ? Text("완료")
            : Container(
                width: 200,
                height: 200,
                color: item.color,
                child: Center(
                  child: Text("${item.hz} Hz\n${item.sec}초",
                      style: TextStyle(fontSize: 24, color: Colors.white)),
                ),
              ),
      ),
    );
  }
}
