import 'package:flutter/material.dart';
import 'package:chilehalal_mobile/services/admin_service.dart';

class SendBroadcastScreen extends StatefulWidget {
  const SendBroadcastScreen({super.key});

  @override
  State<SendBroadcastScreen> createState() => _SendBroadcastScreenState();
}

class _SendBroadcastScreenState extends State<SendBroadcastScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text('Confirmar Envío'),
          ],
        ),
        content: const Text(
          '¿Estás seguro que deseas enviar esta notificación a TODOS los usuarios de la aplicación?\n\nEsta acción es inmediata y no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, enviar a todos', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSending = true);

    final result = await AdminService().sendGlobalNotification(
      _titleController.text.trim(),
      _messageController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSending = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );

      if (result['success']) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Notificación Global'),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Atención: Esta notificación será enviada de forma inmediata a todos los usuarios registrados que tengan la aplicación instalada.',
                          style: TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                const Text('Título de la Notificación', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Ej: ¡Nueva actualización!',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  maxLength: 50,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El título es obligatorio';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                const Text('Cuerpo del Mensaje', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Escribe el detalle del mensaje aquí...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  maxLength: 250,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El mensaje es obligatorio';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 40),
                
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSending ? null : _handleSendNotification,
                    icon: _isSending 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send),
                    label: Text(
                      _isSending ? 'Enviando...' : 'Enviar a todos',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
}