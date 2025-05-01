import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../database_helper.dart';
import '../../navigation_drawer.dart' as appnav;

class SearchPageMobile extends StatefulWidget {
  final String apiKey;

  const SearchPageMobile({super.key, required this.apiKey});

  @override
  State<SearchPageMobile> createState() => _SearchPageMobileState();
}

class _SearchPageMobileState extends State<SearchPageMobile> {
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
    final existingFavorites = await DatabaseHelper.instance.getFavoriteHeroes();
    final isAlreadyFavorite = existingFavorites.any(
      (favorite) => favorite['id'] == hero['id'],
    );

    if (isAlreadyFavorite) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${hero['name']} is already in favorites!")),
      );
      return;
    }

    await DatabaseHelper.instance.addFavoriteHero(hero);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${hero['name']} added to favorites!")),
    );
  }

  Widget _buildHeroCard(Map<String, dynamic> hero) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                hero['image']['url'],
                height: 150,
                width: 150,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, size: 40),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hero['name'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x1F661FFF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.star_border,
                                  color: Color(0xFF661FFF),
                                ),
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _addToFavorites(hero),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                "Favorite",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF661FFF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x1F661FFF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF661FFF),
                                ),
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  debugPrint(
                                    "More Info clicked for ${hero['name']}",
                                  );
                                },
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                "More Info",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF661FFF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: "Search for a hero",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed:
                        () => _searchHeroes(_searchController.text.trim()),
                  ),
                ),
                onSubmitted: (query) => _searchHeroes(query.trim()),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_heroes.isEmpty)
              const Center(child: Text("No heroes found."))
            else
              Expanded(
                child: ListView.builder(
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
