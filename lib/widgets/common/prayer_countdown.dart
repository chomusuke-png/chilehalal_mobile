import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:chilehalal_mobile/services/prayer_service.dart';
import 'package:chilehalal_mobile/screens/tools/prayer_schedule_screen.dart';

class PrayerCountdown extends StatefulWidget {
  final TextStyle? style;

  const PrayerCountdown({super.key, this.style});

  @override
  State<PrayerCountdown> createState() => _PrayerCountdownState();
}

class _PrayerCountdownState extends State<PrayerCountdown> with SingleTickerProviderStateMixin {
  Timer? _timer;
  Map<String, String>? _prayerTimes;
  
  String _nextPrayerName = 'Cargando...';
  DateTime? _targetPrayerTime;
  Duration _timeRemaining = Duration.zero;
  bool _isLoading = true;
  bool _hasError = false;

  // Animación para el movimiento suave del astro
  late AnimationController _animationController;
  late Animation<double> _posAnimation;
  double _currentSunMoonPosition = 0.0; // 0.0 Amanecer, 1.0 Atardecer

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _posAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_animationController);
    _loadPrayerTimes();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPrayerTimes() async {
    final times = await PrayerService().getPrayerTimes();
    
    if (times != null) {
      if (mounted) {
        setState(() {
          _prayerTimes = times;
          _isLoading = false;
        });
        _calculateNextPrayerAndPosition(animate: false);
        _startCountdown();
      }
    } else {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _nextPrayerName = "Error de conexión";
        });
      }
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_targetPrayerTime == null) return;
      final now = DateTime.now();
      if (now.isAfter(_targetPrayerTime!)) {
        _calculateNextPrayerAndPosition(animate: true);
      } else {
        if (mounted) {
          setState(() {
            _timeRemaining = _targetPrayerTime!.difference(now);
          });
        }
      }
    });
  }

  void _calculateNextPrayerAndPosition({required bool animate}) {
    if (_prayerTimes == null) return;
    final now = DateTime.now();
    final orderedKeys = const ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];

    bool found = false;
    for (var key in orderedKeys) {
      final timeStr = _prayerTimes![key]!;
      final prayerDate = _parseTime(timeStr, now);
      if (prayerDate.isAfter(now)) {
        _targetPrayerTime = prayerDate;
        _nextPrayerName = key;
        found = true;
        break; 
      }
    }

    if (!found) {
      final fajrToday = _parseTime(_prayerTimes!["Fajr"]!, now);
      _targetPrayerTime = fajrToday.add(const Duration(days: 1));
      _nextPrayerName = "Fajr";
    }

    // Calcular posición visual (0.0 a 1.0)
    final sunrise = _parseTime(_prayerTimes!["Sunrise"]!, now);
    final maghrib = _parseTime(_prayerTimes!["Maghrib"]!, now);
    double newPosition;

    if (now.isAfter(sunrise) && now.isBefore(maghrib)) {
      final totalDayMinutes = maghrib.difference(sunrise).inMinutes;
      final currentDayMinutes = now.difference(sunrise).inMinutes;
      newPosition = (currentDayMinutes / totalDayMinutes).clamp(0.0, 1.0);
    } else {
      DateTime nextSunrise = sunrise.isBefore(now) ? sunrise.add(const Duration(days: 1)) : sunrise;
      DateTime lastMaghrib = maghrib.isAfter(now) ? maghrib.subtract(const Duration(days: 1)) : maghrib;
      final totalNightMinutes = nextSunrise.difference(lastMaghrib).inMinutes;
      final currentNightMinutes = now.difference(lastMaghrib).inMinutes;
      newPosition = (currentNightMinutes / totalNightMinutes).clamp(0.0, 1.0);
    }

    if (mounted) {
      setState(() {
        _timeRemaining = _targetPrayerTime!.difference(now);
        if (!animate) _currentSunMoonPosition = newPosition;
      });
    }

    if (animate) {
      _posAnimation = Tween<double>(
        begin: _currentSunMoonPosition,
        end: newPosition,
      ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
      _animationController.forward(from: 0.0).then((_) {
         if (mounted) setState(() => _currentSunMoonPosition = newPosition);
      });
    }
  }

  // Corrección de parseo (Hour: 0, Minute: 1)
  DateTime _parseTime(String timeString, DateTime now) {
    final cleanTime = timeString.split(' ')[0]; 
    final parts = cleanTime.split(':');
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  bool _isDaytime() {
    if (_prayerTimes == null) return true;
    final now = DateTime.now();
    final sunrise = _parseTime(_prayerTimes!["Sunrise"]!, now);
    final maghrib = _parseTime(_prayerTimes!["Maghrib"]!, now);
    return now.isAfter(sunrise) && now.isBefore(maghrib);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDay = _isDaytime();

    if (_isLoading) return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()));
    if (_hasError) return Text("Error", style: TextStyle(color: colorScheme.error));

    // Definimos medidas para cálculos de posición
    const double widgetHeight = 110;
    const double astroIconSize = 40.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerScheduleScreen())),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(seconds: 1),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDay 
                ? [Colors.lightBlue[300]!, Colors.lightBlue[100]!] // Día
                : [const Color(0xFF10154D), const Color(0xFF283593)], // Noche
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- ÁREA DEL HORIZONTE ANIMADO (STACK) ---
              SizedBox(
                height: widgetHeight,
                width: double.infinity,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double w = constraints.maxWidth;
                    final double h = constraints.maxHeight;
                    
                    // Definimos el centro de giro y radio matemáticamente
                    final Offset arcCenter = Offset(w / 2, h * 1.5); // Centro abajo
                    final double arcRadius = w * 0.40;

                    // Calculamos la posición del astro en el arco
                    final double posValue = _animationController.isAnimating ? _posAnimation.value : _currentSunMoonPosition;
                    final double angle = math.pi - (posValue * math.pi); // PI (izq) a 0 (der)
                    
                    final double astroX = arcCenter.dx + arcRadius * math.cos(angle);
                    final double astroY = arcCenter.dy - arcRadius * math.sin(angle);

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 1. El arco guía (horizonte)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _HorizonArcPainter(isDay: isDay),
                          ),
                        ),

                        // 2. Las Nubes (Solo de día, estáticas pero lindas)
                        if (isDay) ...[
                          _buildCloud(top: 10, left: w * 0.15, size: 35, opacity: 0.8),
                          _buildCloud(top: 35, right: w * 0.10, size: 25, opacity: 0.6),
                          _buildCloud(bottom: 15, left: w * 0.55, size: 30, opacity: 0.5),
                        ],
                        
                        // 3. Estrellas (Solo de noche, estáticas)
                        if (!isDay) ...[
                          _buildStar(top: 15, left: w * 0.2),
                          _buildStar(top: 40, right: w * 0.3),
                          _buildStar(top: 10, right: w * 0.6),
                        ],

                        // 4. El Astro (Sol o Luna) - ICONO ANIMADO
                        Positioned(
                          // Ajustamos X e Y para centrar el ícono
                          left: astroX - (astroIconSize / 2),
                          top: astroY - (astroIconSize / 2),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (isDay ? Colors.yellow : Colors.white).withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                            child: FaIcon(
                              isDay ? FontAwesomeIcons.solidSun : FontAwesomeIcons.solidMoon,
                              color: isDay ? Colors.yellow[600] : const Color(0xFFEEEEEE),
                              size: astroIconSize,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              
              // --- EL CONTADOR TEXTUAL ---
              Text(
                'Próxima oración: $_nextPrayerName',
                style: TextStyle(
                  color: isDay ? Colors.black87 : Colors.white, 
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _formatDuration(_timeRemaining),
                style: widget.style ?? TextStyle(
                  fontSize: 48, 
                  fontWeight: FontWeight.w900, 
                  color: isDay ? colorScheme.primary : Colors.white,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  letterSpacing: -1.5,
                ),
              ),
              Text(
                'tiempo restante', 
                style: TextStyle(
                  color: isDay ? Colors.black54 : Colors.white70, 
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper para construir nubes consistentes
  Widget _buildCloud({double? top, double? left, double? right, double? bottom, required double size, required double opacity}) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: FaIcon(
        FontAwesomeIcons.solidCloud,
        color: Colors.white.withValues(alpha: opacity),
        size: size,
      ),
    );
  }
  
  // Helper para construir estrellas consistentes
  Widget _buildStar({required double top, double? left, double? right, double? bottom}) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Icon(
        Icons.star,
        color: Colors.white.withValues(alpha: 0.5),
        size: 8,
      ),
    );
  }
}

// --- EL PINTOR SÓLO DIBUJA EL ARCO DEL HORIZONTE ---
class _HorizonArcPainter extends CustomPainter {
  final bool isDay;

  _HorizonArcPainter({required this.isDay});

  @override
  void paint(Canvas canvas, Size size) {
    // Usamos las mismas matemáticas que el Stack para que coincidan
    final center = Offset(size.width / 2, size.height * 1.5);
    final radius = size.width * 0.40;

    final arcPaint = Paint()
      ..color = isDay ? Colors.black12 : Colors.white24 // Línea tenue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    
    // Dibujamos el arco guía de PI (izquierda) a PI (media vuelta arriba)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius), 
      math.pi, 
      math.pi, 
      false, 
      arcPaint
    );
  }

  @override
  bool shouldRepaint(covariant _HorizonArcPainter oldDelegate) => oldDelegate.isDay != isDay;
}