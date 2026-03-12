import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HalalBadge extends StatelessWidget {
  final String status;

  const HalalBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == 'none' || status.isEmpty) {
      return const SizedBox.shrink();
    }

    Color badgeColor = Colors.green; 
    String text = status == 'full' ? '100% Halal' : 'Opciones Halal';
    IconData icon = status == 'full' ? FontAwesomeIcons.solidCircleCheck : FontAwesomeIcons.circleInfo;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 14, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            text, 
            style: TextStyle(
              color: badgeColor, 
              fontWeight: FontWeight.bold, 
              fontSize: 12
            )
          ),
        ],
      ),
    );
  }
}