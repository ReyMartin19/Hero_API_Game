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
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    scrollbars: false, // Disable the horizontal scrollbar
                  ),
                  child: ListView.separated(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    itemCount: deck.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final hero = deck[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 8,
                        ),
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            bool isHovered = hero['hover'] == true;
                            return MouseRegion(
                              onEnter:
                                  (_) => setState(() => hero['hover'] = true),
                              onExit:
                                  (_) => setState(() => hero['hover'] = false),
                              child: GestureDetector(
                                onTap:
                                    decksReady ? () => onCardTap(hero) : null,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color:
                                        isHovered
                                            ? Colors.blue[50]
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        // ignore: deprecated_member_use
                                        color: Colors.grey.withOpacity(
                                          isHovered ? 0.8 : 0.5,
                                        ),
                                        spreadRadius: isHovered ? 4 : 2,
                                        blurRadius: isHovered ? 10 : 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          hero['image']['url'],
                                          width: 160,
                                          height: 160,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (_, __, ___) => const Icon(
                                                Icons.broken_image,
                                                size: 100,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            hero['name'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          _StatRow(
                                            label: "INT",
                                            value:
                                                hero['powerstats']['intelligence'],
                                          ),
                                          _StatRow(
                                            label: "STR",
                                            value:
                                                hero['powerstats']['strength'],
                                          ),
                                          _StatRow(
                                            label: "SPD",
                                            value: hero['powerstats']['speed'],
                                          ),
                                          _StatRow(
                                            label: "DRB",
                                            value:
                                                hero['powerstats']['durability'],
                                          ),
                                          _StatRow(
                                            label: "PWR",
                                            value: hero['powerstats']['power'],
                                          ),
                                          _StatRow(
                                            label: "CMB",
                                            value: hero['powerstats']['combat'],
                                          ),
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
              ),
              // Left arrow
              if (MediaQuery.of(context).size.width >= 700)
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
              if (MediaQuery.of(context).size.width >= 700)
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
          width: 38, // Reduced width for label
          child: Text("$label:", style: const TextStyle(fontSize: 14)),
        ),
        SizedBox(
          width: 32, // Reduced width for value
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
