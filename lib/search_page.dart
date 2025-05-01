import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'database_helper.dart'; // Add this import
import 'navigation_drawer.dart' as appnav; // Use a prefix to avoid ambiguity
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'hero_info.dart'; // <-- Add this import

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
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${hero['name']} is already in favorites!")),
      );
      return;
    }

    // Add the hero to favorites if not already added
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
      ), // Increased border radius
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Added padding around the card
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(
                12,
              ), // Adjusted border radius for the image
              child: Image.network(
                hero['image']['url'],
                height: 150,
                width: 150,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => const Icon(Icons.broken_image, size: 40),
              ),
            ),
            const SizedBox(width: 16), // Added spacing between image and text
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
                  const SizedBox(
                    height: 30,
                  ), // Added spacing between name and buttons
                  Row(
                    children: [
                      Expanded(
                        child: _HoverButton(
                          onTap: () => _addToFavorites(hero),
                          icon: Icons.star_border,
                          label: "Favorite",
                          normalBg: const Color(0x1F661FFF),
                          hoverBg: const Color(0x33661FFF),
                          normalIconColor: const Color(0xFF661FFF),
                          hoverIconColor: Colors.white,
                          normalTextColor: const Color(0xFF661FFF),
                          hoverTextColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _HoverButton(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => HeroInfo(hero: hero),
                            );
                          },
                          icon: Icons.info_outline,
                          label: "More Info",
                          normalBg: const Color(0x1F661FFF),
                          hoverBg: const Color(0x33661FFF),
                          normalIconColor: const Color(0xFF661FFF),
                          hoverIconColor: Colors.white,
                          normalTextColor: const Color(0xFF661FFF),
                          hoverTextColor: Colors.white,
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
    final isMobile = MediaQuery.of(context).size.width < 700;
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
              constraints: const BoxConstraints(maxWidth: 800), // Set max width
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
              Expanded(
                child: Center(
                  child: LoadingAnimationWidget.fourRotatingDots(
                    color: Colors.blue,
                    size: 48,
                  ),
                ),
              )
            else if (_heroes.isEmpty)
              const Center(child: Text("No heroes found."))
            else
              Expanded(
                child:
                    isMobile
                        ? ListView.builder(
                          itemCount: _heroes.length,
                          itemBuilder: (context, index) {
                            return _buildHeroCard(_heroes[index]);
                          },
                        )
                        : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                crossAxisSpacing: 2,
                                mainAxisSpacing: 8,
                                childAspectRatio:
                                    1.8, // Wider to fit image + text layout
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

class _HoverButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color normalBg;
  final Color hoverBg;
  final Color normalIconColor;
  final Color hoverIconColor;
  final Color normalTextColor;
  final Color hoverTextColor;

  // ignore: use_super_parameters
  const _HoverButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.normalBg,
    required this.hoverBg,
    required this.normalIconColor,
    required this.hoverIconColor,
    required this.normalTextColor,
    required this.hoverTextColor,
    Key? key,
  }) : super(key: key);

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: _hovered ? widget.hoverBg : widget.normalBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color:
                    _hovered ? widget.hoverIconColor : widget.normalIconColor,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 10,
                  color:
                      _hovered ? widget.hoverTextColor : widget.normalTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
