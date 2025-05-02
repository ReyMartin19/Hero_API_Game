import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeroInfo extends StatelessWidget {
  final Map<String, dynamic> hero;
  const HeroInfo({super.key, required this.hero});

  @override
  Widget build(BuildContext context) {
    final powerstats = hero['powerstats'] ?? {};
    final biography = hero['biography'] ?? {};
    final appearance = hero['appearance'] ?? {};
    final work = hero['work'] ?? {};
    final connections = hero['connections'] ?? {};

    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          hero['name'] ?? 'Hero Info',
          style: GoogleFonts.gruppo(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Container(
        color: const Color(0xFFF5F6FA),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child:
              isWide
                  ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column: image, name, powerstats
                      SizedBox(
                        width: 340,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.network(
                                  hero['image']?['url'] ?? '',
                                  width: 300,
                                  height: 300,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => const Icon(
                                        Icons.broken_image,
                                        size: 80,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Center(
                              child: Text(
                                hero['name'] ?? 'Unknown',
                                style: GoogleFonts.gruppo(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF661FFF),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _SectionCard(
                              title: "Powerstats",
                              child: _PowerStatsList(stats: powerstats),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      // Right column: biography, appearance, work, connections
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionCard(
                              title: "Biography",
                              child: _InfoList(data: biography),
                            ),
                            const SizedBox(height: 18),
                            _SectionCard(
                              title: "Appearance",
                              child: _InfoList(data: appearance),
                            ),
                            const SizedBox(height: 18),
                            _SectionCard(
                              title: "Work",
                              child: _InfoList(data: work),
                            ),
                            const SizedBox(height: 18),
                            _SectionCard(
                              title: "Connections",
                              child: _InfoList(data: connections),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Hero image
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.network(
                            hero['image']?['url'] ?? '',
                            width: 180,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) =>
                                    const Icon(Icons.broken_image, size: 80),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Hero name
                      Center(
                        child: Text(
                          hero['name'] ?? 'Unknown',
                          style: GoogleFonts.gruppo(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF661FFF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Divider
                      const Divider(height: 32, thickness: 1.2),
                      // Powerstats section
                      _SectionCard(
                        title: "Powerstats",
                        child: _PowerStatsList(stats: powerstats),
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: "Biography",
                        child: _InfoList(data: biography),
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: "Appearance",
                        child: _InfoList(data: appearance),
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(title: "Work", child: _InfoList(data: work)),
                      const SizedBox(height: 18),
                      _SectionCard(
                        title: "Connections",
                        child: _InfoList(data: connections),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
        ),
      ),
    );
  }
}

// Section card for visual grouping
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_SectionTitle(title), const SizedBox(height: 8), child],
        ),
      ),
    );
  }
}

// Section title
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.gruppo(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: Color(0xFF661FFF),
      ),
    );
  }
}

// Redesigned powerstats with icons and alignment
class _PowerStatsList extends StatelessWidget {
  final Map stats;
  const _PowerStatsList({required this.stats});
  static const _statIcons = {
    "intelligence": "🧠",
    "strength": "💪",
    "speed": "⚡",
    "durability": "🛡️",
    "power": "🔥",
    "combat": "⚔️",
  };
  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty)
      // ignore: curly_braces_in_flow_control_structures
      return Text(
        "No data.",
        style: GoogleFonts.gruppo(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.w900,
        ),
      );
    return Column(
      children:
          _statIcons.entries.map((entry) {
            final label = entry.key[0].toUpperCase() + entry.key.substring(1);
            final value = stats[entry.key]?.toString() ?? 'N/A';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      entry.value,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  SizedBox(
                    width: 110,
                    child: Text(
                      label,
                      style: GoogleFonts.gruppo(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.gruppo(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}

// ...existing _InfoList class...
class _InfoList extends StatelessWidget {
  final Map data;
  const _InfoList({required this.data});
  @override
  Widget build(BuildContext context) {
    if (data.isEmpty)
      // ignore: curly_braces_in_flow_control_structures
      return Text(
        "No data.",
        style: GoogleFonts.gruppo(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.w900,
        ),
      );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          data.entries.map<Widget>((entry) {
            final label = entry.key.toString();
            final value =
                entry.value is List
                    ? (entry.value as List).join(', ')
                    : entry.value?.toString() ?? 'N/A';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      label[0].toUpperCase() + label.substring(1),
                      style: GoogleFonts.gruppo(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      value,
                      style: GoogleFonts.gruppo(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
