// interface.dart
// 기기와의 통신을 담당하는 클래스 입니다.
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
  bool get isAlreadyConnected => _connectedDevice != null;
  static final DeviceConnector _instance = DeviceConnector._internal();
  factory DeviceConnector() => _instance;
  DeviceConnector._internal();

  StreamController<String>? _notifyController;
  Stream<String>? get notifyStream => _notifyController?.stream;

  // 2025/03/29 listen 중복문제 해결.
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  // 연결기기 정보
  BluetoothDevice? _connectedDevice;
  // 연결기기 특성
  BluetoothCharacteristic? _targetCharacteristic;

  // 연결기기 특성 정보값 (일치여부 확인 시 필요)

  static const String SERVICE_UUID = "e2c56db5-dffb-48d2-b060-d0f5a71096e0";
  static const String CHARACTERISTIC_UUID =
      "a495ff10-c5b1-4b44-b512-1370f02d74de";

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
            await Future.delayed(Duration(seconds: 1));
            _connectedDevice = result.device; // SSVEP-Device Connection
            print("SSVEP-Device 연결 성공: ${result.device.remoteId}");
            // Find characteristic
            List<BluetoothService> services =
                await _connectedDevice!.discoverServices();
            for (var service in services) {
              print("서비스: ${service.uuid.str}");
              if (service.uuid.str.toLowerCase() == SERVICE_UUID) {
                for (var characteristic in service.characteristics) {
                  print("특성값: ${characteristic.uuid.str}");
                  if (characteristic.uuid.str.toLowerCase() ==
                      CHARACTERISTIC_UUID) {
                    _targetCharacteristic = characteristic;
                    print("연결됨: ${characteristic.uuid.str}");
                  }
                  // if (characteristic.properties.notify) // notify 활성화
                  // {
                  //   await characteristic.setNotifyValue(true);
                  // }
                }
              }
            }

            if (_targetCharacteristic == null)
              print("❌ 특성(characteristic)을 찾지 못했습니다.");
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

  // 데이터 내놔요 PULL 방식
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

  void startListeningToNotify(Function(String) onData) async {
    if (_targetCharacteristic == null) return;

    await _targetCharacteristic!.setNotifyValue(true); // notification 활성화

    _targetCharacteristic!.onValueReceived.listen((value) {
      String received = String.fromCharCodes(value);
      print("🔔 Notified: $received");
      onData(received); // 콜백으로 전달
    });
  }

  void startListeningToNotifyStream() async {
    if (_targetCharacteristic == null) return;

    _notifyController ??= StreamController<String>.broadcast();

    await _targetCharacteristic!.setNotifyValue(true);

    _targetCharacteristic!.onValueReceived.listen((value) {
      String received = String.fromCharCodes(value);
      _notifyController?.add(received); // 스트림으로 데이터 추가
    });
  }

  void dispose() // Stop to listening.
  {
    _scanSubscription?.cancel();
  }
}
