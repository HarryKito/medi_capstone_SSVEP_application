import 'package:flutter/material.dart';
import 'package:medi_capstone1/front-end/displayASSR/ASSR.dart';

class ASSRinterface extends StatefulWidget {
  @override
  _ASSRinterfaceState createState() => _ASSRinterfaceState();
}

class _ASSRinterfaceState extends State<ASSRinterface> {
  int selectedHz = 10;
  TextEditingController timeController = TextEditingController();

  void onStartPressed() {
    int? seconds = int.tryParse(timeController.text);

    if (seconds == null || seconds <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("유효한 시간을 입력하세요 (초 단위)")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ASSR(
          frequency: selectedHz,
          seconds: seconds,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ASSR 인터페이스')),
      body: Center(
        child: Container(
          width: 300,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<int>(
                value: selectedHz,
                items: List.generate(51, (index) => 10 + index).map((value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text("$value Hz"),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedHz = value;
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: timeController,
                decoration: InputDecoration(labelText: "작동 시간 (초)"),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: onStartPressed,
                child: Text("시작"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
