import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chilehalal_mobile/services/notification_service.dart';
import 'package:chilehalal_mobile/services/prayer_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _prayerNotifKey = 'ch_pref_prayer_notifications';
  bool _prayerNotificationsEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _prayerNotificationsEnabled = prefs.getBool(_prayerNotifKey) ?? true;
        _isLoading = false;
      });
    }
  }

  Future<void> _togglePrayerNotifications(bool value) async {
    setState(() {
      _prayerNotificationsEnabled = value;
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prayerNotifKey, value);

    if (value) {
      await PrayerService().getPrayerTimes(forceRefresh: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notificaciones de oración activadas.')),
        );
      }
    } else {
      await NotificationService().cancelAllNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notificaciones de oración desactivadas.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Ajustes'),
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
        backgroundColor: colorScheme.surface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              children: [
                _buildSectionHeader('Notificaciones', colorScheme),
                SwitchListTile(
                  activeThumbColor: colorScheme.primary,
                  secondary: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.access_time_filled, color: colorScheme.primary, size: 22),
                  ),
                  title: const Text(
                    'Horarios de Oración',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  subtitle: Text(
                    'Recibir avisos locales diarios para los horarios de rezo (Salat).',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  value: _prayerNotificationsEnabled,
                  onChanged: _togglePrayerNotifications,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Divider(height: 30),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}