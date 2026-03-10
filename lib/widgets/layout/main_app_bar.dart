import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:chilehalal_mobile/screens/notifications/notifications_screen.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final String title;

  const MainAppBar({
    super.key,
    required this.currentIndex,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      iconTheme: IconThemeData(color: colorScheme.primary), 
      
      title: Image.asset(
              'assets/images/chilehalal-isotipo.png',
              height: 40,
              fit: BoxFit.contain,
            ),
      backgroundColor: colorScheme.surface,
      centerTitle: true,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2.0),
        child: Container(
          color: colorScheme.secondary,
          height: 2.0,
        ),
      ),
      actions: [
        IconButton(
          icon: FaIcon(FontAwesomeIcons.solidBell, size: 20, color: colorScheme.primary,),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}