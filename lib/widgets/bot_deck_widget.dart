import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BotDeckWidget extends StatelessWidget {
  final List<Map<String, dynamic>> deck;
  final int score;
  final int? removingIndex;

  const BotDeckWidget({
    super.key,
    required this.deck,
    required this.score,
    this.removingIndex,
  });

  // Track the previous deck length (not recommended for production, but works for this demo)
  static int _prevDeckLength = 0;

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final bool isMobile = MediaQuery.of(context).size.width < 700;
    final int prevDeckLength = _prevDeckLength;
    _prevDeckLength = deck.length;

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
                style: GoogleFonts.gruppo(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
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
                  itemCount: isMobile ? (deck.isNotEmpty ? 1 : 0) : deck.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final hero = deck[index];
                    // Use different padding for mobile vs desktop
                    final isMobileLayout = isMobile;
                    final isNew = index >= prevDeckLength;
                    final isRemoving = removingIndex == index;
                    return TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: isNew ? 0.0 : 1.0,
                        end: isRemoving ? 0.0 : 1.0,
                      ),
                      duration:
                          isRemoving
                              ? const Duration(milliseconds: 350)
                              : const Duration(milliseconds: 600),
                      curve: Curves.easeIn,
                      builder:
                          (context, opacity, child) =>
                              Opacity(opacity: opacity, child: child),
                      child: Padding(
                        padding:
                            isMobileLayout
                                ? const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 23,
                                )
                                : const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 8,
                                ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
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
                              // Replace the Icon with the asset image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  'assets/logo.png',
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
                              const SizedBox(width: 24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "???",
                                    style: GoogleFonts.gruppo(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF661FFF),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  _BotStatRow(label: "INT"),
                                  _BotStatRow(label: "STR"),
                                  _BotStatRow(label: "SPD"),
                                  _BotStatRow(label: "DRB"),
                                  _BotStatRow(label: "PWR"),
                                  _BotStatRow(label: "CMB"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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

class _BotStatRow extends StatelessWidget {
  final String label;
  const _BotStatRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 38, // Reduced width for label
          child: Text("$label:", style: GoogleFonts.gruppo(fontSize: 14)),
        ),
        const SizedBox(
          width: 32, // Reduced width for value
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
