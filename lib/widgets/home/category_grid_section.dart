import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chilehalal_mobile/screens/catalog/catalog_screen.dart';

class CategoryGridSection extends StatelessWidget {
  final List<Map<String, dynamic>> categories;

  const CategoryGridSection({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Explorar Categorías',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: categories.map((category) {
            final String? imageUrl = category['image_url'];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CatalogScreen(
                      initialCategoryId: category['id'],
                      initialCategoryName: category['name'],
                    ),
                  ),
                );
              },
              child: Container(
                width: (MediaQuery.of(context).size.width - 60) / 2,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          memCacheWidth: 300,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                        )
                      else
                        Container(color: colorScheme.primary),

                      Container(
                        color: Colors.black.withValues(alpha: 0.45),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              category['name'] ?? '',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold, 
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${category['count']} productos',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}