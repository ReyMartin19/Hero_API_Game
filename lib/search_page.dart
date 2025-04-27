import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'database_helper.dart'; // Add this import
import 'navigation_drawer.dart' as appnav; // Use a prefix to avoid ambiguity

class SearchPage extends StatefulWidget {
  final String apiKey;

  const SearchPage({super.key, required this.apiKey});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _heroes = [];
  bool _isLoading = false;

  Future<void> _searchHeroes(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _heroes = [];
    });

    final url = Uri.parse(
      'https://superheroapi.com/api/${widget.apiKey}/search/$query',
    );
    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['response'] == 'success') {
        setState(() {
          _heroes = List<Map<String, dynamic>>.from(data['results']);
        });
      } else {
        setState(() {
          _heroes = [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching heroes: $e');
      setState(() {
        _heroes = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addToFavorites(Map<String, dynamic> hero) async {
    // Check if the hero already exists in the favorites
    final existingFavorites = await DatabaseHelper.instance.getFavoriteHeroes();
    final isAlreadyFavorite = existingFavorites.any(
      (favorite) => favorite['id'] == hero['id'],
    ); // Compare by hero ID

    if (isAlreadyFavorite) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${hero['name']} is already in favorites!")),
      );
      return;
    }

    // Add the hero to favorites if not already added
    await DatabaseHelper.instance.addFavoriteHero(hero);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${hero['name']} added to favorites!")),
    );
  }

  Widget _buildStatRow(String label, dynamic value) {
    final int statValue = int.tryParse(value ?? '0') ?? 0;
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: statValue / 100, // Normalize to a percentage (0.0 - 1.0)
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
              minHeight: 10, // Adjusted thickness
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text("$statValue%", style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildHeroCard(Map<String, dynamic> hero) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              hero['image']['url'],
              height: 300, // Adjusted height
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => const Icon(Icons.broken_image, size: 80),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hero['name'],
                  style: const TextStyle(
                    fontSize: 14, // Adjusted font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatRow(
                  "🧠 Intelligence",
                  hero['powerstats']['intelligence'],
                ),
                _buildStatRow("💪 Strength", hero['powerstats']['strength']),
                _buildStatRow("⚡ Speed", hero['powerstats']['speed']),
                _buildStatRow(
                  "🛡️ Durability",
                  hero['powerstats']['durability'],
                ),
                _buildStatRow("🔥 Power", hero['powerstats']['power']),
                _buildStatRow("⚔️ Combat", hero['powerstats']['combat']),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox.shrink(), // Placeholder for alignment
              IconButton(
                icon: const Icon(Icons.star_border),
                onPressed: () => _addToFavorites(hero),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Heroes")),
      drawer: appnav.NavigationDrawer(
        currentPage: appnav.AppPage.search,
        apiKey: widget.apiKey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search for a hero",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchHeroes(_searchController.text.trim()),
                ),
              ),
              onSubmitted: (query) => _searchHeroes(query.trim()),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_heroes.isEmpty)
              const Center(child: Text("No heroes found."))
            else
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // Adjusted to display 4 cards per row
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio:
                        0.7, // Adjusted aspect ratio for better fit
                  ),
                  itemCount: _heroes.length,
                  itemBuilder: (context, index) {
                    return _buildHeroCard(_heroes[index]);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
