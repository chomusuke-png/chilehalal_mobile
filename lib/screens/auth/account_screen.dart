import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chilehalal_mobile/services/auth_service.dart';
import 'package:chilehalal_mobile/screens/auth/login_screen.dart';
import 'package:chilehalal_mobile/screens/auth/edit_profile_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthService _authService = AuthService();
  
  bool _isLoading = true;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userData;

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

  Future<void> _handleLogout() async {
    await _authService.logout();
    _checkSession();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isLoggedIn) {
      return LoginScreen(onLoginSuccess: _checkSession);
    }

    final String? profileImage = _userData?['profile_image'];
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEditProfile,
            tooltip: 'Editar Perfil',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _checkSession,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                
                const SizedBox(height: 60),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}