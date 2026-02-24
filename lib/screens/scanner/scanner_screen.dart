import 'package:flutter/material.dart';
import 'package:chilehalal_mobile/widgets/scanner/scanner_widget.dart';
import 'package:chilehalal_mobile/screens/product/product_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isProcessing = false;
  
  final GlobalKey<ScannerWidgetState> _scannerKey = GlobalKey<ScannerWidgetState>();

  void _handleCodeDetected(String code) {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    
    _scannerKey.currentState?.pauseScanner();

    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => ProductScreen(barcode: code),
      ),
    ).then((_) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _scannerKey.currentState?.resumeScanner();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Escanear Producto',
                  style: TextStyle(
                    fontSize: 24,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Coloca el código de barras en el cuadro'),
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
                    key: _scannerKey,
                    onDetect: _handleCodeDetected,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                SizedBox(
                  height: 40,
                  child: _isProcessing
                      ? const CircularProgressIndicator()
                      : Text(
                          'Buscando producto...',
                          style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.w500),
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