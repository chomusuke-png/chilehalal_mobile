import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:chilehalal_mobile/services/inbox_service.dart';
import 'package:chilehalal_mobile/services/auth_service.dart';
import 'package:chilehalal_mobile/screens/admin/send_broadcast_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final InboxService _inboxService = InboxService();
  final AuthService _authService = AuthService();
  
  bool _isLoading = true;
  bool _isOwner = false;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await Future.wait([
      _checkUserRole(),
      _loadNotifications(),
    ]);
  }

  Future<void> _checkUserRole() async {
    final role = await _authService.getRole();
    if (mounted) {
      setState(() {
        _isOwner = (role == 'owner');
      });
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final inboxMessages = await _inboxService.getMessages();
      if (mounted) {
        setState(() {
          _notifications = inboxMessages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar la bandeja de entrada')),
        );
      }
    }
  }

  Future<void> _deleteNotification(String id) async {
    try {
      await _inboxService.deleteMessage(id);
      await _loadNotifications();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notificación eliminada'), duration: Duration(seconds: 2)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar la notificación')),
        );
      }
    }
  }

  Future<void> _clearAll() async {
    try {
      await _inboxService.clearAll();
      await _loadNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al limpiar la bandeja')),
        );
      }
    }
  }

  Future<void> _navigateToBroadcastScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SendBroadcastScreen(),
      ),
    );
    
    _loadNotifications();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _loadNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Bandeja de Entrada'),
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
        actions: [
          if (_isOwner)
            IconButton(
              icon: Icon(Icons.campaign, color: colorScheme.primary),
              tooltip: 'Notificación Global',
              onPressed: _navigateToBroadcastScreen,
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
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              color: colorScheme.primary,
              child: _notifications.isEmpty
                  ? _buildEmptyState(colorScheme)
                  : _buildList(colorScheme),
            ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Stack(
      children: [
        ListView(physics: const AlwaysScrollableScrollPhysics()),
        Center(
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
        ),
      ],
    );
  }

  Widget _buildList(ColorScheme colorScheme) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final notificationItem = _notifications[index];
        final date = DateTime.parse(notificationItem['date']);
        final formattedDate = "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";

        return Dismissible(
          key: Key(notificationItem['id']),
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
          onDismissed: (direction) => _deleteNotification(notificationItem['id']),
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
                        notificationItem['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notificationItem['body'],
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