import 'dart:async';
import 'package:flutter/material.dart';

class CouponCard extends StatefulWidget {
  final Map<String, dynamic> coupon;

  const CouponCard({super.key, required this.coupon});

  @override
  State<CouponCard> createState() => _CouponCardState();
}

class _CouponCardState extends State<CouponCard> {
  Timer? _timer;
  Duration _timeLeft = Duration.zero;
  bool _isExpired = false;
  bool _hasExpiry = false;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    if (_hasExpiry && !_isExpired) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _calculateTimeLeft());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _calculateTimeLeft() {
    final expiryStr = widget.coupon['expiry'];
    if (expiryStr == null || expiryStr.toString().isEmpty) {
      _hasExpiry = false;
      return;
    }

    try {
      _hasExpiry = true;
      DateTime parsed = DateTime.parse(expiryStr);
      DateTime expiryDate = DateTime(parsed.year, parsed.month, parsed.day, 23, 59, 59);
      DateTime now = DateTime.now();

      if (now.isAfter(expiryDate)) {
        if (mounted) {
          setState(() {
            _isExpired = true;
            _timeLeft = Duration.zero;
          });
        }
        _timer?.cancel();
      } else {
        if (mounted) {
          setState(() {
            _timeLeft = expiryDate.difference(now);
          });
        }
      }
    } catch (e) {
      _hasExpiry = false;
      _timer?.cancel();
    }
  }

  String _formatDuration(Duration d) {
    if (d.inDays > 1) {
      return "${d.inDays} días";
    } else if (d.inDays == 1) {
      return "1 día y ${d.inHours.remainder(24)}h";
    }
    
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[300]!, style: BorderStyle.solid),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.coupon['discount'] ?? '', 
                  style: const TextStyle(fontWeight: FontWeight.bold)
                )
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.coupon['code'] ?? '',
                  style: TextStyle(fontWeight: FontWeight.w900, color: Colors.orange[900], letterSpacing: 1.5),
                ),
              ),
            ],
          ),
          
          if (_hasExpiry) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.timer_outlined, 
                  size: 14, 
                  color: _isExpired ? Colors.red : Colors.orange[800]
                ),
                const SizedBox(width: 4),
                Text(
                  _isExpired 
                    ? 'Oferta expirada' 
                    : '🔥 Termina en: ${_formatDuration(_timeLeft)}',
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold, 
                    color: _isExpired ? Colors.red : Colors.orange[800],
                    fontFeatures: const [FontFeature.tabularFigures()]
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }
}