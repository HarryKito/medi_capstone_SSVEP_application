// interface.dart
// 기기와의 통신을 담당하는 클래스 입니다.

// TODO: 필요한 패키지 추가할 것
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:wifi_iot/wifi_iot.dart';

class DeviceConnector {
  static final DeviceConnector _instance = DeviceConnector._internal();
  factory DeviceConnector() => _instance;
  DeviceConnector._internal();

  // FIXME: USB 연결 (구현 필요)
  Future<void> connectUSB() async {
    print("USB 연결 시도...");
  }

  // FIXME: Wi-Fi 연결 (구현 필요)
  Future<void> connectWiFi(String ssid, String password) async {
    bool success = false;
    //await WiFiForIoTPlugin.connect(ssid, password: password);
    print(success ? "Wi-Fi 연결 성공" : "Wi-Fi 연결 실패");
  }

  // FIXME: Bluetooth 연결 (구현 필요)
  Future<void> connectBluetooth() async {
    // FlutterBluetoothSerial.instance.requestEnable();
    print("Bluetooth 활성화 요청");
  }
}
