import 'package:flutter/material.dart';
import 'package:chilehalal_mobile/services/favorite_service.dart';
import 'package:chilehalal_mobile/widgets/layout/product_grid.dart';
import 'package:chilehalal_mobile/widgets/common/empty_state.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  
  bool _isLoading = true;
  List<Map<String, dynamic>>? _favorites;

  @override
  void initState() {
    super.initState();
    _loadFavorites(showLoader: true);
    
    _favoriteService.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    _favoriteService.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) {
      _loadFavorites(showLoader: false);
    }
  }

  Future<void> _loadFavorites({bool showLoader = true}) async {
    if (showLoader && _favorites == null) {
      setState(() => _isLoading = true);
    }
    
    final data = await _favoriteService.getFavorites();
    
    if (mounted) {
      setState(() {
        _favorites = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_favorites == null) {
      return const EmptyState(
        message: 'Inicia sesión en tu cuenta para poder guardar y ver tus productos favoritos.',
      );
    }

    if (_favorites!.isEmpty) {
      return const EmptyState(
        message: 'Aún no tienes productos favoritos. ¡Explora el catálogo y añade algunos!',
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadFavorites(showLoader: true),
      child: ProductGrid(products: _favorites!),
    );
  }
}