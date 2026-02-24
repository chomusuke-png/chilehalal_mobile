import 'package:flutter/material.dart';

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
      title: currentIndex == 0
          ? Image.asset(
              'assets/images/chilehalal-isotipo.png',
              height: 40,
              fit: BoxFit.contain,
            )
          : Text(
              title,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 2.0);
}