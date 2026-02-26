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
  List<String> _brands = [];
  
  bool _isLoadingProducts = false;
  bool _isLoadingFilters = true;
  
  int _currentPage = 1;
  int _totalPages = 1;
  String _currentSearch = '';
  
  int? _currentCategoryId;
  String? _currentCategoryName;
  List<String> _selectedBrands = [];

  @override
  void initState() {
    super.initState();
    _currentCategoryId = widget.initialCategoryId;
    _currentCategoryName = widget.initialCategoryName;
    
    _loadFiltersData();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFiltersData() async {
    final results = await Future.wait([
      _productService.getCategories(),
      _productService.getBrands(),
    ]);

    if (mounted) {
      setState(() {
        _categories = results[0] as List<Map<String, dynamic>>;
        _brands = results[1] as List<String>;
        _isLoadingFilters = false;
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
      brands: _selectedBrands,
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

  void _removeFilter({bool isCategory = false, String? brandToRemove}) {
    setState(() {
      if (isCategory) {
        _currentCategoryId = null;
        _currentCategoryName = null;
      }
      if (brandToRemove != null) {
        _selectedBrands.remove(brandToRemove);
      }
    });
    _loadProducts(page: 1);
  }

  void _showFilterModal() {
    int? tempCategoryId = _currentCategoryId;
    String? tempCategoryName = _currentCategoryName;
    List<String> tempBrands = List.from(_selectedBrands);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final colorScheme = Theme.of(context).colorScheme;

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              builder: (_, controller) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Filtros', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: _isLoadingFilters
                            ? const Center(child: CircularProgressIndicator())
                            : ListView(
                                controller: controller,
                                children: [
                                  const Text('Categorías', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8.0,
                                    children: _categories.map((cat) {
                                      final isSelected = tempCategoryId == cat['id'];
                                      return ChoiceChip(
                                        label: Text(cat['name']),
                                        selected: isSelected,
                                        selectedColor: colorScheme.primary.withValues(alpha: 0.2),
                                        checkmarkColor: colorScheme.primary,
                                        onSelected: (bool selected) {
                                          setModalState(() {
                                            if (selected) {
                                              tempCategoryId = cat['id'];
                                              tempCategoryName = cat['name'];
                                            } else {
                                              tempCategoryId = null;
                                              tempCategoryName = null;
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  const Text('Marcas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8.0,
                                    children: _brands.map((brand) {
                                      final isSelected = tempBrands.contains(brand);
                                      return FilterChip(
                                        label: Text(brand),
                                        selected: isSelected,
                                        selectedColor: colorScheme.primary.withValues(alpha: 0.2),
                                        checkmarkColor: colorScheme.primary,
                                        onSelected: (bool selected) {
                                          setModalState(() {
                                            if (selected) {
                                              tempBrands.add(brand);
                                            } else {
                                              tempBrands.remove(brand);
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                      ),
                      
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _currentCategoryId = tempCategoryId;
                            _currentCategoryName = tempCategoryName;
                            _selectedBrands = tempBrands;
                          });
                          Navigator.pop(context);
                          _loadProducts(page: 1);
                        },
                        child: const Text('APLICAR FILTROS', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildActiveFilters() {
    if (_currentCategoryName == null && _selectedBrands.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text('Filtros: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(width: 8),
            
            if (_currentCategoryName != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InputChip(
                  label: Text(_currentCategoryName!),
                  deleteIcon: const Icon(Icons.cancel, size: 18),
                  onDeleted: () => _removeFilter(isCategory: true),
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  side: BorderSide.none,
                ),
              ),

            ..._selectedBrands.map((brand) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InputChip(
                    label: Text(brand),
                    deleteIcon: const Icon(Icons.cancel, size: 18),
                    onDeleted: () => _removeFilter(brandToRemove: brand),
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    side: BorderSide.none,
                  ),
                )),
          ],
        ),
      ),
    );
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
              onFilterPressed: _showFilterModal,
              hasContent: _currentSearch.isNotEmpty,
            ),

            _buildActiveFilters(),

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
}