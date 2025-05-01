import 'package:flutter/material.dart';

class ResultCardContainer extends StatelessWidget {
  final Map<String, dynamic>? selectedUserCard;
  final Map<String, dynamic>? selectedBotCard;
  final int userDeckLength;
  final int botDeckLength;
  final String? battleResult;
  final bool showDice;
  final bool isUserTurn;
  final bool isDiceSpinning;
  final int diceResult;
  final VoidCallback onRollDice;
  final Widget Function() buildDiceOrResult;
  final bool isInitial; // Add this flag to indicate initial state
  final bool showRestart;
  final VoidCallback? onRestart;

  const ResultCardContainer({
    super.key,
    required this.selectedUserCard,
    required this.selectedBotCard,
    required this.userDeckLength,
    required this.botDeckLength,
    required this.battleResult,
    required this.showDice,
    required this.isUserTurn,
    required this.isDiceSpinning,
    required this.diceResult,
    required this.onRollDice,
    required this.buildDiceOrResult,
    this.isInitial = false,
    this.showRestart = false,
    this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    int parseStat(dynamic value) => int.tryParse(value?.toString() ?? '0') ?? 0;

    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    final statLabels = [
      "Intelligence",
      "Strength",
      "Speed",
      "Durability",
      "Power",
      "Combat",
    ];
    final statKeys = [
      "intelligence",
      "strength",
      "speed",
      "durability",
      "power",
      "combat",
    ];

    // Set a fixed width for stats and labels for alignment
    final double statNumberWidth = isSmallScreen ? 28 : 40;
    final double statLabelWidth = isSmallScreen ? 70 : 110;
    final double statRowHeight = isSmallScreen ? 22 : 32;
    final double statRowMargin = 4;
    final double statFontSize = isSmallScreen ? 15 : 15;
    final double statLabelFontSize = isSmallScreen ? 14 : 14;

    Widget userImage =
        selectedUserCard != null
            ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                selectedUserCard!['image']['url'],
                width: 50,
                height: 50, // Increased height
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => const Icon(Icons.broken_image, size: 60),
              ),
            )
            : Container(
              width: 50,
              height: 50, // Increased height
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person_outline,
                size: 30,
                color: Colors.grey,
              ),
            );

    Widget botImage =
        selectedBotCard != null
            ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                selectedBotCard!['image']['url'],
                width: 50,
                height: 50, // Increased height
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => const Icon(Icons.broken_image, size: 60),
              ),
            )
            : Container(
              width: 50,
              height: 50, // Increased height
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                size: 30,
                color: Colors.grey,
              ),
            );

    // Helper to get name or placeholder
    String getCardName(Map<String, dynamic>? card, {bool isBot = false}) {
      if (card != null &&
          card['name'] != null &&
          card['name'].toString().trim().isNotEmpty) {
        return card['name'];
      }
      return isBot ? "Bot Card" : "Your Card";
    }

    Widget userStats = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final key in statKeys)
          Container(
            height: statRowHeight,
            margin: EdgeInsets.symmetric(vertical: statRowMargin / 2),
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: statNumberWidth,
                child: Text(
                  selectedUserCard != null
                      ? "${parseStat(selectedUserCard!['powerstats'][key])}"
                      : "--",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: statFontSize,
                    color:
                        selectedUserCard != null && selectedBotCard != null
                            ? (parseStat(selectedUserCard!['powerstats'][key]) >
                                    parseStat(
                                      selectedBotCard!['powerstats'][key],
                                    )
                                ? Colors.green
                                : Colors.black)
                            : Colors.black,
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    Widget botStats = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final key in statKeys)
          Container(
            height: statRowHeight,
            margin: EdgeInsets.symmetric(vertical: statRowMargin / 2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: statNumberWidth,
                child: Text(
                  selectedBotCard != null
                      ? "${parseStat(selectedBotCard!['powerstats'][key])}"
                      : "--",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: statFontSize,
                    color:
                        selectedUserCard != null && selectedBotCard != null
                            ? (parseStat(selectedBotCard!['powerstats'][key]) >
                                    parseStat(
                                      selectedUserCard!['powerstats'][key],
                                    )
                                ? Colors.green
                                : Colors.black)
                            : Colors.black,
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    Widget statLabelColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (final label in statLabels)
          Container(
            height: statRowHeight,
            margin: EdgeInsets.symmetric(vertical: statRowMargin / 2),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: statLabelWidth,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 2 : 3,
                  vertical: isSmallScreen ? 1 : 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x1F661FFF), // #661FFF at 12% opacity
                  borderRadius: BorderRadius.circular(isSmallScreen ? 4 : 6),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF661FFF), // #661FFF at 100% opacity
                    fontSize: statLabelFontSize,
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main stats row with card counts above images
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User image and name
                Column(
                  children: [
                    const SizedBox(height: 2),
                    userImage,
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 100,
                      child: Text(
                        getCardName(selectedUserCard),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 2),
                // User stats or placeholder (fixed width)
                userStats,
                const SizedBox(width: 4),
                // Stat labels with blue background (fixed width)
                statLabelColumn,
                const SizedBox(width: 4),
                // Bot stats or placeholder (fixed width)
                botStats,
                const SizedBox(width: 2),
                // Bot image and name
                Column(
                  children: [
                    const SizedBox(height: 4),
                    botImage,
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 100,
                      child: Text(
                        getCardName(selectedBotCard, isBot: true),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Result, dice/spin, and additional cards info
            Column(
              children: [
                Text(
                  battleResult ?? "",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                if (showRestart)
                  ElevatedButton(
                    onPressed: onRestart,
                    child: const Text("Restart"),
                  )
                else if (showDice && isUserTurn)
                  ElevatedButton(
                    onPressed: onRollDice,
                    child: const Icon(Icons.casino),
                  )
                else if (showDice && !isUserTurn)
                  const Text(
                    "Bot is spinning...",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                buildDiceOrResult(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
