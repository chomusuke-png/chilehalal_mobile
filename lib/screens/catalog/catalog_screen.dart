import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chilehalal_mobile/services/product_service.dart';
import 'package:chilehalal_mobile/screens/product/product_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  // Estado
  List<dynamic> _products = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  String _currentSearch = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts({int page = 1}) async {
    setState(() {
      _isLoading = true;
    });

    final response = await _productService.getProducts(
      page: page,
      search: _currentSearch,
    );

    if (mounted) {
      setState(() {
        _products = response.products;
        _totalPages = response.totalPages;
        _currentPage = response.currentPage;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    // Actualizamos la búsqueda y reseteamos a página 1
    _currentSearch = value;
    _loadProducts(page: 1);
  }

  void _changePage(int newPage) {
    if (newPage >= 1 && newPage <= _totalPages) {
      _loadProducts(page: newPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // 1. BARRA DE BÚSQUEDA
            _buildSearchBar(colorScheme),

            // 2. LISTA DE PRODUCTOS (Expanded para ocupar el espacio restante)
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _products.isEmpty
                      ? _buildEmptyState()
                      : _buildProductGrid(colorScheme),
            ),

            // 3. PAGINACIÓN (Solo si hay productos)
            if (_products.isNotEmpty) _buildPaginationControls(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar producto...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _currentSearch.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
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
        onSubmitted: _onSearchChanged, // Ejecuta al presionar "Enter" en el teclado
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildProductGrid(ColorScheme colorScheme) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.70,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index] as Map<String, dynamic>;
        return _buildProductCard(product, colorScheme);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, ColorScheme colorScheme) {
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
              child: product['image_url'] != null
                  ? Image.network(product['image_url'], fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Sin nombre',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
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
                        style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold),
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

  Widget _buildPaginationControls(ColorScheme colorScheme) {
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
          // Botón Anterior
          ElevatedButton.icon(
            onPressed: _currentPage > 1 ? () => _changePage(_currentPage - 1) : null,
            icon: const Icon(Icons.arrow_back_ios, size: 14),
            label: const Text('Anterior'),
            style: ElevatedButton.styleFrom(elevation: 0),
          ),
          
          // Indicador de Página
          Text(
            '$_currentPage / $_totalPages',
            style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
          ),

          // Botón Siguiente
          ElevatedButton.icon(
            onPressed: _currentPage < _totalPages ? () => _changePage(_currentPage + 1) : null,
            // Truco para poner el icono a la derecha: Directionality o Row manual
            label: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [Text('Siguiente'), SizedBox(width: 5), Icon(Icons.arrow_forward_ios, size: 14)],
            ),
            style: ElevatedButton.styleFrom(elevation: 0),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(FontAwesomeIcons.boxOpen, size: 50, color: Colors.grey),
          const SizedBox(height: 15),
          Text(
            'No se encontraron productos',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}