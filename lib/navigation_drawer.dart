
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
          ListTile(
            title: const Text("Home Page"),
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
          ListTile(
            title: const Text("Battle Page"),
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
          ListTile(
            title: const Text("Search Page"),
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
          ListTile(
            title: const Text("Favorites Page"),
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
          ListTile(
            title: const Text("About Page"),
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