// interface.dart
// 기기와의 통신을 담당하는 클래스 입니다.

// TODO: 필요한 패키지 추가할 것
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

/// `DeviceConnector` Bluetooth 연결 관리, 싱글톤 클래스
/// `SSVEP-Device`기기와 자동으로 연결하는 기능 제공
///
/// ```dart
/// DeviceConnector deviceConnector = DeviceConnector();
/// bool isConnected = await deviceConnector.connectBluetooth();
/// print("연결 상태: $isConnected");
///
// `connectBluetooth()` 함수는 블루투스 연결을 시도하고 `int` 값을 반환합니다.
//
/// - ` 1` : Connection success
/// - `-1` : Bluetooth not supported
/// - `-2` : Bluetooth is turned off
/// - `-3` : Device not found (Time out)
/// - `-4` : Connection failed

class DeviceConnector {
  static final DeviceConnector _instance = DeviceConnector._internal();
  factory DeviceConnector() => _instance;
  DeviceConnector._internal();

  // 2025/03/29 listen 중복문제 해결.
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  // 연결기기 정보
  BluetoothDevice? _connectedDevice;
  // 연결기기 특성
  BluetoothCharacteristic? _targetCharacteristic;

  // 연결기기 특성 정보값 (일치여부 확인 시 필요)
  static const String SERVICE_UUID = "00001812-0000-1000-8000-00805F9B34FB";
  static const String CHARACTERISTIC_UUID =
      "00002B05-0000-1000-8000-00805F9B34FB";

  // Bluetooth
  Future<int> connectBluetooth() async {
    // Is device Bluetooth support ?
    if (!await FlutterBluePlus.isSupported) return -1;

    // Is Bluetooth activate ?
    BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) return -2;

    _scanSubscription?.cancel(); // listen 중복방지.

    // Bluetooth scan
    FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
    print("블루투스 스캔 시작...");

    Completer<int> connectionResult = Completer<int>();

    // List of all Bluetooth devices
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult result in results) {
        print(
            "발견된 장치: ${result.device.platformName} (${result.device.remoteId})");

        // SSVEP-Device 연결
        if (result.device.platformName == 'SSVEP-Device') {
          await FlutterBluePlus.stopScan();
          try {
            await result.device.connect();
            _connectedDevice = result.device; // SSVEP-Device Connection
            print("SSVEP-Device 연결 성공: ${result.device.remoteId}");
            // Find characteristic
            List<BluetoothService> services =
                await _connectedDevice!.discoverServices();
            for (var service in services) {
              if (service.uuid.toString().toUpperCase() == SERVICE_UUID) {
                for (var characteristic in service.characteristics) {
                  if (characteristic.uuid.toString().toUpperCase() ==
                      CHARACTERISTIC_UUID) {
                    _targetCharacteristic = characteristic;
                    print(
                        "Target characteristic found: ${characteristic.uuid}");
                  }
                }
              }
            }
            if (!connectionResult.isCompleted) connectionResult.complete(1);
          } catch (e) {
            print("Bluetooth 연결 실패: $e");
            if (!connectionResult.isCompleted) connectionResult.complete(-4);
          }
        }
      }
    });

    // Connection Timeout 5sec
    Future.delayed(Duration(seconds: 5), () {
      if (!connectionResult.isCompleted) connectionResult.complete(-3);
    });

    return connectionResult.future;
  }

  /// 연결된 SSVEP-Device 내놔요
  BluetoothDevice? getConnectedDevice() {
    return _connectedDevice;
  }

  // 데이터 내놔요
  Future<String?> readData() async {
    try {
      List<int> value = await _targetCharacteristic!.read();
      String receivedData = String.fromCharCodes(value);
      print("Received Data: $receivedData");
      return receivedData;
    } catch (e) {
      print("Read failed: $e");
      return null;
    }
  }

  void dispose() {
    // Stop to listening.
    _scanSubscription?.cancel();
  }
}
