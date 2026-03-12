import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:chilehalal_mobile/screens/business/business_detail_screen.dart';
import 'package:chilehalal_mobile/services/business_service.dart';
import 'package:chilehalal_mobile/widgets/layout/custom_search_bar.dart';
import 'package:chilehalal_mobile/widgets/layout/custom_filter_modal.dart';
import 'package:chilehalal_mobile/widgets/layout/active_filters_row.dart';
import 'package:chilehalal_mobile/widgets/layout/pagination_controls.dart';
import 'package:chilehalal_mobile/widgets/common/empty_state.dart';
import 'package:chilehalal_mobile/widgets/common/halal_badge.dart';
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

    CustomFilterModal.show(
      context: context,
      title: 'Filtrar por Tipo',
      onApply: () {
        setState(() {
          _currentType = tempType;
        });
        Navigator.pop(context);
        _loadBusinesses(page: 1);
      },
      contentBuilder: (context, setModalState, _) {
        final colorScheme = Theme.of(context).colorScheme;
        
        return Wrap(
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
        );
      },
    );
  }

  Widget _buildBusinessCard(Map<String, dynamic> business) {
    final colorScheme = Theme.of(context).colorScheme;

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
            SizedBox(
              height: 140,
              child: business['thumbnail_url'] != null
                  ? CachedNetworkImage(
                      imageUrl: business['thumbnail_url'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey[200], child: const Center(child: CircularProgressIndicator())),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200], 
                        child: const Center(child: FaIcon(FontAwesomeIcons.store, size: 50, color: Colors.grey)),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Center(child: FaIcon(FontAwesomeIcons.store, size: 50, color: Colors.grey)),
                    ),
            ),
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
                      HalalBadge(status: business['computed_halal_status'] ?? 'none'),
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
                        FaIcon(FontAwesomeIcons.locationDot, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 6),
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

            ActiveFiltersRow(
              currentCategoryName: _currentType,
              selectedBrands: const [],
              onCategoryRemoved: _removeFilter,
              onBrandRemoved: (_) {}, 
            ),

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