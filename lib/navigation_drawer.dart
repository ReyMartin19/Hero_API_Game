import 'package:flutter/material.dart';
import 'home_page.dart';
import 'battle_page.dart';
import 'search_page.dart';
import 'favorite_page.dart';
import 'about_page.dart';

enum AppPage { home, battle, search, favorites, about }

class NavigationDrawer extends StatelessWidget {
  final AppPage currentPage;
  final String apiKey;

  const NavigationDrawer({
    super.key,
    required this.currentPage,
    required this.apiKey,
  });

  static const Color activeBg = Color(0x1F661FFF); // #661FFF at 12% opacity
  static const Color activeText = Color(0xFF661FFF); // #661FFF at 100% opacity

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text("Navigation", style: TextStyle(color: Colors.white)),
          ),
          _drawerTile(
            context,
            title: "Home",
            selected: currentPage == AppPage.home,
            icon: Icons.home,
            onTap: () {
              if (currentPage != AppPage.home) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(apiKey: apiKey),
                  ),
                );
              } else {
                Navigator.pop(context);
              }
            },
          ),
          _drawerTile(
            context,
            title: "Battle",
            selected: currentPage == AppPage.battle,
            icon: Icons.sports_martial_arts,
            onTap: () {
              if (currentPage != AppPage.battle) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BattlePage(apiKey: apiKey),
                  ),
                );
              } else {
                Navigator.pop(context);
              }
            },
          ),
          _drawerTile(
            context,
            title: "Search",
            selected: currentPage == AppPage.search,
            icon: Icons.search,
            onTap: () {
              if (currentPage != AppPage.search) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(apiKey: apiKey),
                  ),
                );
              } else {
                Navigator.pop(context);
              }
            },
          ),
          _drawerTile(
            context,
            title: "Favorites",
            selected: currentPage == AppPage.favorites,
            icon: Icons.star,
            onTap: () {
              if (currentPage != AppPage.favorites) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritePage(apiKey: apiKey),
                  ),
                );
              } else {
                Navigator.pop(context);
              }
            },
          ),
          _drawerTile(
            context,
            title: "About",
            selected: currentPage == AppPage.about,
            icon: Icons.info,
            onTap: () {
              if (currentPage != AppPage.about) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AboutPage(apiKey: apiKey),
                  ),
                );
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

// Helper for drawer tile with custom active style, margin, and icon
Widget _drawerTile(
  BuildContext context, {
  required String title,
  required bool selected,
  required VoidCallback onTap,
  required IconData icon,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8), // Add margin left/right
    decoration: BoxDecoration(
      color: selected ? NavigationDrawer.activeBg : null,
      borderRadius: BorderRadius.circular(8),
    ),
    child: ListTile(
      leading: Icon(icon, color: selected ? NavigationDrawer.activeText : null),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? NavigationDrawer.activeText : null,
          fontWeight: selected ? FontWeight.normal : null,
        ),
      ),
      selected: selected,
      onTap: onTap,
    ),
  );
}
