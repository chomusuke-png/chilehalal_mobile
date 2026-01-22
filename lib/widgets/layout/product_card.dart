import 'package:flutter/material.dart';
import 'package:chilehalal_mobile/screens/product/product_screen.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Extraemos y formateamos las categorías
    // La API devuelve una lista de Strings en 'categories'
    final List<dynamic> categoriesList = product['categories'] ?? [];
    final String categoryText = categoriesList.isNotEmpty
        ? categoriesList.join(', ')
        : 'Sin categoría';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductScreen(productData: product),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. IMAGEN
            Expanded(
              child: product['image_url'] != null
                  ? Image.network(product['image_url'], fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
                    ),
            ),
            
            // 2. INFORMACIÓN
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  Text(
                    product['name'] ?? 'Sin nombre',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  
                  const SizedBox(height: 4),

                  // Categoría
                  Text(
                    categoryText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Etiqueta Halal
                  if (product['is_halal'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green, width: 0.5),
                      ),
                      child: const Text(
                        'HALAL',
                        style: TextStyle(
                          fontSize: 9, 
                          color: Colors.green, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}