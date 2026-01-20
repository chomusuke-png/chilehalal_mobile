import 'package:flutter/material.dart';
import 'package:chilehalal_mobile/widgets/scanner/scanner_widget.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  String? _lastScannedCode;

  void _handleCodeDetected(String code) {
    setState(() {
      _lastScannedCode = code;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Código detectado: $code')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _lastScannedCode == null 
                    ? 'Apunte la cámara a un código' 
                    : 'Último código: $_lastScannedCode',
                style: TextStyle(
                  fontSize: 18,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ScannerWidget(
                  onDetect: _handleCodeDetected,
                ),
              ),
              
              const SizedBox(height: 20),
              Text(
                'Buscando productos Halal...',
                style: TextStyle(
                  color: colorScheme.secondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}