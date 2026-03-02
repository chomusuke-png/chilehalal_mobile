import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:chilehalal_mobile/services/prayer_service.dart';

class PrayerScheduleScreen extends StatefulWidget {
  const PrayerScheduleScreen({super.key});

  @override
  State<PrayerScheduleScreen> createState() => _PrayerScheduleScreenState();
}

class _PrayerScheduleScreenState extends State<PrayerScheduleScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  Map<String, String>? _prayerTimes;
  String _nextPrayer = '';

  @override
  void initState() {
    super.initState();
    _checkGpsAndLoad();
  }

  Future<void> _checkGpsAndLoad({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    
    if (!serviceEnabled && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('GPS desactivado. Usando ubicación por defecto (Santiago).'),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'AJUSTES',
            textColor: Colors.white,
            onPressed: () {
              Geolocator.openLocationSettings();
            },
          ),
        ),
      );
    }

    final times = await PrayerService().getPrayerTimes(forceRefresh: forceRefresh);
    
    if (mounted) {
      if (times != null) {
        setState(() {
          _prayerTimes = times;
          _isLoading = false;
          _calculateNextPrayer();
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  void _calculateNextPrayer() {
    if (_prayerTimes == null) return;
    final now = DateTime.now();
    final orderedKeys = const ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"];

    for (var key in orderedKeys) {
      final timeStr = _prayerTimes![key]!;
      final prayerDate = _parseTime(timeStr, now);

      if (prayerDate.isAfter(now)) {
        _nextPrayer = key;
        return;
      }
    }
    _nextPrayer = "Fajr";
  }

  DateTime _parseTime(String timeString, DateTime now) {
    final cleanTime = timeString.split(' ')[0];
    final parts = cleanTime.split(':');
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  Widget _buildPrayerTile(String title, String time, IconData icon, bool isNext) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: isNext ? colorScheme.primary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: isNext ? null : Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          FaIcon(
            icon, 
            color: isNext ? Colors.white : colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
              color: isNext ? Colors.white : Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            time,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isNext ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Horario de Oraciones', style: TextStyle(fontWeight: FontWeight.bold)),
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Actualizar ubicación',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              
              _checkGpsAndLoad(forceRefresh: true);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('Error de conexión', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
                      TextButton(
                        onPressed: () => _checkGpsAndLoad(forceRefresh: true), 
                        child: const Text('Reintentar')
                      )
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, color: colorScheme.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                PrayerService().currentCity,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      _buildPrayerTile('Fajr', _prayerTimes!['Fajr']!, FontAwesomeIcons.cloudMoon, _nextPrayer == 'Fajr'),
                      _buildPrayerTile('Amanecer (Sunrise)', _prayerTimes!['Sunrise']!, FontAwesomeIcons.sun, _nextPrayer == 'Sunrise'),
                      _buildPrayerTile('Dhuhr', _prayerTimes!['Dhuhr']!, FontAwesomeIcons.solidSun, _nextPrayer == 'Dhuhr'),
                      _buildPrayerTile('Asr', _prayerTimes!['Asr']!, FontAwesomeIcons.cloudSun, _nextPrayer == 'Asr'),
                      _buildPrayerTile('Maghrib', _prayerTimes!['Maghrib']!, FontAwesomeIcons.solidMoon, _nextPrayer == 'Maghrib'),
                      _buildPrayerTile('Isha', _prayerTimes!['Isha']!, FontAwesomeIcons.moon, _nextPrayer == 'Isha'),
                    ],
                  ),
                ),
    );
  }
}