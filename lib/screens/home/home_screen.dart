import 'package:flutter/material.dart';
import 'package:chilehalal_mobile/services/auth_service.dart';
import 'package:chilehalal_mobile/services/product_service.dart';
import 'package:chilehalal_mobile/services/recent_products_service.dart';
import 'package:chilehalal_mobile/widgets/common/prayer_countdown.dart';
import 'package:chilehalal_mobile/widgets/layout/main_app_bar.dart';
import 'package:chilehalal_mobile/widgets/home/recent_products_section.dart';
import 'package:chilehalal_mobile/widgets/home/category_grid_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final ProductService _productService = ProductService();
  final RecentProductsService _recentService = RecentProductsService();

  bool _isLoading = true;
  String _userName = 'Usuario';
  List<Map<String, dynamic>> _recentProducts = [];
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final results = await Future.wait([
      _authService.getLocalUser(),
      _recentService.getRecentProducts(),
      _productService.getCategories(),
    ]);

    if (mounted) {
      setState(() {
        final userData = results[0] as Map<String, dynamic>?;
        _userName = userData?['name'] ?? 'Usuario';
        _recentProducts = results[1] as List<Map<String, dynamic>>;
        _categories = results[2] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const MainAppBar(
        currentIndex: 0, 
        title: 'ChileHalal'
      ),
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PrayerCountdown(
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      Text(
                        'Bienvenido, $_userName',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                        ),
                      ),

                      const SizedBox(height: 40),

                      RecentProductsSection(products: _recentProducts),
                      
                      if (_recentProducts.isNotEmpty)
                        const SizedBox(height: 40),

                      CategoryGridSection(categories: _categories),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}