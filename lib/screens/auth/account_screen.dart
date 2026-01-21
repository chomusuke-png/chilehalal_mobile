import 'package:flutter/material.dart';
import 'package:chilehalal_mobile/services/auth_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthService _authService = AuthService();
  
  // Estado
  bool _isLoading = true;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userData;

  // Formulario
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  // Verificar si ya hay sesión al iniciar
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
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogin() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa email y contraseña')),
      );
      return;
    }

    setState(() => _isLoading = true); // Mostrar carga

    final result = await _authService.login(_emailCtrl.text, _passCtrl.text);

    setState(() => _isLoading = false); // Ocultar carga

    if (result['success']) {
      setState(() {
        _isLoggedIn = true;
        _userData = result['data'];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Bienvenido ${_userData?['name']}!')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    setState(() {
      _isLoggedIn = false;
      _userData = null;
      _emailCtrl.clear();
      _passCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.grey[50], // Fondo suave
      body: _isLoggedIn ? _buildProfileView() : _buildLoginView(),
    );
  }

  // VISTA 1: Perfil del Usuario
  Widget _buildProfileView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.green,
            child: Icon(Icons.person, size: 50, color: Colors.white),
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
          const SizedBox(height: 10),
          Chip(
            label: Text('Puntos: ${_userData?['points'] ?? 0}'),
            backgroundColor: Colors.amber[100],
            avatar: const Icon(Icons.star, size: 18, color: Colors.orange),
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
            ),
          )
        ],
      ),
    );
  }

  // VISTA 2: Formulario de Login
  Widget _buildLoginView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          // Logo o Icono
          Image.asset(
            'assets/images/chilehalal-logo.png', // Asegúrate de tener este asset o usa un Icono
            height: 100,
            errorBuilder: (c, e, s) => const Icon(Icons.lock, size: 80, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          const Text(
            'Iniciar Sesión',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          
          // Campos
          TextField(
            controller: _emailCtrl,
            decoration: const InputDecoration(
              labelText: 'Correo Electrónico',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _passCtrl,
            decoration: const InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          
          const SizedBox(height: 30),
          
          // Botón Login
          ElevatedButton(
            onPressed: _handleLogin,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('INGRESAR', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}