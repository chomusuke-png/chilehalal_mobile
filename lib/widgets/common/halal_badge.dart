import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HalalBadge extends StatelessWidget {
  final dynamic status;

  const HalalBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final strStatus = status?.toString().toLowerCase() ?? '';

    if (strStatus == 'true' || strStatus == 'yes' || strStatus == '1') {
      return _buildBadge(Colors.green, 'Halal', FontAwesomeIcons.solidCircleCheck);
    } else if (strStatus == 'doubt') {
      return _buildBadge(Colors.orange, 'Dudoso', FontAwesomeIcons.circleExclamation);
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildBadge(Color color, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, color: color, size: 10),
          const SizedBox(width: 4),
          Text(
            text, 
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)
          ),
        ],
      ),
    );
  }
}