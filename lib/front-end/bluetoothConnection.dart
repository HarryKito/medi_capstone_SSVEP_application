import 'package:flutter/material.dart';
import 'package:medi_capstone1/parser.dart';
import 'package:medi_capstone1/HAL/interface.dart'; // デバイス関連
import 'package:medi_capstone1/front-end/MainScreen.dart';
import 'package:medi_capstone1/front-end/displaySSVEP/entire.dart';
import 'package:medi_capstone1/main.dart';

class BluetoothConnectionScreen extends StatefulWidget {
  @override
  _BluetoothConnectionScreenState createState() =>
      _BluetoothConnectionScreenState();
}

class _BluetoothConnectionScreenState extends State<BluetoothConnectionScreen> {
  int _connectionStatus = 0; // 0: Connecting, 1: Connected, -1~-4: Errors

  @override
  void initState() {
    super.initState();
    _connectToDevice();
  }

  Future<void> _connectToDevice() async {
    int result = await DeviceConnector().connectBluetooth();
    if (result == 1) {
      DeviceConnector().startListeningToNotifyStream();
      DeviceConnector().notifyStream?.listen((data) {
        print("글로벌 수신 데이터: $data");
        ParsedData? parsed = parseNotifyData(data);
        if (parsed != null) {
          // 여기서 어떤 화면이든 강제로 띄우고 싶다면 navigatorKey 사용
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => Entire(
                frequency: parsed.frequency,
                seconds: parsed.seconds,
                color: parsed.color,
              ),
            ),
          );
        }
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      setState(() {
        _connectionStatus = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Device Connection')),
      body: Center(
        child: _connectionStatus == 0
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getErrorMessage(_connectionStatus),
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _connectToDevice,
                    child: Text('Retry Connection'),
                  ),
                ],
              ),
      ),
    );
  }

  // 연결 안될 시 에러메시지
  String _getErrorMessage(int status) {
    switch (status) {
      case -1:
        return "Bluetooth not supported.";
      case -2:
        return "Please turn on Bluetooth.";
      case -3:
        return "Device not found.";
      case -4:
        return "Connection failed.";
      default:
        return "Connecting...";
    }
  }
}
