import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:chilehalal_mobile/services/prayer_service.dart';
import 'package:chilehalal_mobile/widgets/common/prayer_countdown.dart'; 

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  Widget _buildPrayerTile(String title, String time, IconData icon, Color iconColor, bool isNext) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isNext ? colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (isNext)
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
          border: isNext ? null : Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isNext ? 6 : 0,
                  color: Colors.yellow[600], 
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isNext ? Colors.white : iconColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: FaIcon(
                            icon, 
                            color: iconColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                            color: isNext ? Colors.white : Colors.black87,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900, 
                            color: isNext ? Colors.white : Colors.black87,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface, 
      appBar: AppBar(
        title: const Text('Horario de Oraciones'),
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: IconButton(
              icon: Icon(Icons.my_location, color: colorScheme.primary, size: 20),
              tooltip: 'Actualizar ubicación',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                _checkGpsAndLoad(forceRefresh: true);
              },
            ),
          ),
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
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _checkGpsAndLoad(forceRefresh: true), 
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar')
                      )
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _checkGpsAndLoad(forceRefresh: true),
                  color: colorScheme.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(), 
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100), 
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(color: Colors.grey[200]!, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.location_on, color: colorScheme.primary, size: 16),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  PrayerService().currentCity,
                                  style: const TextStyle(
                                    fontSize: 15, 
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        const AbsorbPointer(
                          absorbing: true, 
                          child: PrayerCountdown(),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                          child: Text(
                            'Horarios del día',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        
                        _buildPrayerTile('Fajr', _prayerTimes!['Fajr']!, FontAwesomeIcons.cloudMoon, Colors.indigo[400]!, _nextPrayer == 'Fajr'),
                        _buildPrayerTile('Amanecer', _prayerTimes!['Sunrise']!, FontAwesomeIcons.sun, Colors.orange[400]!, _nextPrayer == 'Sunrise'),
                        _buildPrayerTile('Dhuhr', _prayerTimes!['Dhuhr']!, FontAwesomeIcons.solidSun, Colors.amber[500]!, _nextPrayer == 'Dhuhr'),
                        _buildPrayerTile('Asr', _prayerTimes!['Asr']!, FontAwesomeIcons.cloudSun, Colors.deepOrange[400]!, _nextPrayer == 'Asr'),
                        _buildPrayerTile('Maghrib', _prayerTimes!['Maghrib']!, FontAwesomeIcons.solidMoon, Colors.purple[400]!, _nextPrayer == 'Maghrib'),
                        _buildPrayerTile('Isha', _prayerTimes!['Isha']!, FontAwesomeIcons.moon, Colors.blue[800]!, _nextPrayer == 'Isha'),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
    );
  }
}