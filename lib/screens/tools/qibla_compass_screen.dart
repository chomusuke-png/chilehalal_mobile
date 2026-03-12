import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:chilehalal_mobile/services/qibla_service.dart';

class QiblaCompassScreen extends StatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends State<QiblaCompassScreen> {
  final QiblaService _qiblaService = QiblaService();
  
  double? _qiblaDirection;
  double? _currentHeading;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    _initQibla();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initQibla() async {
    try {
      final CompassEvent tmp = await FlutterCompass.events!.first;
      if (tmp.heading == null) {
        throw Exception('El dispositivo no tiene sensor magnético.');
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Activa el GPS para calcular la Qibla.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permiso de ubicación denegado.');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);

      final direction = await _qiblaService.getQiblaDirection(
          position.latitude, position.longitude);

      if (direction == null) throw Exception('No se pudo conectar con el servidor.');

      if (mounted) {
        setState(() {
          _qiblaDirection = direction;
          _isLoading = false;
        });

        _compassSubscription = FlutterCompass.events!.listen((event) {
          if (mounted) {
            setState(() {
              _currentHeading = event.heading;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Brújula Qibla', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFF1E293B),
              Color(0xFF0F172A),
            ],
            center: Alignment.center,
            radius: 1.2,
          ),
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text('Calculando dirección...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FaIcon(FontAwesomeIcons.solidFaceFrown, size: 60, color: Colors.white54),
              const SizedBox(height: 24),
              Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4)),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  setState(() { _isLoading = true; _hasError = false; });
                  _initQibla();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      );
    }

    if (_currentHeading == null || _qiblaDirection == null) {
      return const Center(child: Text('Calibrando sensor...', style: TextStyle(color: Colors.white)));
    }

    double diff = (_qiblaDirection! - _currentHeading!).abs();
    if (diff > 180) diff = 360 - diff;
    final bool isAligned = diff < 4.0;

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isAligned ? Colors.green.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: isAligned ? Colors.greenAccent : Colors.white24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  isAligned ? FontAwesomeIcons.solidCircleCheck : FontAwesomeIcons.compass, 
                  size: 18, 
                  color: isAligned ? Colors.greenAccent : Colors.white70
                ),
                const SizedBox(width: 10),
                Text(
                  isAligned ? '¡Alineado con La Meca!' : 'Gira hasta alinear la flecha',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isAligned ? Colors.greenAccent : Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),

          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))
                    ]
                  ),
                ),

                AnimatedRotation(
                  turns: (_currentHeading! * -1) / 360,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: _buildCompassDial(),
                ),

                AnimatedRotation(
                  turns: (_qiblaDirection! - _currentHeading!) / 360,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: _buildQiblaNeedle(isAligned),
                ),
                
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFF94A3B8),
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.white, Color(0xFF475569)],
                      center: Alignment(-0.3, -0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
            child: Text(
              'Qibla: ${_qiblaDirection!.toStringAsFixed(0)}°  |  Teléfono: ${_currentHeading!.toStringAsFixed(0)}°',
              style: const TextStyle(color: Colors.white70, fontFamily: 'monospace', fontSize: 13),
            ),
          ),
          
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 50.0),
            child: Text(
              'Coloque el teléfono en posición horizontal y lejos de objetos metálicos o electrónicos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.4),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildCompassDial() {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF334155), Color(0xFF1E293B)],
        ),
        border: Border.all(color: const Color(0xFF475569), width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: -2, offset: Offset(0, 5)),
        ]
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(300, 300),
            painter: CompassTicksPainter(),
          ),
          _buildCardinalText('N', const Color(0xFFEF4444), top: 20),
          _buildCardinalText('S', Colors.white70, bottom: 20),
          _buildCardinalText('E', Colors.white70, right: 28),
          _buildCardinalText('O', Colors.white70, left: 28),
        ],
      ),
    );
  }

  Widget _buildCardinalText(String text, Color color, {double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: text == 'N' ? 24 : 20,
          fontWeight: FontWeight.w900,
          fontFamily: 'serif',
        ),
      ),
    );
  }

  Widget _buildQiblaNeedle(bool isAligned) {
    final Color accentColor = isAligned ? Colors.greenAccent : const Color(0xFFFBBF24);
    
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: isAligned ? 0.7 : 0.4),
                blurRadius: isAligned ? 25 : 15,
                spreadRadius: isAligned ? 5 : 0,
              )
            ]
          ),
        ),

        SizedBox(
          width: 200,
          height: 200,
          child: Center(
            child: Container(
              width: 10,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    accentColor,
                    accentColor.withValues(alpha: 0.1),
                  ],
                  stops: const [0.6, 1.0],
                ),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),

        Positioned(
          top: 0,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              shape: BoxShape.circle,
              border: Border.all(color: accentColor, width: 2),
            ),
            child: FaIcon(
              FontAwesomeIcons.kaaba,
              size: 28,
              color: accentColor,
            ),
          ),
        ),
      ],
    );
  }
}

class CompassTicksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 72; i++) {
      final angle = i * 5 * (math.pi / 180);
      
      final isMajor = (i * 5) % 15 == 0;
      final tickLength = isMajor ? 12.0 : 6.0;
      paint.strokeWidth = isMajor ? 2.0 : 1.0;
      paint.color = isMajor ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8).withValues(alpha: 0.4);

      final start = Offset(
        center.dx + (radius - 10 - tickLength) * math.cos(angle),
        center.dy + (radius - 10 - tickLength) * math.sin(angle),
      );
      final end = Offset(
        center.dx + (radius - 15) * math.cos(angle),
        center.dy + (radius - 15) * math.sin(angle),
      );

      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}