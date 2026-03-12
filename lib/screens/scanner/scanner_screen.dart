import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:chilehalal_mobile/widgets/scanner/scanner_widget.dart';
import 'package:chilehalal_mobile/screens/catalog/product_screen.dart';
import 'package:chilehalal_mobile/screens/main_wrapper.dart'; 

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isProcessing = false;
  bool _isCameraActive = false;

  void _handleCodeDetected(String code) {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    mainWrapperKey.currentState?.jumpToTab(
      1, 
      screenToPush: ProductScreen(barcode: code),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return VisibilityDetector(
      key: const Key('scanner-screen-visibility'),
      onVisibilityChanged: (visibilityInfo) {
        if (mounted) {
          final isVisible = visibilityInfo.visibleFraction > 0;
          if (_isCameraActive != isVisible) {
            setState(() {
              _isCameraActive = isVisible;
            });
          }
        }
      },
      child: Scaffold(
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
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: _isCameraActive
                        ? ScannerWidget(onDetect: _handleCodeDetected)
                        : const Center(
                            child: Icon(Icons.camera_alt, color: Colors.white54, size: 50),
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
      ),
    );
  }
}