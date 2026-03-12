import 'dart:async';
import 'package:chilehalal_mobile/screens/business/business_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:chilehalal_mobile/services/business_service.dart';
import 'package:chilehalal_mobile/widgets/layout/custom_search_bar.dart';
import 'package:chilehalal_mobile/widgets/layout/pagination_controls.dart';
import 'package:chilehalal_mobile/widgets/common/empty_state.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BusinessesListScreen extends StatefulWidget {
  const BusinessesListScreen({super.key});

  @override
  State<BusinessesListScreen> createState() => _BusinessesListScreenState();
}

class _BusinessesListScreenState extends State<BusinessesListScreen> {
  final BusinessService _businessService = BusinessService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _businesses = [];
  
  bool _isLoading = false;
  
  int _currentPage = 1;
  int _totalPages = 1;
  String _currentSearch = '';
  String? _currentType;

  // Filtros estáticos sugeridos para negocios
  final List<String> _businessTypes = [
    'Restaurante', 'Carnicería', 'Supermercado', 'Minimarket', 'Cafetería', 'Pastelería'
  ];

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBusinesses({int page = 1}) async {
    setState(() {
      _isLoading = true;
    });

    final response = await _businessService.getBusinesses(
      page: page,
      search: _currentSearch,
      type: _currentType,
    );

    if (mounted) {
      setState(() {
        if (response['success'] == true) {
          _businesses = response['data'];
          _totalPages = response['pagination']['total_pages'];
          _currentPage = response['pagination']['current_page'];
        } else {
          _businesses = [];
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadBusinesses(page: 1);
  }

  void _onSearchChanged(String value) {
    _currentSearch = value;
    _loadBusinesses(page: 1);
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
    setState(() {});
  }

  void _removeFilter() {
    setState(() {
      _currentType = null;
    });
    _loadBusinesses(page: 1);
  }

  void _showFilterModal() {
    String? tempType = _currentType;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final colorScheme = Theme.of(context).colorScheme;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    children: _businessTypes.map((type) {
                      final isSelected = tempType == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        selectedColor: colorScheme.primary.withValues(alpha: 0.2),
                        checkmarkColor: colorScheme.primary,
                        onSelected: (bool selected) {
                          setModalState(() {
                            tempType = selected ? type : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _currentType = tempType;
                      });
                      Navigator.pop(context);
                      _loadBusinesses(page: 1);
                    },
                    child: const Text('APLICAR FILTRO', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActiveFilters() {
    if (_currentType == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          InputChip(
            label: Text('Tipo: $_currentType'),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: _removeFilter,
            backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
            labelStyle: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessCard(Map<String, dynamic> business) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Configuración visual según el estado Halal
    Color statusColor = Colors.grey;
    String statusText = 'No verificado';
    IconData statusIcon = Icons.help_outline;

    switch (business['computed_halal_status']) {
      case 'full':
        statusColor = Colors.green;
        statusText = '100% Halal';
        statusIcon = Icons.check_circle;
        break;
      case 'partial':
        statusColor = Colors.orange;
        statusText = 'Opciones Halal';
        statusIcon = Icons.info;
        break;
      case 'none':
        statusColor = Colors.red;
        statusText = 'No Halal';
        statusIcon = Icons.cancel;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => BusinessDetailScreen(businessId: business['id'])));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen de Portada
            SizedBox(
              height: 140,
              child: business['thumbnail_url'] != null
                  ? CachedNetworkImage(
                      imageUrl: business['thumbnail_url'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey[200], child: const Center(child: CircularProgressIndicator())),
                      errorWidget: (context, url, error) => Container(color: Colors.grey[200], child: const Icon(Icons.store, size: 50, color: Colors.grey)),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.store, size: 50, color: Colors.grey),
                    ),
            ),
            // Detalles
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          business['name'] ?? 'Sin Nombre',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 14, color: statusColor),
                            const SizedBox(width: 4),
                            Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (business['type'] != null && business['type'].toString().isNotEmpty)
                    Text(
                      business['type'],
                      style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  const SizedBox(height: 8),
                  if (business['address'] != null && business['address'].toString().isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            business['address'],
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
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
            CustomSearchBar(
              hintText: 'Buscar restaurantes, tiendas...',
              controller: _searchController,
              onSubmitted: _onSearchChanged,
              onClear: _clearSearch,
              onFilterPressed: _showFilterModal,
              hasContent: _currentSearch.isNotEmpty,
            ),

            _buildActiveFilters(),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _handleRefresh,
                      color: colorScheme.primary,
                      child: _businesses.isEmpty
                          ? CustomScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              slivers: [
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: const Center(
                                    child: EmptyState(message: 'No se encontraron negocios'),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: _businesses.length,
                              itemBuilder: (context, index) {
                                return _buildBusinessCard(_businesses[index]);
                              },
                            ),
                    ),
            ),

            if (_businesses.isNotEmpty && _totalPages > 1)
              PaginationControls(
                currentPage: _currentPage,
                totalPages: _totalPages,
                onPageChanged: (page) => _loadBusinesses(page: page),
              ),
          ],
        ),
      ),
    );
  }
}