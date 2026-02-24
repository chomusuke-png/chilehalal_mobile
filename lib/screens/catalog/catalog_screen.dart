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
  List<Map<String, dynamic>> _categories = [];
  
  bool _isLoadingProducts = false;
  bool _isLoadingCategories = true;
  
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
    
    _loadCategories();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final categories = await _productService.getCategories();
    if (mounted) {
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadProducts({int page = 1}) async {
    setState(() {
      _isLoadingProducts = true;
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
        _isLoadingProducts = false;
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

  void _onCategorySelected(int? categoryId, String? categoryName) {
    if (_currentCategoryId == categoryId) return;

    setState(() {
      _currentCategoryId = categoryId;
      _currentCategoryName = categoryName;
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

            _buildCategoryFilters(colorScheme),

            Expanded(
              child: _isLoadingProducts
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

  Widget _buildCategoryFilters(ColorScheme colorScheme) {
    if (_isLoadingCategories) {
      return const SizedBox(
        height: 50,
        child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }

    if (_categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: _categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = _currentCategoryId == null;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: const Text('Todos', style: TextStyle(fontWeight: FontWeight.bold)),
                selected: isSelected,
                selectedColor: colorScheme.primary.withValues(alpha: 0.2),
                checkmarkColor: colorScheme.primary,
                onSelected: (bool selected) {
                  if (selected) _onCategorySelected(null, null);
                },
              ),
            );
          }

          final category = _categories[index - 1];
          final isSelected = _currentCategoryId == category['id'];

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category['name'] ?? ''),
              selected: isSelected,
              selectedColor: colorScheme.primary.withValues(alpha: 0.2),
              checkmarkColor: colorScheme.primary,
              onSelected: (bool selected) {
                if (selected) {
                  _onCategorySelected(category['id'], category['name']);
                } else {
                  _onCategorySelected(null, null);
                }
              },
            ),
          );
        },
      ),
    );
  }
}