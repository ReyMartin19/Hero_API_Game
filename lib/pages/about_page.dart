import 'package:flutter/material.dart';
import '../navigation_drawer.dart' as appnav; // Use a prefix to avoid ambiguity

class AboutPage extends StatelessWidget {
  final String apiKey;

  const AboutPage({super.key, required this.apiKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About")),
      drawer: appnav.NavigationDrawer(
        currentPage: appnav.AppPage.about,
        apiKey: apiKey,
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
