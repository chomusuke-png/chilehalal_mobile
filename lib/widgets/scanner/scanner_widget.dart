import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerWidget extends StatefulWidget {
  final void Function(String code) onDetect;

  const ScannerWidget({
    super.key,
    required this.onDetect,
  });

  @override
  State<ScannerWidget> createState() => _ScannerWidgetState();
}

class _ScannerWidgetState extends State<ScannerWidget> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16), // Bordes redondeados para que se vea moderno
      child: Stack(
        children: [
          // 1. La cámara en sí
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  widget.onDetect(barcode.rawValue!);
                  break; // Solo procesamos el primero que encuentre
                }
              }
            },
          ),
          
          // 2. Un overlay visual (opcional) para guiar al usuario
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          
          // 3. Icono de escaneo al centro
          Center(
            child: Icon(
              Icons.qr_code_scanner,
              color: Colors.white.withValues(alpha: 0.3),
              size: 80,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}