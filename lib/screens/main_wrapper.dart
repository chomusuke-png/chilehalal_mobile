import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:chilehalal_mobile/screens/home/home_screen.dart';
import 'package:chilehalal_mobile/screens/catalog/catalog_screen.dart';
import 'package:chilehalal_mobile/screens/scanner/scanner_screen.dart';
import 'package:chilehalal_mobile/screens/favorites/favorites_screen.dart';
import 'package:chilehalal_mobile/screens/auth/account_screen.dart';

final GlobalKey<MainWrapperState> mainWrapperKey = GlobalKey<MainWrapperState>();

class MainWrapper extends StatefulWidget {
  MainWrapper({Key? key}) : super(key: key ?? mainWrapperKey);

  @override
  State<MainWrapper> createState() => MainWrapperState();
}

class MainWrapperState extends State<MainWrapper> {
  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);

  void jumpToTab(int index, {Widget? screenToPush}) {
    _controller.jumpToTab(index);
    if (screenToPush != null && mounted) {
      Future.delayed(const Duration(milliseconds: 100), () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => screenToPush));
      });
    }
  }

  List<Widget> _buildScreens() {
    return const [
      HomeScreen(),
      CatalogScreen(),
      ScannerScreen(),
      FavoritesScreen(),
      AccountScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems(ColorScheme colorScheme) {
    return [
      PersistentBottomNavBarItem(
        icon: const FaIcon(FontAwesomeIcons.solidHouse),
        title: "Inicio",
        activeColorPrimary: colorScheme.primary,
        inactiveColorPrimary: Colors.grey,
        activeColorSecondary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: const FaIcon(FontAwesomeIcons.list),
        title: "Catálogo",
        activeColorPrimary: colorScheme.primary,
        inactiveColorPrimary: Colors.grey,
        activeColorSecondary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.barcode_reader),
        title: "Escanear",
        activeColorPrimary: colorScheme.primary,
        inactiveColorPrimary: Colors.grey,
        activeColorSecondary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: const FaIcon(FontAwesomeIcons.solidHeart),
        title: "Favoritos",
        activeColorPrimary: colorScheme.primary,
        inactiveColorPrimary: Colors.grey,
        activeColorSecondary: Colors.white,
      ),
      PersistentBottomNavBarItem(
        icon: const FaIcon(FontAwesomeIcons.solidUser),
        title: "Cuenta",
        activeColorPrimary: colorScheme.primary,
        inactiveColorPrimary: Colors.grey,
        activeColorSecondary: Colors.white,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PersistentTabView(
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
    );
  }
}