import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:chilehalal_mobile/services/inbox_service.dart';
import 'package:chilehalal_mobile/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final InboxService _inboxService = InboxService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final msgs = await _inboxService.getMessages();
    if (mounted) {
      setState(() {
        _notifications = msgs;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteNotification(String id) async {
    await _inboxService.deleteMessage(id);
    _loadNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notificación eliminada'), duration: Duration(seconds: 2)),
      );
    }
  }

  Future<void> _clearAll() async {
    await _inboxService.clearAll();
    _loadNotifications();
  }

  Future<void> _createTestNotification() async {
    const title = '¡Bienvenido a ChileHalal!';
    const body = 'Tu cuenta ha sido configurada correctamente. Gracias por preferirnos.';
    
    await _inboxService.addMessage(title, body);
    
    // 2. Opcional: Mostramos una alerta en el sistema operativo ahora mismo
    // await NotificationService().flutterLocalNotificationsPlugin.show(
    //   999, title, body, const NotificationDetails(android: AndroidNotificationDetails('test', 'Pruebas', importance: Importance.max)),
    // );

    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Bandeja de Entrada', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert),
            tooltip: 'Generar prueba',
            onPressed: _createTestNotification,
          ),
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              tooltip: 'Limpiar todo',
              onPressed: _clearAll,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState(colorScheme)
              : _buildList(colorScheme),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              FontAwesomeIcons.bellSlash,
              size: 60,
              color: colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Bandeja vacía',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No tienes notificaciones recientes.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildList(ColorScheme colorScheme) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final notif = _notifications[index];
        final date = DateTime.parse(notif['date']);
        final formattedDate = "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";

        return Dismissible(
          key: Key(notif['id']),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) => _deleteNotification(notif['id']),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications_active, color: colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notif['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif['body'],
                        style: TextStyle(color: Colors.grey[700], height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formattedDate,
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}