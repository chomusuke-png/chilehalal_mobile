import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            icon: const Icon(Icons.arrow_back_ios, size: 14),
            label: const Text('Anterior'),
            style: ElevatedButton.styleFrom(elevation: 0),
          ),
          Text(
            '$currentPage / $totalPages',
            style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
          ),
          ElevatedButton.icon(
            onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
            label: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Siguiente'),
                SizedBox(width: 5),
                Icon(Icons.arrow_forward_ios, size: 14)
              ],
            ),
            style: ElevatedButton.styleFrom(elevation: 0),
          ),
        ],
      ),
    );
  }
}