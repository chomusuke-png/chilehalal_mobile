import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chilehalal_mobile/services/auth_service.dart';
import 'package:chilehalal_mobile/services/favorite_service.dart';
import 'package:chilehalal_mobile/screens/auth/login_screen.dart';
import 'package:chilehalal_mobile/screens/auth/edit_profile_screen.dart';
import 'package:chilehalal_mobile/widgets/layout/product_grid.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthService _authService = AuthService();
  final FavoriteService _favoriteService = FavoriteService();
  
  bool _isLoading = true;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userData;
  
  List<dynamic> _favoriteProducts = [];
  bool _isLoadingFavorites = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final logged = await _authService.isLoggedIn();
    if (logged) {
      final freshUser = await _authService.getUserProfile(); 
      final userToUse = freshUser ?? await _authService.getLocalUser();
      
      if (mounted) {
        setState(() {
          _isLoggedIn = true;
          _userData = userToUse;
          _isLoading = false;
        });
        _loadFavorites();
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _userData = null;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoadingFavorites = true);
    try {
      final favs = await _favoriteService.getFavorites();
      if (mounted) {
        setState(() {
          _favoriteProducts = favs ?? [];
          _isLoadingFavorites = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingFavorites = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      _checkSession();
    }
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(userData: _userData!),
      ),
    );

    if (result == true) {
      setState(() => _isLoading = true);
      _checkSession();
    }
  }

  void _handleMenuAction(String value) {
    if (value == 'edit') {
      _navigateToEditProfile();
    } else if (value == 'logout') {
      _handleLogout();
    }
  }

  Widget _buildPartnerSection(ColorScheme colorScheme) {
    final company = _userData?['company']?.toString().isNotEmpty == true 
        ? _userData!['company'] 
        : 'No especificada';
    
    final List<dynamic> brands = _userData?['brands'] ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storefront, color: colorScheme.primary),
              const SizedBox(width: 10),
              const Text('Datos de Partner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 30),
          
          const Text('Empresa / Razón Social', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(company, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          
          const SizedBox(height: 20),
          
          const Text('Marcas Autorizadas', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          brands.isNotEmpty
              ? Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: brands.map((b) => Chip(
                    label: Text(b.toString(), style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600)),
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                    side: BorderSide.none,
                  )).toList(),
                )
              : const Text('Sin marcas asignadas', style: TextStyle(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isLoggedIn) {
      return LoginScreen(onLoginSuccess: _checkSession);
    }

    final String? profileImage = _userData?['profile_image'];
    final String phone = _userData?['phone'] ?? '';
    final bool isPartner = _userData?['role'] == 'partner';
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20, color: Colors.black87),
                    SizedBox(width: 12),
                    Text('Editar Perfil'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _checkSession,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3), width: 4),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))
                            ],
                          ),
                          child: ClipOval(
                            child: profileImage != null && profileImage.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: profileImage,
                                    fit: BoxFit.cover,
                                    memCacheWidth: 300,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[200],
                                      child: const Center(child: CircularProgressIndicator()),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: colorScheme.primary,
                                      child: const Icon(Icons.person, size: 60, color: Colors.white),
                                    ),
                                  )
                                : Container(
                                    color: colorScheme.primary,
                                    child: const Icon(Icons.person, size: 60, color: Colors.white),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Text(
                          _userData?['name'] ?? 'Usuario',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _userData?['email'] ?? 'correo@ejemplo.com',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        
                        if (phone.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.phone, size: 16, color: Colors.grey[500]),
                              const SizedBox(width: 6),
                              Text(
                                phone,
                                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                        
                        const SizedBox(height: 20),
                        
                        Chip(
                          label: Text(
                            'Rol: ${_userData?['role'] ?? 'user'}'.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                          labelStyle: TextStyle(color: colorScheme.primary),
                          avatar: Icon(Icons.verified_user, size: 18, color: colorScheme.primary),
                          side: BorderSide.none,
                        ),

                        if (isPartner) ...[
                          const SizedBox(height: 30),
                          _buildPartnerSection(colorScheme),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Divider(thickness: 1),
                  const SizedBox(height: 20),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.red[400]),
                        const SizedBox(width: 10),
                        const Text('Mis Favoritos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _isLoadingFavorites
                      ? const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _favoriteProducts.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Text(
                                'Aún no tienes productos guardados en favoritos.',
                                style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ProductGrid(
                              products: _favoriteProducts,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                            ),
                            
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}