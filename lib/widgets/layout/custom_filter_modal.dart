import 'package:flutter/material.dart';

class CustomFilterModal {
  static Future<void> show({
    required BuildContext context,
    required String title,
    bool isScrollControlled = false,
    required Widget Function(BuildContext context, StateSetter setModalState, ScrollController? scrollController) contentBuilder,
    required VoidCallback onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: isScrollControlled,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final colorScheme = Theme.of(context).colorScheme;

            Widget buildBody(ScrollController? controller) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    
                    isScrollControlled 
                        ? Expanded(child: contentBuilder(context, setModalState, controller))
                        : contentBuilder(context, setModalState, controller),
                    
                    const SizedBox(height: 24),
                    
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: onApply,
                      child: const Text('APLICAR FILTROS', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }

            if (isScrollControlled) {
              return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.6,
                maxChildSize: 0.9,
                builder: (_, controller) => buildBody(controller),
              );
            } else {
              return buildBody(null);
            }
          },
        );
      },
    );
  }
}