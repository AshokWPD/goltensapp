import 'dart:async';
import 'package:flutter/material.dart';
import 'package:goltens_core/utils/functions.dart';

class CountdownTimer extends StatefulWidget {
  final int seconds;
  final Function() onTimerFinished;

  const CountdownTimer({
    super.key,
    required this.seconds,
    required this.onTimerFinished,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  int _timeLeft = 0;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _tick(Timer timer) {
    setState(() {
      if (_timeLeft > 0) {
        _timeLeft--;
      } else {
        widget.onTimerFinished();
        _timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Timer: ${formattedTime(timeInSecond: _timeLeft)}',
      style: const TextStyle(fontSize: 17.0),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
