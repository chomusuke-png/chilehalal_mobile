import 'dart:async';
import 'dart:convert';
import 'package:chilehalal_mobile/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PrayerCountdown extends StatefulWidget {
  final TextStyle? style;

  const PrayerCountdown({super.key, this.style});

  @override
  State<PrayerCountdown> createState() => _PrayerCountdownState();
}

class _PrayerCountdownState extends State<PrayerCountdown> {
  Timer? _timer;
  Map<String, String>? _prayerTimes;
  
  String _nextPrayerName = 'Cargando...';
  DateTime? _targetPrayerTime;
  Duration _timeRemaining = Duration.zero;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchPrayerTimes() async {
    const String apiUrl = "https://api.aladhan.com/v1/timingsByCity?city=Santiago&country=Chile&method=3";
    
    try {
      final response = await http.get(Uri.parse(apiUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];

        if (mounted) {
          setState(() {
            _prayerTimes = {
              "Fajr": timings['Fajr'],
              "Dhuhr": timings['Dhuhr'],
              "Asr": timings['Asr'],
              "Maghrib": timings['Maghrib'],
              "Isha": timings['Isha'],
            };
            _isLoading = false;
          });
          
          _calculateNextPrayer();
          _scheduleDailyNotifications();
          _startCountdown();
        }
      } else {
        _handleError();
      }
    } catch (e) {
      _handleError();
    }
  }

  void _scheduleDailyNotifications() {
    if (_prayerTimes == null) return;
    
    final now = DateTime.now();
    final orderedKeys = const ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];
    
    NotificationService().cancelAllNotifications();

    int notificationId = 100;
    
    for (var key in orderedKeys) {
      final timeStr = _prayerTimes![key]!;
      final prayerDate = _parseTime(timeStr, now);

      if (prayerDate.isAfter(now)) {
        NotificationService().scheduleNotification(
          id: notificationId,
          title: 'Hora de Oración: $key',
          body: 'Es el momento de la oración de $key.',
          scheduledTime: prayerDate,
        );
      }
      notificationId++;
    }
  }

  void _handleError() {
    if (mounted) {
      setState(() {
        _hasError = true;
        _isLoading = false;
        _nextPrayerName = "Error de conexión";
      });
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_targetPrayerTime == null) return;

      final now = DateTime.now();
      
      if (now.isAfter(_targetPrayerTime!)) {
        _calculateNextPrayer();
      } else {
        if (mounted) {
          setState(() {
            _timeRemaining = _targetPrayerTime!.difference(now);
          });
        }
      }
    });
  }

  void _calculateNextPrayer() {
    if (_prayerTimes == null) return;

    final now = DateTime.now();
    final orderedKeys = const ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];

    for (var key in orderedKeys) {
      final timeStr = _prayerTimes![key]!;
      final prayerDate = _parseTime(timeStr, now);

      if (prayerDate.isAfter(now)) {
        _targetPrayerTime = prayerDate;
        _nextPrayerName = key;
        
        if (mounted) {
          setState(() {
            _timeRemaining = _targetPrayerTime!.difference(now);
          });
        }
        return; 
      }
    }

    final fajrToday = _parseTime(_prayerTimes!["Fajr"]!, now);
    _targetPrayerTime = fajrToday.add(const Duration(days: 1));
    _nextPrayerName = "Fajr";
    
    if (mounted) {
      setState(() {
        _timeRemaining = _targetPrayerTime!.difference(now);
      });
    }
  }

  DateTime _parseTime(String timeString, DateTime now) {
    final cleanTime = timeString.split(' ')[0]; 
    final parts = cleanTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const SizedBox(
        height: 50, 
        width: 50, 
        child: CircularProgressIndicator()
      );
    }

    if (_hasError) {
      return Text(
        "No se pudo cargar",
        style: TextStyle(color: colorScheme.error),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Próxima oración: $_nextPrayerName',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 5),
        Text(
          _formatDuration(_timeRemaining),
          style: widget.style ??
              Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
        ),
        Text(
          'tiempo restante',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.outline,
              ),
        ),
      ],
    );
  }
}