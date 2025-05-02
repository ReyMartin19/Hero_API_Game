import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../navigation_drawer.dart' as appnav; // Use a prefix to avoid ambiguity

class AboutPage extends StatelessWidget {
  final String apiKey;

  const AboutPage({super.key, required this.apiKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About",
          style: GoogleFonts.gruppo(fontWeight: FontWeight.w900),
        ),
      ),
      drawer: appnav.NavigationDrawer(
        currentPage: appnav.AppPage.about,
        apiKey: apiKey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "About Hero Games",
              style: GoogleFonts.gruppo(
                fontWeight: FontWeight.w900,
                fontSize: 24,
                color: const Color(0xFF661FFF),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Hero Games is a fun and interactive app where you can search for superheroes, "
              "add them to your favorites, and battle with them. Powered by the Superhero API, "
              "this app brings your favorite heroes to life!",
              style: GoogleFonts.gruppo(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Features:",
              style: GoogleFonts.gruppo(
                fontWeight: FontWeight.w900,
                fontSize: 24,
                color: const Color(0xFF661FFF),
              ),
            ),
            const SizedBox(height: 8),
            const Text("- Search for superheroes using the Superhero API."),
            const Text("- Add your favorite heroes to a favorites list."),
            const Text("- Battle with heroes and compare their stats."),
            const Text("- Save your progress and continue anytime."),
            const SizedBox(height: 16),
            Text(
              "Developed by Rey Agluya and members of the Hero Games team.",
              style: GoogleFonts.gruppo(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
