import 'package:flutter/material.dart';

class ParsedData {
  final int frequency;
  final int seconds;
  final Color color;

  ParsedData(
      {required this.frequency, required this.seconds, required this.color});
}

ParsedData? parseNotifyData(String input) {
  try {
    final regex = RegExp(r'F:(\d+)SS:(\d+)C:([0-9A-Fa-f]{6})');
    final match = regex.firstMatch(input);

    if (match != null) {
      int freq = int.parse(match.group(1)!);
      int sec = int.parse(match.group(2)!);
      String hex = match.group(3)!;
      Color color = Color(int.parse('0xFF$hex'));

      return ParsedData(frequency: freq, seconds: sec, color: color);
    }
  } catch (e) {
    print("❌ 파싱 실패: $e");
  }
  return null;
}
