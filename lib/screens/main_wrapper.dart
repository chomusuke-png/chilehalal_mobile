import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:chilehalal_mobile/screens/home/home_screen.dart';
import 'package:chilehalal_mobile/screens/catalog/catalog_screen.dart';
import 'package:chilehalal_mobile/screens/scanner/scanner_screen.dart';
import 'package:chilehalal_mobile/screens/auth/account_screen.dart';

final GlobalKey<MainWrapperState> mainWrapperKey = GlobalKey<MainWrapperState>();

class MainWrapper extends StatefulWidget {
  MainWrapper({Key? key}) : super(key: key ?? mainWrapperKey);

  @override
  State<MainWrapper> createState() => MainWrapperState();
}

class MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CatalogScreen(),
    ScannerScreen(),
    AccountScreen(),
  ];

  void jumpToTab(int index, {Widget? screenToPush}) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
      
      if (screenToPush != null) {
        Future.delayed(const Duration(milliseconds: 100), () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => screenToPush));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withValues(alpha: 0.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: colorScheme.primary,
              iconSize: 22,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              duration: const Duration(milliseconds: 200),
              tabBackgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              color: Colors.grey[600],
              tabs: const [
                GButton(
                  icon: FontAwesomeIcons.solidHouse,
                  text: 'Inicio',
                ),
                GButton(
                  icon: FontAwesomeIcons.list,
                  text: 'Catálogo',
                ),
                GButton(
                  icon: Icons.barcode_reader,
                  iconSize: 26,
                  text: 'Escanear',
                ),
                GButton(
                  icon: FontAwesomeIcons.solidUser,
                  text: 'Cuenta',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}