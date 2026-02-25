import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chilehalal_mobile/screens/product/product_screen.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> categoriesList = product['categories'] ?? [];
    final String categoryText = categoriesList.isNotEmpty
        ? categoriesList.join(', ')
        : 'Sin categoría';

    final dynamic rawHalalStatus = product['is_halal'];
    
    Color badgeColor = Colors.grey;
    IconData badgeIcon = FontAwesomeIcons.question;

    if (rawHalalStatus == true || rawHalalStatus == 'yes') {
      badgeColor = Colors.green;
      badgeIcon = FontAwesomeIcons.check;
    } else if (rawHalalStatus == false || rawHalalStatus == 'no') {
      badgeColor = Colors.red;
      badgeIcon = FontAwesomeIcons.xmark;
    } else if (rawHalalStatus == 'doubt') {
      badgeColor = Colors.orange;
      badgeIcon = FontAwesomeIcons.exclamation;
    }

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
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  product['image_url'] != null && product['image_url'].toString().isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product['image_url'], 
                          fit: BoxFit.cover,
                          memCacheWidth: 300,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
                        ),
                  
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: FaIcon(
                        badgeIcon,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product['name'] ?? 'Sin nombre',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  
                  const SizedBox(height: 4),

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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}