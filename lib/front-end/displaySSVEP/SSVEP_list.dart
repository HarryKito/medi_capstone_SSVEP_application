// SSVEP 적용 리스트
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:medi_capstone1/front-end/displaySSVEP/SSVEPinterface.dart';
import 'package:medi_capstone1/HAL/interface.dart'; // DeviceConnector

class SSVEPListScreen extends StatefulWidget {
  @override
  _SSVEPListScreenState createState() => _SSVEPListScreenState();
}

class _SSVEPListScreenState extends State<SSVEPListScreen> {
  int currentIndex = 0;
  List<SSVEPItem> items = [
    SSVEPItem(hz: 2, sec: 2, color: Colors.pink),
    SSVEPItem(hz: 60, sec: 1, color: Colors.cyan),
  ];

  void _addItem() async {
    final result = await showDialog<SSVEPItem>(
      context: context,
      builder: (context) => AddItemDialog(),
    );

    if (result != null) {
      setState(() {
        items.add(result);
      });
    }
  }

  TableRow _buildRow(BuildContext context, SSVEPItem item, int index) {
    return TableRow(
      children: [
        _tableCell('${index + 1}', () => _editItem(index)),
        _tableCell('${item.hz} Hz', () => _editItem(index)),
        _tableCell('${item.sec} 초', () => _editItem(index)),
        _colorCell(item.color, () => _editItem(index)),
        _deleteCell(index), // 삭제 버튼 추가
      ],
    );
  }

  Widget _deleteCell(int index) {
    return IconButton(
      icon: Icon(Icons.delete, color: Colors.red),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("삭제 확인"),
            content: Text("${index + 1}번째 항목을 삭제하시겠습니까?"),
            actions: [
              TextButton(
                child: Text("취소"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text("삭제"),
                onPressed: () {
                  setState(() {
                    items.removeAt(index);
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tableCell(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Text(text),
      ),
    );
  }

  Widget _colorCell(Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(),
        ),
      ),
    );
  }

  void _editItem(int index) async {
    final result = await showDialog<SSVEPItem>(
      context: context,
      builder: (context) => AddItemDialog(item: items[index]),
    );

    if (result != null) {
      setState(() {
        items[index] = result;
      });
    }
  }

  void _runNext() {
    if (currentIndex >= items.length) return;
    final currentItem = items[currentIndex];

    print("_startSSVEP(currentItem);");

    Future.delayed(Duration(seconds: currentItem.sec), () {
      setState(() => currentIndex++);
      _runNext();
    });
  }

  void _navigateToInterfaceAll() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SSVEPinterface(
          items: items, // 현재 SSVEPListScreen 내의 전체 리스트
        ),
      ),
    );
  }

  void Send_list() async {
    final StringBuffer message = StringBuffer();

    message.write("{\n\tCNT : ${items.length}");

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final hexColor = item.color.value
          .toRadixString(16)
          .padLeft(8, '0')
          .substring(2)
          .toUpperCase(); // ARGB → RGB
      message.write(
          "\n\tN: ${i + 1}\n\tF : ${item.hz}\n\tS : ${item.sec}\n\tC: $hexColor");
    }

    message.write("\n}");

    final dataToSend = message.toString();
    print("BLE 전송 메시지:\n$dataToSend");

    try {
      print("BLE 데이터 전송 성공");
    } catch (e) {
      print("BLE 데이터 전송 실패: $e");
    }
  }

  void _execute() {
    Send_list();
    _navigateToInterfaceAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SSVEP Action List View"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Table(
                border: TableBorder.all(),
                columnWidths: {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade300),
                    children: [
                      _headerCell("번호"),
                      _headerCell("Hz"),
                      _headerCell("시간"),
                      _headerCell("색상"),
                      _headerCell("삭제")
                    ],
                  ),
                  ...items
                      .asMap()
                      .entries
                      .map(
                        (entry) => _buildRow(context, entry.value, entry.key),
                      )
                      .toList(),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: "runAll",
            onPressed: _execute,
            label: Text("전체 실행"),
            icon: Icon(Icons.play_arrow),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "addItem",
            onPressed: _addItem,
            child: Icon(Icons.add),
            tooltip: "액션 추가",
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String label) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class SSVEPItem {
  final int hz;
  final int sec;
  final Color color;

  SSVEPItem({required this.hz, required this.sec, required this.color});
}

class AddItemDialog extends StatefulWidget {
  final SSVEPItem? item;
  AddItemDialog({this.item});

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  int? hz;
  int? sec;
  Color color = Color.fromARGB(255, 0, 0, 0); // 초기값 (0, 0, 0)

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      hz = widget.item!.hz;
      sec = widget.item!.sec;
      color = widget.item!.color;
    } else {
      hz = 0;
      sec = 0;
    }
  }

  Widget _buildColorInput(String label, void Function(String) onChanged,
      {String initial = '0'}) {
    return Expanded(
      child: TextFormField(
        decoration: InputDecoration(labelText: label),
        initialValue: initial,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        validator: (value) {
          if (value == null || value.isEmpty) return '필수';
          final val = int.tryParse(value);
          if (val == null || val < 0 || val > 255) return '0~255';
          return null;
        },
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("새 SSVEP 항목 추가"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: "Hz"),
                  initialValue: hz?.toString() ?? '0',
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || value.isEmpty ? '값을 입력하세요' : null,
                  onSaved: (value) => hz = int.tryParse(value ?? '0'),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "시간 (초)"),
                  initialValue: sec?.toString() ?? '0',
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || value.isEmpty ? '값을 입력하세요' : null,
                  onSaved: (value) => sec = int.tryParse(value ?? '0'),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text("색상:"),
                    SizedBox(width: 10),
                    Expanded(
                      child: Row(
                        children: [
                          _buildColorInput("R", (value) {
                            final val = int.tryParse(value) ?? 0;
                            setState(() => color = color.withRed(val));
                          }, initial: color.red.toString()),
                          SizedBox(width: 8),
                          _buildColorInput("G", (value) {
                            final val = int.tryParse(value) ?? 0;
                            setState(() => color = color.withGreen(val));
                          }, initial: color.green.toString()),
                          SizedBox(width: 8),
                          _buildColorInput("B", (value) {
                            final val = int.tryParse(value) ?? 0;
                            setState(() => color = color.withGreen(val));
                          }, initial: color.blue.toString()),
                        ],
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      margin: EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Text(
            "시간만 입력 시 대기화면으로 사용됩니다.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text("취소"),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text(widget.item != null ? "수정" : "추가"),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              Navigator.pop(
                context,
                SSVEPItem(hz: hz!, sec: sec!, color: color),
              );
            }
          },
        ),
      ],
    );
  }
}
