import 'dart:async';
import 'package:flutter/material.dart';

class LiveClock extends StatefulWidget {
  final TextStyle? style;

  const LiveClock({super.key, this.style});

  @override
  State<LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatNumber(int number) {
    return number.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    final hour = _formatNumber(_currentTime.hour);
    final minute = _formatNumber(_currentTime.minute);
    final second = _formatNumber(_currentTime.second);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$hour:$minute:$second',
          style:
              widget.style ??
              Theme.of(context).textTheme.displayMedium?.copyWith(
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
        ),
        Text(
          'Hora Local',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
