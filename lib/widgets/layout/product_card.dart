import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chilehalal_mobile/screens/product/product_screen.dart';
import 'package:chilehalal_mobile/screens/product/edit_product_screen.dart';
import 'package:chilehalal_mobile/services/auth_service.dart';
import 'package:chilehalal_mobile/services/product_service.dart';

class ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _canEdit = false;
  bool _canDelete = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final user = await AuthService().getLocalUser();
    if (user == null) return;

    final String role = user['role'] ?? 'user';
    final List<dynamic> userBrands = user['brands'] ?? [];
    final String productBrand = widget.product['brand'] ?? '';

    if (mounted) {
      setState(() {
        if (role == 'owner' || role == 'administrator') {
          _canEdit = true;
          _canDelete = true;
        } else if (role == 'editor') {
          _canEdit = true;
          _canDelete = false;
        } else if (role == 'partner') {
          final isOwnBrand = userBrands.any((b) => b.toString().toLowerCase() == productBrand.toLowerCase());
          _canEdit = isOwnBrand;
          _canDelete = isOwnBrand;
        } else {
          _canEdit = false;
          _canDelete = false;
        }
      });
    }
  }

  void _handleAction(String action) {
    if (action == 'edit') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProductScreen(productData: widget.product),
        ),
      ).then((didUpdate) {
        if (didUpdate == true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor actualiza la vista para ver los cambios.')),
          );
        }
      });
    } else if (action == 'delete') {
      _showDeleteConfirmation();
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Estás seguro que deseas eliminar "${widget.product['name']}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              _executeDelete();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _executeDelete() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true, 
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    final productId = widget.product['id'] as int;
    final result = await ProductService().deleteProduct(productId);

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto eliminado. Desliza hacia abajo para actualizar.'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> categoriesList = widget.product['categories'] ?? [];
    final String categoryText = categoriesList.isNotEmpty
        ? categoriesList.join(', ')
        : 'Sin categoría';

    final dynamic rawHalalStatus = widget.product['is_halal'];
    
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
            builder: (_) => ProductScreen(productData: widget.product),
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
                  widget.product['image_url'] != null && widget.product['image_url'].toString().isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.product['image_url'], 
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

                  if (_canEdit || _canDelete)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.more_vert, size: 18, color: Colors.black87),
                          onSelected: _handleAction,
                          itemBuilder: (context) => [
                            if (_canEdit)
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 18, color: Colors.blue),
                                    SizedBox(width: 10),
                                    Text('Editar'),
                                  ],
                                ),
                              ),
                            if (_canDelete)
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 18, color: Colors.red),
                                    SizedBox(width: 10),
                                    Text('Eliminar', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                          ],
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
                    widget.product['name'] ?? 'Sin nombre',
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