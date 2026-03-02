import 'package:flutter/material.dart';
import 'package:chilehalal_mobile/widgets/layout/product_card.dart';

class ProductGrid extends StatelessWidget {
  final List<dynamic> products;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ProductGrid({
    super.key, 
    required this.products,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}