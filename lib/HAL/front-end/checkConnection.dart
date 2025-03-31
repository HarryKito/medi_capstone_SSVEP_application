import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:medi_capstone1/HAL/interface.dart';

class CheckMsgScreen extends StatefulWidget {
  @override
  _CheckMsgScreenState createState() => _CheckMsgScreenState();
}

class _CheckMsgScreenState extends State<CheckMsgScreen> {
  String _message = "데이터를 기다리는 중..."; // 초기 메시지
  late DeviceConnector _deviceConnector;

  @override
  void initState() {
    super.initState();
    _deviceConnector = DeviceConnector(); // 싱글톤 인스턴스 생성
    _startReadingData(); // 데이터 읽기 시작
  }

  Future<void> _startReadingData() async {
    int isConnected = await _deviceConnector.connectBluetooth();

    if (isConnected == 1) {
      print("SSVEP-Device 연결 성공");

      // 데이터를 주기적으로 읽기
      _readDataPeriodically();
    } else {
      setState(() {
        _message = "Bluetooth 연결 실패";
      });
    }
  }

  // 주기적으로 데이터를 읽어오는 함수
  void _readDataPeriodically() {
    // 데이터를 2초마다 읽기
    Future.delayed(Duration(seconds: 2), () async {
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
            onPressed: _startReadingData, // 수동으로 다시 시작하는 버튼
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
