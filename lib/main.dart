// main.dart
// 시작부분이자, DB및 인터페이스 호출구문이 호출되는 곳입니다.
// 시스템적 제어를 제외한 작성은 금지함.
import 'package:flutter/material.dart';
import 'package:medi_capstone1/front-end/bluetoothConnection.dart';
import 'package:medi_capstone1/front-end/MainScreen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const SsvepMobile());
}

class SsvepMobile extends StatelessWidget {
  const SsvepMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: navigatorKey, // 키 설정
        home: MainScreen()); // BluetoothConnectionScreen
  }
}

// VR기깃 ㅓ 대체적으로 보여주기에
//  BLE 디바이스 컨트롤보드 만들기