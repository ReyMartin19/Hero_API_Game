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
            title: "Home Page",
            selected: currentPage == AppPage.home,
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
            title: "Battle Page",
            selected: currentPage == AppPage.battle,
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
            title: "Search Page",
            selected: currentPage == AppPage.search,
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
            title: "Favorites Page",
            selected: currentPage == AppPage.favorites,
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
            title: "About Page",
            selected: currentPage == AppPage.about,
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

// Helper for drawer tile with custom active style and margin
Widget _drawerTile(
  BuildContext context, {
  required String title,
  required bool selected,
  required VoidCallback onTap,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8), // Add margin left/right
    decoration: BoxDecoration(
      color: selected ? NavigationDrawer.activeBg : null,
      borderRadius: BorderRadius.circular(8),
    ),
    child: ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: selected ? NavigationDrawer.activeText : null,
          fontWeight: selected ? FontWeight.bold : null,
        ),
      ),
      selected: selected,
      onTap: onTap,
    ),
  );
}
