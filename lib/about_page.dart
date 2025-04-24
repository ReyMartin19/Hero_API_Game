import 'package:flutter/material.dart';
import 'home_page.dart'; // Add this import
import 'battle_page.dart'; // Add this import
import 'search_page.dart'; // Add this import
import 'favorite_page.dart'; // Add this import

class AboutPage extends StatelessWidget {
  final String apiKey;

  const AboutPage({super.key, required this.apiKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Navigation", style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              title: const Text("Home Page"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(apiKey: apiKey),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("Battle Page"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BattlePage(apiKey: apiKey),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("Search Page"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(apiKey: apiKey),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("Favorites Page"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritePage(apiKey: apiKey),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text("About Page"),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "About Hero Games",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "Hero Games is a fun and interactive app where you can search for superheroes, "
              "add them to your favorites, and battle with them. Powered by the Superhero API, "
              "this app brings your favorite heroes to life!",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "Features:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("- Search for superheroes using the Superhero API."),
            Text("- Add your favorite heroes to a favorites list."),
            Text("- Battle with heroes and compare their stats."),
            Text("- Save your progress and continue anytime."),
            SizedBox(height: 16),
            Text(
              "Developed by Rey Agluya and members of the Hero Games team.",
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
