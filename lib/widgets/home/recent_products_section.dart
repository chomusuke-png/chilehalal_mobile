import 'package:flutter/material.dart';
import 'package:chilehalal_mobile/widgets/layout/product_card.dart';

class RecentProductsSection extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  const RecentProductsSection({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vistos Recientemente',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 150,
                child: ProductCard(product: products[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}