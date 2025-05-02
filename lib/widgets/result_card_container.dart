import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultCardContainer extends StatefulWidget {
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
  State<ResultCardContainer> createState() => _ResultCardContainerState();
}

class _ResultCardContainerState extends State<ResultCardContainer>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _revealAnimation;
  late AnimationController _botController;
  late Animation<double> _botRevealAnimation;
  late AnimationController _statController;
  late Animation<Offset> _statSlideAnimation = AlwaysStoppedAnimation(
    Offset.zero,
  );
  late AnimationController _botStatController;
  late Animation<Offset> _botStatSlideAnimation = AlwaysStoppedAnimation(
    Offset.zero,
  );
  Map<String, dynamic>? _lastUserCard;
  Map<String, dynamic>? _lastBotCard;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _revealAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _botController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _botRevealAnimation = CurvedAnimation(
      parent: _botController,
      curve: Curves.easeInOut,
    );
    _statController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _statSlideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _statController, curve: Curves.easeOut));
    _botStatController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _botStatSlideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _botStatController, curve: Curves.easeOut),
    );
    if (widget.selectedUserCard != null) {
      _controller.forward();
      _statController.forward();
      _lastUserCard = widget.selectedUserCard;
    }
    if (widget.selectedBotCard != null) {
      _botController.forward();
      _botStatController.forward();
      _lastBotCard = widget.selectedBotCard;
    }
  }

  @override
  void didUpdateWidget(ResultCardContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // User card animation
    if (widget.selectedUserCard != null &&
        widget.selectedUserCard != _lastUserCard) {
      _controller.reset();
      _revealAnimation = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      );
      _controller.forward();
      _statController.reset();
      _statSlideAnimation = Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _statController, curve: Curves.easeOut),
      );
      _statController.forward();
      _lastUserCard = widget.selectedUserCard;
    }
    if (widget.selectedUserCard == null && oldWidget.selectedUserCard != null) {
      _controller.reset();
      _revealAnimation = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      );
      _statController.reset();
      _statSlideAnimation = Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _statController, curve: Curves.easeOut),
      );
      _lastUserCard = null;
    }
    // Bot card animation
    if (widget.selectedBotCard != null &&
        widget.selectedBotCard != _lastBotCard) {
      _botController.reset();
      _botRevealAnimation = CurvedAnimation(
        parent: _botController,
        curve: Curves.easeInOut,
      );
      _botController.forward();
      _botStatController.reset();
      _botStatSlideAnimation = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _botStatController, curve: Curves.easeOut),
      );
      _botStatController.forward();
      _lastBotCard = widget.selectedBotCard;
    }
    if (widget.selectedBotCard == null && oldWidget.selectedBotCard != null) {
      _botController.reset();
      _botRevealAnimation = CurvedAnimation(
        parent: _botController,
        curve: Curves.easeInOut,
      );
      _botStatController.reset();
      _botStatSlideAnimation = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _botStatController, curve: Curves.easeOut),
      );
      _lastBotCard = null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _botController.dispose();
    _statController.dispose();
    _botStatController.dispose();
    super.dispose();
  }

  Widget _buildUserImage() {
    final card = widget.selectedUserCard;
    if (card == null) {
      return Container(
        width: 70,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8), // Add border radius
        ),
        child: const Icon(Icons.person, size: 60, color: Colors.grey),
      );
    }
    return RevealImage(
      imageUrl: card['image']['url'],
      animation: _revealAnimation,
      width: 70,
      height: 160,
    );
  }

  Widget _buildBotImage() {
    final card = widget.selectedBotCard;
    if (card == null) {
      return Container(
        width: 70,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8), // Already present
        ),
        child: const Icon(
          Icons.smart_toy_outlined,
          size: 30,
          color: Colors.grey,
        ),
      );
    }
    return RevealImage(
      imageUrl: card['image']['url'],
      animation: _botRevealAnimation,
      width: 70,
      height: 160,
    );
  }

  @override
  Widget build(BuildContext context) {
    int parseStat(dynamic value) => int.tryParse(value?.toString() ?? '0') ?? 0;

    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    final statLabels = ["INT", "STR", "SPD", "DRB", "PWR", "CMB"];
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
    final double statLabelWidth = isSmallScreen ? 70 : 70;
    final double statRowHeight = isSmallScreen ? 22 : 32;
    final double statRowMargin = 4;
    final double statFontSize = isSmallScreen ? 15 : 15;
    final double statLabelFontSize = isSmallScreen ? 14 : 14;

    Widget botImage = _buildBotImage();

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
                child: SlideTransition(
                  position: _statSlideAnimation,
                  child: Text(
                    widget.selectedUserCard != null
                        ? "${parseStat(widget.selectedUserCard!['powerstats'][key])}"
                        : " ",
                    textAlign: TextAlign.right,
                    style: GoogleFonts.gruppo(
                      fontWeight: FontWeight.bold,
                      fontSize: statFontSize,
                      color:
                          widget.selectedUserCard != null &&
                                  widget.selectedBotCard != null
                              ? (parseStat(
                                        widget
                                            .selectedUserCard!['powerstats'][key],
                                      ) >
                                      parseStat(
                                        widget
                                            .selectedBotCard!['powerstats'][key],
                                      )
                                  ? Colors.green
                                  : Colors.black)
                              : Colors.black,
                    ),
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
                child: SlideTransition(
                  position: _botStatSlideAnimation,
                  child: Text(
                    widget.selectedBotCard != null
                        ? "${parseStat(widget.selectedBotCard!['powerstats'][key])}"
                        : " ",
                    textAlign: TextAlign.left,
                    style: GoogleFonts.gruppo(
                      fontWeight: FontWeight.bold,
                      fontSize: statFontSize,
                      color:
                          widget.selectedUserCard != null &&
                                  widget.selectedBotCard != null
                              ? (parseStat(
                                        widget
                                            .selectedBotCard!['powerstats'][key],
                                      ) >
                                      parseStat(
                                        widget
                                            .selectedUserCard!['powerstats'][key],
                                      )
                                  ? Colors.green
                                  : Colors.black)
                              : Colors.black,
                    ),
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
                  style: GoogleFonts.gruppo(
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

    Widget resultWidget;
    if (widget.battleResult == "You Win this Round!" ||
        widget.battleResult == "Bot Wins this Round!" ||
        widget.battleResult == "It's a Draw!") {
      resultWidget = Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0x1F661FFF), // #661FFF at 12% opacity (0x1F = 12%)
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          widget.battleResult!,
          style: GoogleFonts.gruppo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else if (widget.battleResult != null) {
      resultWidget = Text(
        widget.battleResult!,
        style: GoogleFonts.gruppo(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      );
    } else {
      resultWidget = const SizedBox.shrink();
    }

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
                    _buildUserImage(),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 100,
                      child: Text(
                        getCardName(widget.selectedUserCard),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.gruppo(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: const Color(0xFF661FFF), // Set name color to #661FFF
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
                        getCardName(widget.selectedBotCard, isBot: true),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.gruppo(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: const Color(0xFF661FFF), // Set name color to #661FFF
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
                resultWidget,
                const SizedBox(height: 10),
                if (widget.showRestart)
                  ElevatedButton(
                    onPressed: widget.onRestart,
                    child: const Text("Restart"),
                  )
                else if (widget.showDice && widget.isUserTurn)
                  ElevatedButton(
                    onPressed: widget.onRollDice,
                    child: const Icon(Icons.casino),
                  )
                else if (widget.showDice && !widget.isUserTurn)
                  const Text(
                    "Bot is spinning...",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                widget.buildDiceOrResult(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Animated image reveal widget
class RevealImage extends StatelessWidget {
  final String imageUrl;
  final Animation<double> animation;
  final double width;
  final double height;

  const RevealImage({
    super.key,
    required this.imageUrl,
    required this.animation,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: animation.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        clipBehavior: Clip.hardEdge,
        child: Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => const Icon(Icons.broken_image, size: 60),
        ),
      ),
    );
  }
}
