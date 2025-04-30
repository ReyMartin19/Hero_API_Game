import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'navigation_drawer.dart' as appnav;
import 'hero_info.dart'; // <-- Add this import

class FavoritePageMobile extends StatefulWidget {
  final String apiKey;

  const FavoritePageMobile({super.key, required this.apiKey});

  @override
  State<FavoritePageMobile> createState() => _FavoritePageMobileState();
}

class _FavoritePageMobileState extends State<FavoritePageMobile> {
  List<Map<String, dynamic>> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await DatabaseHelper.instance.getFavoriteHeroes();
    setState(() {
      _favorites = favorites;
    });
  }

  Future<void> _removeFromFavorites(dynamic id) async {
    try {
      final int heroId = id is int ? id : int.tryParse(id.toString()) ?? 0;
      if (heroId == 0) throw Exception("Invalid hero ID");
      await DatabaseHelper.instance.removeFavoriteHero(heroId);
      setState(() {
        _favorites.removeWhere((hero) => hero['id'].toString() == heroId.toString());
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hero removed successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
      _loadFavorites();
    }
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
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () => _removeFromFavorites(hero['id']),
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
                              children: const [
                                Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Delete",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => HeroInfo(hero: hero),
                              ),
                            );
                          },
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
                              children: const [
                                Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF661FFF),
                                  size: 20,
                                ),
                                SizedBox(width: 4),
                                Text(
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
      appBar: AppBar(title: const Text("Favorite Heroes")),
      drawer: appnav.NavigationDrawer(
        currentPage: appnav.AppPage.favorites,
        apiKey: widget.apiKey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _favorites.isEmpty
            ? const Center(
                child: Text(
                  "No favorite heroes yet.",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : ListView.builder(
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  return _buildHeroCard(_favorites[index]);
                },
              ),
      ),
    );
  }
}