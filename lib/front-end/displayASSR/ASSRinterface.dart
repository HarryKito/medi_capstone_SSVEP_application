import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';

class SoundConfig {
  double start;
  double end;
  String type;
  double freq;
  double volume;
  bool repeat;

  SoundConfig({
    required this.start,
    required this.end,
    required this.type,
    required this.freq,
    required this.volume,
    this.repeat = false,
  });
}

class ASSRinterface extends StatefulWidget {
  @override
  _ASSRinterfaceState createState() => _ASSRinterfaceState();
}

class _ASSRinterfaceState extends State<ASSRinterface> {
  final List<SoundConfig> configs = [
    SoundConfig(start: 0, end: 2, type: '순음', freq: 5, volume: 50),
  ];

  final List<String> types = ['순음', '톤버스트'];
  bool isPlaying = false;
  bool selectAll = false;

  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _playerInited = false;

  @override
  void initState() {
    super.initState();
    _player.openPlayer().then((_) {
      setState(() => _playerInited = true);
    });
  }

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  Future<Uint8List> generateSound(
      String type, double freq, double volume, int durationMs) async {
    int sampleRate = 44100;
    int samples = (durationMs * sampleRate ~/ 1000);
    Float64List signal = Float64List(samples);

    for (int i = 0; i < samples; i++) {
      double t = i / sampleRate;
      double value;

      switch (type) {
        case '톤버스트':
          double burstCycle = 1.0 / freq;
          value =
              ((t % burstCycle) < burstCycle / 2) ? sin(2 * pi * 1000 * t) : 0;
          break;
        case '순음':
        default:
          double toneCycle = 1.0 / freq;
          value = ((t % toneCycle) < toneCycle / 2) ? 1.0 : 0.0;
      }

      signal[i] = value * (volume / 100);
    }

    Int16List intData =
        Int16List.fromList(signal.map((e) => (e * 32767).toInt()).toList());
    return Uint8List.view(intData.buffer);
  }

  Future<void> playConfig(SoundConfig config) async {
    int durationMs = ((config.end - config.start) * 1000).toInt();
    final data = await generateSound(
        config.type, config.freq, config.volume, durationMs);

    await _player.startPlayer(
      fromDataBuffer: data,
      codec: Codec.pcm16,
      sampleRate: 44100,
      numChannels: 1,
    );
    await Future.delayed(Duration(milliseconds: durationMs));
    await _player.stopPlayer();
  }

  Future<void> playSequence() async {
    if (!_playerInited) debugPrint("플레이어가 아직 초기화 안됐음.");
    setState(() => isPlaying = true);

    for (var config in configs) {
      await playConfig(config);
    }

    while (isPlaying) {
      final repeats = configs.where((c) => c.repeat).toList();
      if (repeats.isEmpty) break;

      for (var config in repeats) {
        if (!isPlaying) break;
        await playConfig(config);
      }
    }

    setState(() => isPlaying = false);
  }

  void stopSequence() {
    setState(() => isPlaying = false);
    _player.stopPlayer();
  }

  void syncStartTime(int index) {
    if (index > 0) {
      configs[index].start = configs[index - 1].end;
    }
  }

  void syncEndTime(int index) {
    if (index < configs.length - 1) {
      configs[index + 1].start = configs[index].end;
    }
  }

  void ensureEndAfterStart(int index) {
    if (configs[index].end <= configs[index].start) {
      configs[index].end = configs[index].start + 1.0;
    }
  }

  Widget buildConfigItem(int index) {
    var config = configs[index];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(children: [
              Checkbox(
                value: config.repeat,
                onChanged: (val) {
                  setState(() => config.repeat = val!);
                },
              ),
              Text("구간 ${index + 1} (${config.type})"),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() => configs.removeAt(index));
                },
              ),
            ]),
            Row(children: [
              const Text("시작(초): "),
              Expanded(
                child: TextField(
                  controller: TextEditingController(
                      text: config.start.toStringAsFixed(1)),
                  keyboardType: TextInputType.number,
                  onSubmitted: (val) {
                    double? start = double.tryParse(val);
                    if (start != null) {
                      setState(() {
                        config.start = start;
                        ensureEndAfterStart(index);
                        syncStartTime(index);
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              const Text("끝(초): "),
              Expanded(
                child: TextField(
                  controller: TextEditingController(
                      text: config.end.toStringAsFixed(1)),
                  keyboardType: TextInputType.number,
                  onSubmitted: (val) {
                    double? end = double.tryParse(val);
                    if (end != null) {
                      setState(() {
                        config.end = end;
                        ensureEndAfterStart(index);
                        syncEndTime(index);
                      });
                    }
                  },
                ),
              ),
            ]),
            Row(children: [
              const Text("주파수: "),
              Expanded(
                child: Slider(
                  value: config.freq,
                  min: 1,
                  max: 50,
                  divisions: 49,
                  label: config.freq.toStringAsFixed(1),
                  onChanged: (val) => setState(() => config.freq = val),
                ),
              ),
              Text("${config.freq.toStringAsFixed(1)} Hz"),
            ]),
            Row(children: [
              const Text("볼륨: "),
              Expanded(
                child: Slider(
                  value: config.volume,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: config.volume.toStringAsFixed(0),
                  onChanged: (val) => setState(() => config.volume = val),
                ),
              ),
              Text("${config.volume.toStringAsFixed(0)}%"),
            ]),
            DropdownButton<String>(
              value: config.type,
              items: types
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => config.type = val!),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ASSR 테스트")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(children: [
              Checkbox(
                value: selectAll,
                onChanged: (val) {
                  setState(() {
                    selectAll = val!;
                    for (var c in configs) {
                      c.repeat = selectAll;
                    }
                  });
                },
              ),
              const Text("전체 반복"),
              const Spacer(),
              ElevatedButton(
                onPressed: isPlaying
                    ? null
                    : () => setState(() {
                          configs.add(SoundConfig(
                            start: configs.last.end,
                            end: configs.last.end + 2,
                            type: '순음',
                            freq: 5,
                            volume: 50,
                          ));
                        }),
                child: const Text("구간 추가"),
              ),
            ]),
            for (int i = 0; i < configs.length; i++) buildConfigItem(i),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: !_playerInited || isPlaying ? null : playSequence,
                  child: const Text("재생"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isPlaying ? stopSequence : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("정지"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
