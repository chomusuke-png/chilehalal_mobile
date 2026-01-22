import 'package:flutter/material.dart';
import 'package:chilehalal_mobile/widgets/scanner/scanner_widget.dart';
import 'package:chilehalal_mobile/screens/product/product_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isProcessing = false; // Candado para evitar múltiples navegaciones

  void _handleCodeDetected(String code) {
    if (_isProcessing) return; // Si ya estamos procesando, ignoramos

    setState(() => _isProcessing = true);

    // Navegamos a la pantalla de detalle
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductScreen(barcode: code),
      ),
    ).then((_) {
      // Cuando el usuario vuelva (haga "Atrás"), desbloqueamos para escanear de nuevo
      setState(() => _isProcessing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: SingleChildScrollView( // Para evitar overflow en pantallas chicas
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
              
              // Contenedor de la cámara
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
                // Pasamos nuestra función protegida al widget
                child: ScannerWidget(
                  onDetect: _handleCodeDetected,
                ),
              ),
              
              const SizedBox(height: 30),
              
              if (_isProcessing)
                const CircularProgressIndicator()
              else
                Text(
                  'Buscando productos Halal...',
                  style: TextStyle(color: colorScheme.secondary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}