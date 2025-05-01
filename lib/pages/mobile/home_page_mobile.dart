import 'package:flutter/material.dart';
import '../../navigation_drawer.dart' as appnav; // <-- Add this import

class HomePageMobile extends StatelessWidget {
  final String apiKey;
  final Map<String, dynamic>? heroData;
  final bool isLoading;

  const HomePageMobile({
    super.key,
    required this.apiKey,
    required this.heroData,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hero of the Day")),
      drawer: appnav.NavigationDrawer(
        // <-- Add this line
        currentPage: appnav.AppPage.home,
        apiKey: apiKey,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
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
                    child: ListView(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            heroData!['image']['url'],
                            height: 300,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) =>
                                    const Icon(Icons.error, size: 80),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 300),
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
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                "Work: ${heroData!['work']['occupation'] ?? 'N/A'}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 300),
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
                              const Text(
                                "Power Stats",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _buildPowerStats(heroData!['powerstats']),
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
        double barWidth = (constraints.maxWidth * 0.6).clamp(80.0, 400.0);
        return Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            SizedBox(
              width: barWidth,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: statValue / 100,
                  backgroundColor: Colors.grey[300],
                  color: Colors.blue,
                  minHeight: 10,
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
