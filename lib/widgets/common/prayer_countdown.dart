import 'dart:async';
import 'dart:convert';
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
  Map<String, String>? _prayerTimes; // Almacena los horarios crudos (HH:mm)
  
  String _nextPrayerName = 'Cargando...';
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

  /// 1. Consumir la API
  Future<void> _fetchPrayerTimes() async {
    const String apiUrl = "https://api.aladhan.com/v1/timingsByCity?city=Santiago&country=Chile&method=3";
    
    try {
      final response = await http.get(Uri.parse(apiUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];

        if (mounted) {
          setState(() {
            // Guardamos solo los rezos obligatorios
            _prayerTimes = {
              "Fajr": timings['Fajr'],
              "Dhuhr": timings['Dhuhr'],
              "Asr": timings['Asr'],
              "Maghrib": timings['Maghrib'],
              "Isha": timings['Isha'],
            };
            _isLoading = false;
          });
          // Iniciamos el reloj
          _startCountdown();
        }
      } else {
        _handleError();
      }
    } catch (e) {
      _handleError();
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

  /// 2. Lógica del Temporizador
  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateNextPrayer();
    });
    // Ejecutar inmediatamente la primera vez
    _calculateNextPrayer();
  }

  /// 3. Calcular cuál es el siguiente rezo y cuánto falta
  void _calculateNextPrayer() {
    if (_prayerTimes == null) return;

    final now = DateTime.now();
    DateTime? upcomingPrayerTime;
    String upcomingName = "";

    // Iteramos los rezos para buscar el primero que sea > ahora
    // El orden del mapa es importante, pero al iterar entries suele respetarse la inserción o usamos una lista definida
    final orderedKeys = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];

    for (var key in orderedKeys) {
      final timeStr = _prayerTimes![key]!; // "HH:mm"
      final prayerDate = _parseTime(timeStr, now);

      if (prayerDate.isAfter(now)) {
        upcomingPrayerTime = prayerDate;
        upcomingName = key;
        break; 
      }
    }

    // Si no encontramos ninguno (ej: son las 23:00 y el último fue Isha a las 21:30)
    // Entonces el siguiente es Fajr de MAÑANA.
    if (upcomingPrayerTime == null) {
      upcomingName = "Fajr";
      final fajrToday = _parseTime(_prayerTimes!["Fajr"]!, now);
      upcomingPrayerTime = fajrToday.add(const Duration(days: 1));
    }

    if (mounted) {
      setState(() {
        _nextPrayerName = upcomingName;
        _timeRemaining = upcomingPrayerTime!.difference(now);
      });
    }
  }

  /// Helper para convertir "18:43" string a un DateTime de HOY
  DateTime _parseTime(String timeString, DateTime now) {
    // La API a veces devuelve "05:43 (CLT)", limpiamos por si acaso
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
        // Texto pequeño arriba
        Text(
          'Próxima oración: $_nextPrayerName',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 5),
        // Reloj grande
        Text(
          _formatDuration(_timeRemaining),
          style: widget.style ??
              Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFeatures: [const FontFeature.tabularFigures()], // Evita saltos visuales
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