import 'package:flutter/material.dart';

class ActiveFiltersRow extends StatelessWidget {
  final String? currentCategoryName;
  final List<String> selectedBrands;
  final VoidCallback onCategoryRemoved;
  final ValueChanged<String> onBrandRemoved;

  const ActiveFiltersRow({
    super.key,
    this.currentCategoryName,
    required this.selectedBrands,
    required this.onCategoryRemoved,
    required this.onBrandRemoved,
  });

  @override
  Widget build(BuildContext context) {
    if (currentCategoryName == null && selectedBrands.isEmpty) {
      return const SizedBox.shrink();
    }

    final chipBackgroundColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text(
              'Filtros: ', 
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)
            ),
            const SizedBox(width: 8),
            
            if (currentCategoryName != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InputChip(
                  label: Text(currentCategoryName!),
                  deleteIcon: const Icon(Icons.cancel, size: 18),
                  onDeleted: onCategoryRemoved,
                  backgroundColor: chipBackgroundColor,
                  side: BorderSide.none,
                ),
              ),

            ...selectedBrands.map((brand) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InputChip(
                    label: Text(brand),
                    deleteIcon: const Icon(Icons.cancel, size: 18),
                    onDeleted: () => onBrandRemoved(brand),
                    backgroundColor: chipBackgroundColor,
                    side: BorderSide.none,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}