import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chilehalal_mobile/services/notification_service.dart';

class PrayerService {
  static final PrayerService _instance = PrayerService._internal();
  factory PrayerService() => _instance;
  PrayerService._internal();

  Map<String, String>? _cachedPrayerTimes;

  Future<Map<String, String>?> getPrayerTimes({bool forceRefresh = false}) async {
    if (_cachedPrayerTimes != null && !forceRefresh) {
      return _cachedPrayerTimes;
    }

    const String apiUrl = "https://api.aladhan.com/v1/timingsByCity?city=Santiago&country=Chile&method=3";
    
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
        
        _scheduleDailyNotifications(_cachedPrayerTimes!);
        
        return _cachedPrayerTimes;
      }
    } catch (e) {
      // null
    }
    return null;
  }

  void _scheduleDailyNotifications(Map<String, String> prayerTimes) {
    final now = DateTime.now();
    final orderedKeys = const ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];
    
    NotificationService().cancelAllNotifications();

    int notificationId = 100;
    
    for (var key in orderedKeys) {
      final timeStr = prayerTimes[key]!;
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

  DateTime _parseTime(String timeString, DateTime now) {
    final cleanTime = timeString.split(' ')[0]; 
    final parts = cleanTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}