import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:chilehalal_mobile/screens/home/home_screen.dart';
import 'package:chilehalal_mobile/screens/scanner/scanner_screen.dart';
import 'package:chilehalal_mobile/screens/auth/account_screen.dart';
import 'package:chilehalal_mobile/widgets/layout/main_app_bar.dart';

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
        icon: const FaIcon(FontAwesomeIcons.house),
        title: "Inicio",
        activeColorPrimary: colorScheme.primary,
        inactiveColorPrimary: Colors.grey,
        activeColorSecondary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: const FaIcon(FontAwesomeIcons.qrcode),
        title: "Escanear",
        activeColorPrimary: colorScheme.primary,
        inactiveColorPrimary: Colors.grey,
        activeColorSecondary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: const FaIcon(FontAwesomeIcons.user),
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
      appBar: MainAppBar(
        currentIndex: _currentIndex,
        title: _getAppBarTitle(_currentIndex),
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