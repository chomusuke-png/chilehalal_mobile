import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:chilehalal_mobile/screens/home_screen.dart';
import 'package:chilehalal_mobile/screens/scanner_screen.dart';
import 'package:chilehalal_mobile/screens/account_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);
  
  int _currentIndex = 0;

  List<Widget> _buildScreens() {
    return const [
      HomeScreen(),
      ScannerScreen(),
      AccountScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems(ColorScheme colorScheme) {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        title: "Inicio",
        activeColorPrimary: colorScheme.primary,
        inactiveColorPrimary: Colors.grey,
        activeColorSecondary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.qr_code_scanner),
        title: "Escanear",
        activeColorPrimary: colorScheme.primary,
        inactiveColorPrimary: Colors.grey,
        activeColorSecondary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: "Cuenta",
        activeColorPrimary: colorScheme.primary,
        inactiveColorPrimary: Colors.grey,
        activeColorSecondary: Colors.white,
      ),
    ];
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 1:
        return 'Escanear Producto';
      case 2:
        return 'Mi Cuenta';
      default:
        return 'ChileHalal';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _currentIndex == 0
            ? Image.asset(
                'assets/images/chilehalal-isotipo.png',
                height: 40,
                fit: BoxFit.contain,
              )
            : Text(_getAppBarTitle(_currentIndex)),
        backgroundColor: colorScheme.surface,
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: colorScheme.secondary,
            height: 2.0,
          ),
        ),
      ),
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(colorScheme),
        backgroundColor: colorScheme.surface,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true, 
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(10.0),
          colorBehindNavBar: colorScheme.surface,
        ),
        navBarStyle: NavBarStyle.style7,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}