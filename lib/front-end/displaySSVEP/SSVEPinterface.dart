import 'package:flutter/material.dart';
import 'package:medi_capstone1/front-end/displaySSVEP/entire.dart';
import 'package:medi_capstone1/front-end/displaySSVEP/SSVEP_list.dart';
import 'package:medi_capstone1/HAL/interface.dart'; // DeviceConnector

class SSVEPui extends StatefulWidget {
  final List<SSVEPItem> items;

  SSVEPui({required this.items});

  @override
  _SSVEPui createState() => _SSVEPui();
}

class _SSVEPui extends State<SSVEPui> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSequence());
  }

  void _onBlinkComplete() {
    if (currentIndex + 1 < widget.items.length)
      setState(() => currentIndex++);
    else
      Navigator.pop(context);
  }

  void _startSequence() async {
    while (currentIndex < widget.items.length) {
      final item = widget.items[currentIndex];

      // 현재 아이템의 자극 보여주기
      await Navigator.push(
        context,
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => Entire(
            frequency: item.hz,
            seconds: item.sec,
            color: item.color,
            onComplete: () => Navigator.of(context).pop(),
          ),
        ),
      );

      setState(() => currentIndex++);
    }
    // 전체 리스트 순환 후 pop
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final item =
        currentIndex < widget.items.length ? widget.items[currentIndex] : null;

    return Scaffold(
      appBar: AppBar(title: Text("SSVEP 실행 중")),
      body: Center(
        child: item == null
            ? Text("완료", style: TextStyle(fontSize: 24))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("현재 자극", style: TextStyle(fontSize: 20)),
                  SizedBox(height: 20),
                  Container(
                    width: 200,
                    height: 200,
                    color: item.color,
                    child: Center(
                      child: Text(
                        "${item.hz} Hz\n${item.sec}초",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
