import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../navigation_drawer.dart' as appnav; // Use a prefix to avoid ambiguity
import 'mobile/favorite_page_mobile.dart'; // <-- Add this import
import '../widgets/hero_info.dart'; // <-- Add this import
import 'package:google_fonts/google_fonts.dart';

class FavoritePage extends StatefulWidget {
  final String apiKey;

  const FavoritePage({super.key, required this.apiKey});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
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

      debugPrint('Attempting to remove hero ID: $heroId');

      // 1. First remove from database
      await DatabaseHelper.instance.removeFavoriteHero(heroId);

      // 2. Then update UI
      setState(() {
        final initialCount = _favorites.length;
        _favorites.removeWhere(
          (hero) => hero['id'].toString() == heroId.toString(),
        );
        debugPrint(
          'UI update - Removed: ${initialCount - _favorites.length} items',
        );
      });

      // 3. Verify by reloading from database
      final updatedFavorites =
          await DatabaseHelper.instance.getFavoriteHeroes();
      debugPrint('Database now contains ${updatedFavorites.length} favorites');

      if (updatedFavorites.length == _favorites.length) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Hero removed successfully!")),
        );
      } else {
        // If mismatch, sync UI with database
        setState(() => _favorites = updatedFavorites);
        throw Exception('Database and UI out of sync');
      }
    } catch (e) {
      debugPrint("Deletion error: $e");
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      // Reload from database on error
      _loadFavorites();
    }
  }

  Widget _buildHeroCard(Map<String, dynamic> hero) {
    return _HoverGrow(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      style: GoogleFonts.gruppo(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: const Color(0xFF661FFF),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 30,
                    ), // Spacing between name and buttons
                    Row(
                      children: [
                        Expanded(
                          child: _HoverButton(
                            onTap: () => _removeFromFavorites(hero['id']),
                            icon: Icons.delete,
                            label: "Delete",
                            normalBg: const Color(0x1F661FFF),
                            hoverBg: const Color(0x33FF0000),
                            normalIconColor: Colors.red,
                            hoverIconColor: Colors.white,
                            normalTextColor: Colors.red,
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
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => HeroInfo(hero: hero),
                                ),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    if (isMobile) {
      return FavoritePageMobile(apiKey: widget.apiKey);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Favorite Heroes",
          style: GoogleFonts.gruppo(fontWeight: FontWeight.w900),
        ),
      ),
      drawer: appnav.NavigationDrawer(
        currentPage: appnav.AppPage.favorites,
        apiKey: widget.apiKey, // <-- use widget.apiKey here
      ),
      body:
          _favorites.isEmpty
              ? Center(
                child: Text(
                  "No favorite heroes yet.",
                  style: GoogleFonts.gruppo(fontWeight: FontWeight.w900),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.8,
                  ),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    return _buildHeroCard(_favorites[index]);
                  },
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

class _HoverGrow extends StatefulWidget {
  final Widget child;
  const _HoverGrow({required this.child});

  @override
  State<_HoverGrow> createState() => _HoverGrowState();
}

class _HoverGrowState extends State<_HoverGrow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
