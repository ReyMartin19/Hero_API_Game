import 'package:flutter/material.dart';

class BotDeckWidget extends StatelessWidget {
  final List<Map<String, dynamic>> deck;
  final int score;

  const BotDeckWidget({super.key, required this.deck, required this.score});

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
                "Bot Deck: ${deck.length} cards",
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
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(
                                hero['hover'] == true ? 0.8 : 0.5,
                              ),
                              spreadRadius: hero['hover'] == true ? 4 : 2,
                              blurRadius: hero['hover'] == true ? 10 : 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.question_mark, size: 160),
                            const SizedBox(width: 24),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "???",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _BotStatRow(label: "Intelligence"),
                                _BotStatRow(label: "Strength"),
                                _BotStatRow(label: "Speed"),
                                _BotStatRow(label: "Durability"),
                                _BotStatRow(label: "Power"),
                                _BotStatRow(label: "Combat"),
                              ],
                            ),
                          ],
                        ),
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

class _BotStatRow extends StatelessWidget {
  final String label;
  const _BotStatRow({required this.label});

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
        const SizedBox(
          width: 40,
          child: Text(
            "???",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
