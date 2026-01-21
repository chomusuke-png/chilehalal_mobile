import 'package:flutter/material.dart';
import 'package:chilehalal_mobile/services/auth_service.dart';
import 'package:chilehalal_mobile/screens/auth/login_screen.dart';

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

  // Esta función refresca el estado general
  Future<void> _checkSession() async {
    final logged = await _authService.isLoggedIn();
    if (logged) {
      final user = await _authService.getLocalUser();
      setState(() {
        _isLoggedIn = true;
        _userData = user;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoggedIn = false;
        _userData = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    _checkSession(); // Recargamos para volver al login
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // --- AQUÍ OCURRE LA MAGIA ---
    if (!_isLoggedIn) {
      // Si NO está logueado, le mostramos el LoginScreen
      // Le pasamos _checkSession como callback para que cuando termine de loguearse,
      // esta pantalla se entere y se actualice sola.
      return LoginScreen(onLoginSuccess: _checkSession);
    }

    // Si SÍ está logueado, mostramos el Perfil
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.green,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              _userData?['name'] ?? 'Usuario',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              _userData?['email'] ?? '',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 15),
            Chip(
              // Mostramos el Rol en lugar de puntos (según tu cambio reciente)
              label: Text('Rol: ${_userData?['role'] ?? 'user'}'.toUpperCase()),
              backgroundColor: Colors.amber[100],
              avatar: const Icon(Icons.verified_user, size: 18, color: Colors.orange),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            )
          ],
        ),
      ),
    );
  }
}