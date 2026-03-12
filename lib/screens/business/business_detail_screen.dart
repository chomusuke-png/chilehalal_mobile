import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:chilehalal_mobile/services/business_service.dart';
import 'package:chilehalal_mobile/services/coupon_service.dart';

class BusinessDetailScreen extends StatefulWidget {
  final int businessId;

  const BusinessDetailScreen({super.key, required this.businessId});

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  final BusinessService _businessService = BusinessService();
  final CouponService _couponService = CouponService();

  Map<String, dynamic>? _business;
  List<dynamic> _coupons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Cargamos los detalles y los cupones al mismo tiempo para ahorrar tiempo
    final results = await Future.wait([
      _businessService.getBusinessDetails(widget.businessId),
      _couponService.getCoupons(businessId: widget.businessId, onlyActive: true),
    ]);

    if (mounted) {
      setState(() {
        _business = results[0];
        
        final couponsRes = results[1] as Map<String, dynamic>;
        if (couponsRes['success'] == true) {
          _coupons = couponsRes['data'];
        }
        
        _isLoading = false;
      });
    }
  }

  Widget _buildHalalBadge(String status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'full':
        color = Colors.green;
        text = '100% Halal';
        icon = Icons.check_circle;
        break;
      case 'partial':
        color = Colors.orange;
        text = 'Opciones Halal';
        icon = Icons.info;
        break;
      default:
        color = Colors.red;
        text = 'No Halal';
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildContactInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _business!['name'] ?? '',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _business!['type'] ?? 'Negocio',
                      style: TextStyle(fontSize: 14, color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _buildHalalBadge(_business!['computed_halal_status'] ?? 'none'),
            ],
          ),
          const SizedBox(height: 20),
          if (_business!['address'] != null && _business!['address'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3), shape: BoxShape.circle),
                    child: Icon(Icons.location_on, color: theme.colorScheme.primary, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Text(_business!['address'], style: const TextStyle(fontSize: 15))),
                ],
              ),
            ),
          if (_business!['phone'] != null && _business!['phone'].toString().isNotEmpty)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3), shape: BoxShape.circle),
                  child: Icon(Icons.phone, color: theme.colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(_business!['phone'], style: const TextStyle(fontSize: 15))),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildGallery() {
    final List<dynamic>? urls = _business!['gallery_urls'];
    if (urls == null || urls.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Text('Galería', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: urls.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: urls[index],
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[200], width: 140),
                    errorWidget: (context, url, error) => Container(color: Colors.grey[200], width: 140, child: const Icon(Icons.image)),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildCoupons(ThemeData theme) {
    if (_coupons.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.tag, color: Colors.orange[800], size: 18),
              const SizedBox(width: 8),
              Text('Cupones Disponibles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange[900])),
            ],
          ),
          const SizedBox(height: 16),
          ..._coupons.map((coupon) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[300]!, style: BorderStyle.solid),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(coupon['discount'], style: const TextStyle(fontWeight: FontWeight.bold))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    coupon['code'],
                    style: TextStyle(fontWeight: FontWeight.w900, color: Colors.orange[900], letterSpacing: 1.5),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMenu(ThemeData theme) {
    final List<dynamic>? menu = _business!['menu'];
    if (menu == null || menu.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Menú', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...menu.map((category) {
            final items = category['items'] as List<dynamic>? ?? [];
            if (items.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    category['category'] ?? 'Otros',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
                  ),
                ),
                ...items.map((item) {
                  final isHalal = item['is_halal'] == true || item['is_halal'] == 'true';
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 5, offset: const Offset(0, 2)),
                      ]
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['name'] ?? '',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ),
                                  if (isHalal)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Icon(Icons.check_circle, color: Colors.green[600], size: 16),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if (item['description'] != null && item['description'].toString().isNotEmpty)
                                Text(
                                  item['description'],
                                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '\$${item['price'] ?? 0}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 10),
              ],
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_business == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No se pudo cargar la información del local.')),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _business!['thumbnail_url'] != null
                  ? CachedNetworkImage(
                      imageUrl: _business!['thumbnail_url'],
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.store, size: 80, color: Colors.grey),
                    ),
              collapseMode: CollapseMode.pin,
            ),
            backgroundColor: theme.colorScheme.primary,
          ),
          
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContactInfo(theme),
                _buildCoupons(theme),
                _buildGallery(),
                const SizedBox(height: 10),
                _buildMenu(theme),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}