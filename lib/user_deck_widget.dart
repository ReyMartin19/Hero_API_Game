import 'package:flutter/material.dart';

class UserDeckWidget extends StatelessWidget {
  final List<Map<String, dynamic>> deck;
  final int score;
  final bool decksReady;
  final void Function(Map<String, dynamic> hero) onCardTap;

  const UserDeckWidget({
    super.key,
    required this.deck,
    required this.score,
    required this.decksReady,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Your Deck: ${deck.length} cards",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              SizedBox(
                height: 200,
                child: ListView.separated(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: deck.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final hero = deck[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          bool isHovered = hero['hover'] == true;
                          return MouseRegion(
                            onEnter: (_) => setState(() => hero['hover'] = true),
                            onExit: (_) => setState(() => hero['hover'] = false),
                            child: GestureDetector(
                              onTap: decksReady ? () => onCardTap(hero) : null,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isHovered ? Colors.blue[50] : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(
                                        isHovered ? 0.8 : 0.5,
                                      ),
                                      spreadRadius: isHovered ? 4 : 2,
                                      blurRadius: isHovered ? 10 : 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                  border: isHovered
                                      ? Border.all(color: Colors.blue, width: 2)
                                      : null,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        hero['image']['url'],
                                        width: 160,
                                        height: 160,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.broken_image,
                                          size: 100,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          hero['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        _StatRow(label: "Intelligence", value: hero['powerstats']['intelligence']),
                                        _StatRow(label: "Strength", value: hero['powerstats']['strength']),
                                        _StatRow(label: "Speed", value: hero['powerstats']['speed']),
                                        _StatRow(label: "Durability", value: hero['powerstats']['durability']),
                                        _StatRow(label: "Power", value: hero['powerstats']['power']),
                                        _StatRow(label: "Combat", value: hero['powerstats']['combat']),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              // Left arrow
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: const Icon(Icons.arrow_left),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      scrollController.animateTo(
                        scrollController.offset - 200,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
              // Right arrow
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: const Icon(Icons.arrow_right),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      scrollController.animateTo(
                        scrollController.offset + 200,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final dynamic value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            "$label:",
            style: const TextStyle(fontSize: 14),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            "${value ?? 'N/A'}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
