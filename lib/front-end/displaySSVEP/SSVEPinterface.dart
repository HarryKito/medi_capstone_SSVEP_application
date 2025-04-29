import 'package:flutter/material.dart';
import 'package:medi_capstone1/front-end/displaySSVEP/entire.dart';
import 'package:medi_capstone1/HAL/interface.dart'; // DeviceConnector

class SSVEPinterface extends StatefulWidget {
  @override
  _SSVEPinterface createState() => _SSVEPinterface();
}

class _SSVEPinterface extends State<SSVEPinterface> {
  int selectedHz = 10;
  TextEditingController timeController = TextEditingController();

  double red = 255;
  double green = 255;
  double blue = 255;

  int get redInt => red.toInt();
  int get greenInt => green.toInt();
  int get blueInt => blue.toInt();

  Color get selectedColor => Color.fromARGB(255, redInt, greenInt, blueInt);

  final List<int> hzOptions = [for (int i = 10; i <= 60; i += 5) i];

  void onStartPressed() async {
    int? seconds = int.tryParse(timeController.text);

    if (seconds == null || seconds <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("유효한 시간을 입력하세요 (초 단위)")),
      );
      return;
    }
    // HEX Msg
    String hexColor = selectedColor.red.toRadixString(16).padLeft(2, '0') +
        selectedColor.green.toRadixString(16).padLeft(2, '0') +
        selectedColor.blue.toRadixString(16).padLeft(2, '0');

    String message =
        "F:${selectedHz}S:${seconds.toString().padLeft(2, '0')}C:$hexColor";

    try {
      await DeviceConnector.sendData(message);
      print("Send to device: $message");
    } catch (e) {
      print("BLE 전송 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send msg to the BLE")),
      );
    }

    // 여기가 추가할 위치!
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Entire(
          frequency: selectedHz,
          seconds: seconds,
          color: selectedColor,
        ),
      ),
    );
  }

  Widget buildColorSlider(String label, double value,
      ValueChanged<double> onChanged, Color activeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ${value.toInt()}"),
        Slider(
          value: value,
          min: 0,
          max: 255,
          divisions: 255,
          label: value.toInt().toString(),
          onChanged: onChanged,
          activeColor: activeColor,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SSVEP Interface")),
      body: Center(
        child: Card(
          margin: EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Hz 선택
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(labelText: '주파수 (Hz)'),
                    value: selectedHz,
                    items: hzOptions.map((hz) {
                      return DropdownMenuItem(value: hz, child: Text('$hz Hz'));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedHz = val!;
                      });
                    },
                  ),
                  SizedBox(height: 16),

                  // 시간 입력
                  TextField(
                    controller: timeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '작동 시간 (초)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),

                  // 색상 선택 슬라이더 (RGB)
                  buildColorSlider(
                      "R", red, (val) => setState(() => red = val), Colors.red),
                  buildColorSlider("G", green,
                      (val) => setState(() => green = val), Colors.green),
                  buildColorSlider("B", blue,
                      (val) => setState(() => blue = val), Colors.blue),

                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Colour",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // 시작 버튼
                  ElevatedButton(
                    onPressed: onStartPressed,
                    child: Text("시작"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// FIXME: 이 부분 블루투스로 보내는거로 만들기.