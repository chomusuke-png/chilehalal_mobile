import 'package:flutter/material.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner,
              size: 100,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Apunte la cámara a un código de barras',
              style: TextStyle(
                fontSize: 18,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: 250,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.secondary, width: 3),
                borderRadius: BorderRadius.circular(10),
                color: Colors.black.withValues(alpha: 0.1),
              ),
              child: const Center(
                child: Text(
                  'Cámara (Próximamente)',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}