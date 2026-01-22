import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chilehalal_mobile/services/product_service.dart';
import 'package:chilehalal_mobile/widgets/layout/catalog_search_bar.dart';
import 'package:chilehalal_mobile/widgets/layout/product_grid.dart';
import 'package:chilehalal_mobile/widgets/layout/pagination_controls.dart';
import 'package:chilehalal_mobile/widgets/common/empty_state.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

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
    _currentSearch = value;
    _loadProducts(page: 1);
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
    setState(() {}); // Forzar rebuild para ocultar icono X
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      // Sin AppBar, como solicitaste.
      body: SafeArea(
        child: Column(
          children: [
            // 1. Barra de Búsqueda Modular
            CatalogSearchBar(
              controller: _searchController,
              onSubmitted: _onSearchChanged,
              onClear: _clearSearch,
              hasContent: _currentSearch.isNotEmpty,
            ),

            // 2. Contenido (Carga, Vacío o Grilla)
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _products.isEmpty
                      ? const EmptyState(message: 'No se encontraron productos')
                      : ProductGrid(products: _products),
            ),

            // 3. Paginación
            if (_products.isNotEmpty)
              PaginationControls(
                currentPage: _currentPage,
                totalPages: _totalPages,
                onPageChanged: (page) => _loadProducts(page: page),
              ),
          ],
        ),
      ),
    );
  }
}