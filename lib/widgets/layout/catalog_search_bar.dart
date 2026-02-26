import 'package:flutter/material.dart';

class CatalogSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onFilterPressed;
  final bool hasContent;

  const CatalogSearchBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.onClear,
    required this.onFilterPressed,
    required this.hasContent,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Buscar producto...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: hasContent
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: onClear,
                      )
                    : null,
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
            ),
          ),
          const SizedBox(width: 8),
          
          Container(
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: Colors.white),
              onPressed: onFilterPressed,
              tooltip: 'Filtrar',
            ),
          ),
        ],
      ),
    );
  }
}