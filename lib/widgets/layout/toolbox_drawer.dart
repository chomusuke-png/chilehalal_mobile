import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:chilehalal_mobile/screens/tools/about_screen.dart';
import 'package:chilehalal_mobile/screens/tools/halal_guide_screen.dart';
import 'package:chilehalal_mobile/screens/tools/prayer_schedule_screen.dart';

class ToolboxDrawer extends StatelessWidget {
  const ToolboxDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: colorScheme.surface,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Image.asset(
                      'assets/images/chilehalal-logo.png',
                      height: 80,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '"Trabajando con usted, para usted."',
                    style: TextStyle(
                      color: colorScheme.onSurface, 
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildDrawerItem(
                  context,
                  icon: FontAwesomeIcons.bookOpen,
                  title: 'Guía Halal',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HalalGuideScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: FontAwesomeIcons.personPraying,
                  title: 'Horario de oraciones',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PrayerScheduleScreen()),
                    );
                  },
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Divider(),
                ),
                
                _buildDrawerItem(
                  context,
                  icon: FontAwesomeIcons.gear,
                  title: 'Ajustes',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: FontAwesomeIcons.circleInfo,
                  title: 'Acerca de ChileHalal',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: FaIcon(icon, size: 22, color: colorScheme.primary),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}