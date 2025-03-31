import 'package:medi_capstone1/front-end/ux.dart';
import 'package:flutter/material.dart';
import 'package:medi_capstone1/HAL/interface.dart';
import 'dart:async';

class BlockScreen extends StatefulWidget {
  @override
  _BlockScreenState createState() => _BlockScreenState();
}

class _BlockScreenState extends State<BlockScreen> {
  int leftHz = 10; // 왼쪽
  int rightHz = 50; // 오른쪽
  bool isBlinking = true;
  final DeviceConnector deviceConnector = DeviceConnector();
  Color backgroundColor = Colors.white;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SSVEP Block Project'),
        // actions: [
        //   PopupMenuButton<String>(
        //     onSelected: (value) {
        //       switch (value) {
        //         case 'USB':
        //           deviceConnector.connectUSB();
        //           break;
        //         case 'Bluetooth':
        //           deviceConnector.connectBluetooth();
        //           break;
        //         case 'Wi-Fi':
        //           deviceConnector.connectWiFi("SSID", "password");
        //           break;
        //       }
        //     },
        //     itemBuilder: (context) => [
        //       PopupMenuItem(value: 'USB', child: Text('USB 연결')),
        //       PopupMenuItem(value: 'Bluetooth', child: Text('Bluetooth 연결')),
        //       PopupMenuItem(value: 'Wi-Fi', child: Text('Wi-Fi 연결')),
        //     ],
        //     icon: Icon(Icons.link),
        //   ),
        // ],
      ),
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
        ],
      ),
    );
  }
}
