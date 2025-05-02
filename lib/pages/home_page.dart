import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../navigation_drawer.dart' as appnav; // Use a prefix to avoid ambiguity
import 'mobile/home_page_mobile.dart'; // Import mobile layout
import 'battle_page.dart'; // <-- Add this import
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HomePage extends StatefulWidget {
  final String apiKey;

  const HomePage({super.key, required this.apiKey});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? heroData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRandomHero();
  }

  Future<void> _fetchRandomHero() async {
    final randomId = Random().nextInt(731) + 1;
    final url = Uri.parse(
      'https://superheroapi.com/api/${widget.apiKey}/$randomId',
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['response'] == 'success') {
        setState(() {
          heroData = data;
          isLoading = false;
        });
      } else {
        setState(() {
          heroData = null;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        heroData = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 700;

    if (isNarrow) {
      // Always delegate to mobile layout, let HomePageMobile handle the loader
      return HomePageMobile(
        apiKey: widget.apiKey,
        heroData: heroData,
        isLoading: isLoading,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hero of the Day",
          style: GoogleFonts.gruppo(fontWeight: FontWeight.w900),
        ),
      ),
      drawer: appnav.NavigationDrawer(
        currentPage: appnav.AppPage.home,
        apiKey: widget.apiKey,
      ),
      body: isLoading
          ? Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: Colors.blue,
                size: 48,
              ),
            )
          : heroData == null
              ? const Center(child: Text("Failed to load hero."))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            heroData!['image']['url'],
                            height: 470,
                            width: 300,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) =>
                                    const Icon(Icons.error, size: 80),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 600,
                                ),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      // ignore: deprecated_member_use
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      heroData!['name'],
                                      style: GoogleFonts.gruppo(
                                        fontSize: 40,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF661FFF),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Work: ${heroData!['work']['occupation'] ?? 'N/A'}",
                                      style: GoogleFonts.gruppo(
                                        fontSize: 18,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 400,
                                ),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      // ignore: deprecated_member_use
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Power Stats",
                                      style: GoogleFonts.gruppo(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _buildPowerStats(heroData!['powerstats']),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Move the button here, outside the powerstats container
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 40,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 5,
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              BattlePage(apiKey: widget.apiKey),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.sports_martial_arts,
                                      size: 28,
                                      color: Color(0xFF661FFF),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'BATTLE',
                                      style: GoogleFonts.gruppo(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildPowerStats(Map<String, dynamic> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatRow("🧠", stats['intelligence']),
        _buildStatRow("💪", stats['strength']),
        _buildStatRow("⚡", stats['speed']),
        _buildStatRow("🛡️", stats['durability']),
        _buildStatRow("🔥", stats['power']),
        _buildStatRow("⚔️", stats['combat']),
      ],
    );
  }

  Widget _buildStatRow(String emoji, dynamic value) {
    final int statValue = int.tryParse(value ?? '0') ?? 0;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive: use 60% of available width for the bar, min 80, max 400
        double barWidth = (constraints.maxWidth * 0.6).clamp(80.0, 400.0);
        return Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            SizedBox(
              width: barWidth,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: statValue / 100),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.grey[300],
                      color: Colors.blue,
                      minHeight: 10,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text("$statValue%", style: const TextStyle(fontSize: 14)),
          ],
        );
      },
    );
  }
}
