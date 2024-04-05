import 'dart:async';

import 'package:flutter/material.dart';

class PreciseTimer extends StatefulWidget {
  const PreciseTimer({super.key});

  @override
  State<PreciseTimer> createState() => _PreciseTimerState();
}

class _PreciseTimerState extends State<PreciseTimer> {
  Timer? _timer;
  DateTime? _startTime;
  final _elapsed = ValueNotifier<Duration>(const Duration());

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_timer != null && _timer!.isActive) return;

    _startTime = DateTime.now();

    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      final now = DateTime.now();

      _elapsed.value = now.difference(_startTime!);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _resetTimer() {
    _timer?.cancel();
    _elapsed.value = const Duration();
  }

  String _formatTimer(String duration) {
    final point = duration.indexOf('.');
    return duration.substring(0, point + 3);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.asset(
                    'assets/images/person.png',
                  ),
                ),
                const Text('Name'),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ListenableBuilder(
                    listenable: _elapsed,
                    builder: (context, _) {
                      return Text(
                        _formatTimer(_elapsed.value.toString()),
                        style: const TextStyle(
                          fontSize: 30,
                          fontFamily: 'IBMPlexMono',
                        ),
                      );
                    }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filled(
                      onPressed: _startTimer,
                      icon: const Icon(Icons.start),
                    ),
                    IconButton.filled(
                      onPressed: _stopTimer,
                      icon: const Icon(Icons.stop),
                    ),
                    IconButton.filled(
                      onPressed: _resetTimer,
                      icon: const Icon(Icons.restore),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
