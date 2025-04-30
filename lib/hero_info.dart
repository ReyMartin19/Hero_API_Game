import 'package:flutter/material.dart';

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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(hero['name'] ?? 'Hero Info'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  hero['image']?['url'] ?? '',
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 80),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                hero['name'] ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle("Powerstats"),
            _StatList(stats: powerstats),
            const SizedBox(height: 16),
            _SectionTitle("Biography"),
            _InfoList(data: biography),
            const SizedBox(height: 16),
            _SectionTitle("Appearance"),
            _InfoList(data: appearance),
            const SizedBox(height: 16),
            _SectionTitle("Work"),
            _InfoList(data: work),
            const SizedBox(height: 16),
            _SectionTitle("Connections"),
            _InfoList(data: connections),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF661FFF),
      ),
    );
  }
}

class _StatList extends StatelessWidget {
  final Map stats;
  const _StatList({required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const Text("No data.");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: stats.entries.map<Widget>((entry) {
        final label = entry.key.toString();
        final value = entry.value?.toString() ?? 'N/A';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              SizedBox(width: 120, child: Text(label[0].toUpperCase() + label.substring(1))),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _InfoList extends StatelessWidget {
  final Map data;
  const _InfoList({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Text("No data.");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.map<Widget>((entry) {
        final label = entry.key.toString();
        final value = entry.value is List
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
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(child: Text(value)),
            ],
          ),
        );
      }).toList(),
    );
  }
}