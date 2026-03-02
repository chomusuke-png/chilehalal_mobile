import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:chilehalal_mobile/services/notification_service.dart';

class PrayerService {
  static final PrayerService _instance = PrayerService._internal();
  factory PrayerService() => _instance;
  PrayerService._internal();

  Map<String, String>? _cachedPrayerTimes;
  
  String currentCity = "Santiago, Chile"; 

  Future<Map<String, String>?> getPrayerTimes({bool forceRefresh = false}) async {
    if (_cachedPrayerTimes != null && !forceRefresh) {
      return _cachedPrayerTimes;
    }

    double lat = -33.4489; 
    double lng = -70.6693;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
          );
          
          lat = position.latitude;
          lng = position.longitude;

          try {
            List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
            if (placemarks.isNotEmpty) {
              final place = placemarks.first;
              final city = place.locality ?? place.subAdministrativeArea ?? "Ciudad desconocida";
              final country = place.country ?? "";
              currentCity = "$city, $country";
            }
          } catch (e) {
            currentCity = "Ubicación actual";
          }
        }
      }
    } catch (e) {
      // e
    }

    final String apiUrl = "https://api.aladhan.com/v1/timings?latitude=$lat&longitude=$lng&method=3";
    
    try {
      final response = await http.get(Uri.parse(apiUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];

        _cachedPrayerTimes = {
          "Fajr": timings['Fajr'],
          "Sunrise": timings['Sunrise'],
          "Dhuhr": timings['Dhuhr'],
          "Asr": timings['Asr'],
          "Maghrib": timings['Maghrib'],
          "Isha": timings['Isha'],
        };
        
        await _scheduleDailyNotifications(_cachedPrayerTimes!);
        
        return _cachedPrayerTimes;
      }
    } catch (e) {
      // e
    }
    return null;
  }

  Future<void> _scheduleDailyNotifications(Map<String, String> prayerTimes) async {
    final now = DateTime.now();
    final orderedKeys = const ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];
    
    await NotificationService().cancelAllNotifications();

    int notificationId = 100;
    
    for (var key in orderedKeys) {
      final timeStr = prayerTimes[key]!;
      DateTime prayerDate = _parseTime(timeStr, now);

      if (prayerDate.isBefore(now)) {
        prayerDate = prayerDate.add(const Duration(days: 1));
      }

      await NotificationService().scheduleNotification(
        id: notificationId,
        title: 'Hora de Oración: $key',
        body: 'Es el momento de la oración de $key.',
        scheduledTime: prayerDate,
      );
      
      notificationId++;
    }
  }

  DateTime _parseTime(String timeString, DateTime now) {
    final cleanTime = timeString.split(' ')[0]; 
    final parts = cleanTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}