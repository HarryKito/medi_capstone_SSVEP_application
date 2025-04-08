import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:medi_capstone1/HAL/interface.dart';

class CheckMsgScreen extends StatefulWidget {
  @override
  _CheckMsgScreenState createState() => _CheckMsgScreenState();
}

class _CheckMsgScreenState extends State<CheckMsgScreen> {
  String _message = "데이터를 기다리는 중..."; // 최초
  late DeviceConnector _deviceConnector;

  @override
  void initState() {
    super.initState();
    _deviceConnector = DeviceConnector(); // 싱글톤
    _readDataPeriodically(); // 데이터 읽기
  }

  Future<void> _startReadingData() async {
    print("초기 연결 상태: ${_deviceConnector.isAlreadyConnected}");

    if (_deviceConnector.isAlreadyConnected) {
      print("이미 연결된 상태입니다. 알림 수신 시작.");
      _deviceConnector.startListeningToNotify((data) {
        setState(() {
          _message = data;
        });
      });
      return;
    }

    print("Bluetooth 연결 시도 중...");
    int isConnected = await _deviceConnector.connectBluetooth();

    if (isConnected == 1) {
      print("SSVEP-Device 연결 성공");
      _deviceConnector.startListeningToNotify((data) {
        setState(() {
          _message = data;
        });
      });
    } else {
      print("Bluetooth 연결 실패 (코드: $isConnected)");
      setState(() {
        _message = "Bluetooth 연결 실패 (코드: $isConnected)";
      });
    }
  }

  // 주기적으로 데이터를 읽어오는 함수
  void _readDataPeriodically() {
    // 데이터를 2초마다 읽기
    Future.delayed(Duration(seconds: 1), () async {
      String data = await _readData();
      setState(() {
        _message = data; // 읽은 데이터를 화면에 업데이트
      });

      // 다시 주기적으로 데이터 읽기
      _readDataPeriodically();
    });
  }

  // 데이터를 읽는 함수
  Future<String> _readData() async {
    BluetoothDevice? device = _deviceConnector.getConnectedDevice();

    if (device != null) {
      try {
        String? data = await _deviceConnector.readData();
        return data ?? "데이터 읽기 실패"; // null이면 기본 메시지 반환
      } catch (e) {
        print("데이터 읽기 오류: $e");
        return "데이터 읽기 오류";
      }
    }
    return "장치가 연결되지 않았습니다.";
  }

  @override
  void dispose() {
    _deviceConnector.dispose(); // 자원 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check Msg'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _readDataPeriodically, // 수동으로
          ),
        ],
      ),
      body: Center(
        child: Text(
          _message, // 실시간 메시지 표시
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
