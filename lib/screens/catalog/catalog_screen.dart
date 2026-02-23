import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chilehalal_mobile/services/product_service.dart';
import 'package:chilehalal_mobile/widgets/layout/catalog_search_bar.dart';
import 'package:chilehalal_mobile/widgets/layout/product_grid.dart';
import 'package:chilehalal_mobile/widgets/layout/pagination_controls.dart';
import 'package:chilehalal_mobile/widgets/common/empty_state.dart';

class CatalogScreen extends StatefulWidget {
  final int? initialCategoryId;
  final String? initialCategoryName;

  const CatalogScreen({
    super.key, 
    this.initialCategoryId, 
    this.initialCategoryName
  });

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
  
  int? _currentCategoryId;
  String? _currentCategoryName;

  @override
  void initState() {
    super.initState();
    _currentCategoryId = widget.initialCategoryId;
    _currentCategoryName = widget.initialCategoryName;
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
      categoryId: _currentCategoryId,
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
    setState(() {});
  }

  void _clearCategoryFilter() {
    setState(() {
      _currentCategoryId = null;
      _currentCategoryName = null;
    });
    _loadProducts(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CatalogSearchBar(
              controller: _searchController,
              onSubmitted: _onSearchChanged,
              onClear: _clearSearch,
              hasContent: _currentSearch.isNotEmpty,
            ),

            if (_currentCategoryName != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    const Text('Filtrando por: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Chip(
                      label: Text(_currentCategoryName!),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: _clearCategoryFilter,
                      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                      labelStyle: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                      side: BorderSide.none,
                    ),
                  ],
                ),
              ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _products.isEmpty
                      ? const EmptyState(message: 'No se encontraron productos')
                      : ProductGrid(products: _products),
            ),

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