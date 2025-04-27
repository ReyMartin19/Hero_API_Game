import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'database_helper.dart';
import 'navigation_drawer.dart' as appnav; // Use a prefix to avoid ambiguity
import 'user_deck_widget.dart';
import 'bot_deck_widget.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'result_card_container.dart';

class BattlePage extends StatefulWidget {
  final String apiKey;

  const BattlePage({super.key, required this.apiKey});

  @override
  State<BattlePage> createState() => _BattlePageState();
}

class _BattlePageState extends State<BattlePage> {
  List<Map<String, dynamic>> userDeck = [];
  List<Map<String, dynamic>> botDeck = [];
  Set<int> bannedCardIds = {}; // Ban list to store used card IDs
  bool isLoadingDeck = false;
  bool decksReady = false;
  bool isLoadingAdditionalCards =
      false; // Flag to track additional card loading

  Map<String, dynamic>? selectedUserCard;
  Map<String, dynamic>? selectedBotCard;
  String? battleResult;
  int userScore = 0;
  int botScore = 0;

  bool showDice = false;
  bool isUserTurn = false; // To track whose turn it is to spin the dice
  int diceResult = 0; // Result of the dice roll
  bool isDiceSpinning = false; // Add a flag to track dice spinning state

  @override
  void initState() {
    super.initState();
    _loadGameState();
  }

  Future<void> _loadGameState() async {
    final gameState = await DatabaseHelper.instance.loadGameState();

    setState(() {
      userDeck = List<Map<String, dynamic>>.from(gameState['userDeck'] ?? []);
      botDeck = List<Map<String, dynamic>>.from(gameState['botDeck'] ?? []);
      userScore = gameState['userScore'] ?? 0;
      botScore = gameState['botScore'] ?? 0;
      decksReady = userDeck.isNotEmpty && botDeck.isNotEmpty;
    });

    // If decks are empty or invalid, reset the game state to show the distribution button
    if (userDeck.isEmpty || botDeck.isEmpty) {
      setState(() {
        userDeck = [];
        botDeck = [];
        userScore = 0;
        botScore = 0;
        decksReady = false;
      });
    }
  }

  Future<void> _saveGameState() async {
    await DatabaseHelper.instance.saveGameState(
      userDeck: userDeck,
      botDeck: botDeck,
      userScore: userScore,
      botScore: botScore,
    );
  }

  Future<void> _generateDeck() async {
    setState(() {
      isLoadingDeck = true;
      decksReady = false;
    });

    try {
      generateValidCards() async {
        final List<Map<String, dynamic>> validCards = [];
        final Set<int> usedIds = {};

        while (validCards.length < 5) {
          final id = Random().nextInt(731) + 1;
          if (usedIds.contains(id)) continue;
          usedIds.add(id);

          try {
            final response = await http.get(
              Uri.parse('https://superheroapi.com/api/${widget.apiKey}/$id'),
            );
            if (response.statusCode == 200) {
              final data = json.decode(response.body);
              if (data['response'] == 'success' &&
                  data['powerstats']['power'] != 'null' &&
                  data['image']?['url'] != null) {
                validCards.add(data);
              }
            }
          } catch (e) {
            debugPrint('Error fetching hero $id: $e');
          }
        }

        return validCards;
      }

      final userCards = await generateValidCards();
      final botCards = await generateValidCards();

      await DatabaseHelper.instance.saveActiveCards(
        userCards, // Pass user cards
        botCards, // Pass bot cards
      ); // Save to active_cards and bot_active_cards

      setState(() {
        userDeck = userCards;
        botDeck = botCards;
        decksReady = true;
        isLoadingDeck = false;
      });
    } catch (e) {
      debugPrint("Deck generation error: $e");
      setState(() => isLoadingDeck = false);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to load decks. Please try again."),
          ),
        );
      }
    }
  }

  Future<void> _rollDice() async {
    setState(() {
      diceResult = 0; // Reset dice result before rolling
      isDiceSpinning = true; // Show the spinning dice GIF
      isLoadingAdditionalCards = true; // Set loading flag
    });

    await Future.delayed(const Duration(seconds: 2)); // Simulate spinning delay

    final result = Random().nextInt(3) + 1; // Roll a dice (1-3)

    setState(() {
      diceResult = result; // Update dice result after rolling
      isDiceSpinning = false; // Hide the spinning dice GIF
      showDice = false; // Hide dice button after rolling
    });

    if (diceResult > 0) {
      final additionalCards = await _generateAdditionalCards(diceResult);
      setState(() {
        if (isUserTurn) {
          userDeck.addAll(additionalCards); // Add cards to user deck
        } else {
          botDeck.addAll(additionalCards); // Add cards to bot deck
        }
        isLoadingAdditionalCards = false; // Reset loading flag
      });

      // Save the updated game state
      await _saveGameState();
    } else {
      setState(() {
        isLoadingAdditionalCards = false; // Reset loading flag
      });
    }
  }

  Future<void> _botRollDice() async {
    setState(() {
      diceResult = 0; // Reset dice result before rolling
      showDice = false; // Hide dice while bot is spinning
      isLoadingAdditionalCards = true; // Set loading flag for bot
    });

    await Future.delayed(const Duration(seconds: 2)); // Add delay for bot spin
    final result = Random().nextInt(3) + 1; // Bot rolls a dice (1-6)

    setState(() {
      diceResult = result; // Update dice result after rolling
    });

    if (diceResult > 0) {
      final additionalCards = await _generateAdditionalCards(diceResult);
      setState(() {
        botDeck.addAll(additionalCards); // Add cards to bot deck
        isLoadingAdditionalCards = false; // Reset loading flag
      });

      // Save the updated game state
      await _saveGameState();
    } else {
      setState(() {
        isLoadingAdditionalCards = false; // Reset loading flag
      });
    }
  }

  Future<List<Map<String, dynamic>>> _generateAdditionalCards(int count) async {
    final List<Map<String, dynamic>> additionalCards = [];
    final Set<int> usedIds = {
      ...bannedCardIds,
    }; // Include banned IDs in the exclusion list

    while (additionalCards.length < count) {
      final id = Random().nextInt(731) + 1;
      if (usedIds.contains(id)) continue; // Skip if the card ID is banned
      usedIds.add(id);

      try {
        final response = await http.get(
          Uri.parse('https://superheroapi.com/api/${widget.apiKey}/$id'),
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['response'] == 'success' &&
              data['powerstats']['power'] != 'null' &&
              data['image']?['url'] != null) {
            additionalCards.add(data);
          }
        }
      } catch (e) {
        debugPrint('Error fetching hero $id: $e');
      }
    }

    return additionalCards;
  }

  Future<void> _startBattle(Map<String, dynamic> userCard) async {
    if (isLoadingAdditionalCards) {
      // Alert the user to wait for additional cards to load
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please wait, additional cards are still being distributed.",
          ),
        ),
      );
      return;
    }

    if (showDice && isUserTurn) {
      // Alert the user to roll the dice first
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please roll the dice before selecting another card."),
        ),
      );
      return;
    }

    selectedUserCard = userCard;
    selectedBotCard =
        botDeck.isNotEmpty ? botDeck[Random().nextInt(botDeck.length)] : null;

    // Initialize points
    int userPoints = 0;
    int botPoints = 0;

    // List of powerstats to compare
    final powerStats = [
      'intelligence',
      'strength',
      'speed',
      'durability',
      'power',
      'combat',
    ];

    for (final stat in powerStats) {
      final userStat =
          int.tryParse(selectedUserCard!['powerstats'][stat] ?? '0') ?? 0;
      final botStat =
          int.tryParse(selectedBotCard!['powerstats'][stat] ?? '0') ?? 0;

      if (userStat > botStat) {
        userPoints++;
      } else if (botStat > userStat) {
        botPoints++;
      }
    }

    // Determine the winner based on points
    if (userPoints > botPoints) {
      battleResult = "You Win this Round!";
      userScore++;
      diceResult = 0;
      showDice = true;
      isUserTurn = true;
    } else if (botPoints > userPoints) {
      battleResult = "Bot Wins this Round!";
      botScore++;
      diceResult = 0;
      showDice = true;
      isUserTurn = false;
      _botRollDice();
    } else {
      battleResult = "It's a Draw!";
      showDice = false;
    }

    // Move the used cards to the used_cards table
    await DatabaseHelper.instance.addCardToUsed(selectedUserCard!);
    if (selectedBotCard != null) {
      await DatabaseHelper.instance.addCardToUsed(selectedBotCard!);
    }

    // Remove the used cards from the in-memory decks
    setState(() {
      userDeck.remove(selectedUserCard);
      botDeck.remove(selectedBotCard);
    });

    _saveGameState();

    if (userDeck.isEmpty || botDeck.isEmpty) {
      if (userDeck.isEmpty) {
        battleResult = "Bot Wins the Game!";
      } else if (botDeck.isEmpty) {
        battleResult = "You Win the Game!";
      }
      decksReady = false;
    }

    // Finally update UI
    setState(() {});
  }

  void _restartGame() async {
    await DatabaseHelper.instance.clearMatchData(); // Clear match-related data
    bannedCardIds.clear(); // Clear the ban list when restarting the game
    setState(() {
      userDeck = [];
      botDeck = [];
      selectedUserCard = null;
      selectedBotCard = null;
      battleResult = null;
      userScore = 0;
      botScore = 0;
      decksReady = false;
      showDice = false; // Reset dice visibility
      isUserTurn = false; // Reset turn tracking
    });
  }

  Widget _buildEndScreen() {
    return Center(
      // Wrap the entire column with Center
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            battleResult ?? "Game Over",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (userDeck.isEmpty || botDeck.isEmpty) ...[
            Text(
              userDeck.isEmpty ? "The Winner is Bot!" : "The Winner is You!",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
          ],
          Text("Your Score: $userScore", style: const TextStyle(fontSize: 18)),
          Text("Bot's Score: $botScore", style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 30),
          ElevatedButton(onPressed: _restartGame, child: const Text("Restart")),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _generateDeck,
            child: const Text("Distribute Cards Again"),
          ),
        ],
      ),
    );
  }

  Widget _buildDiceSpinner() {
    return Center(
      child: Image.asset(
        'assets/dice-game.gif', // Path to the dice GIF
        width: 150,
        height: 150,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildDiceOrResult() {
    if (isDiceSpinning) {
      return Image.asset(
        'assets/dice-game.gif', // Path to the dice GIF
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    } else if (diceResult > 0) {
      return Text(
        "Additional Cards: $diceResult",
        style: const TextStyle(fontSize: 16),
      );
    } else {
      return const SizedBox.shrink(); // Empty widget if no result
    }
  }

  Widget _buildResultContainer() {
    // Always show the result card container, even if no card is picked yet
    return ResultCardContainer(
      selectedUserCard: selectedUserCard,
      selectedBotCard: selectedBotCard,
      userDeckLength: userDeck.length,
      botDeckLength: botDeck.length,
      battleResult: battleResult,
      showDice: showDice,
      isUserTurn: isUserTurn,
      isDiceSpinning: isDiceSpinning,
      diceResult: diceResult,
      onRollDice: _rollDice,
      buildDiceOrResult: _buildDiceOrResult,
      isInitial: selectedUserCard == null && selectedBotCard == null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showResult = true; // Always show result card container

    return Scaffold(
      appBar: AppBar(title: const Text("Battle Page")),
      drawer: appnav.NavigationDrawer(
        currentPage: appnav.AppPage.battle,
        apiKey: widget.apiKey,
      ),
      body:
          isDiceSpinning
              ? _buildDiceSpinner() // Show the dice spinner if spinning
              : Padding(
                padding: const EdgeInsets.all(16),
                child:
                    isLoadingDeck
                        ? Center(
                          child: LoadingAnimationWidget.fourRotatingDots(
                            color: Colors.blue,
                            size: 48,
                          ),
                        )
                        : (userDeck.isEmpty || botDeck.isEmpty) &&
                            battleResult != null
                        ? _buildEndScreen()
                        : decksReady
                        ? ScrollConfiguration(
                          behavior: _NoScrollbarBehavior(),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                UserDeckWidget(
                                  deck: userDeck,
                                  score: userScore,
                                  decksReady: decksReady,
                                  onCardTap: _startBattle,
                                ),
                                const SizedBox(height: 20),
                                _buildResultContainer(),
                                const SizedBox(height: 20),
                                BotDeckWidget(deck: botDeck, score: botScore),
                              ],
                            ),
                          ),
                        )
                        : Center(
                          child: ElevatedButton(
                            onPressed: _generateDeck,
                            child: const Text("Distribute Cards"),
                          ),
                        ),
              ),
    );
  }
}

class _ThreeDotsLoader extends StatefulWidget {
  const _ThreeDotsLoader();

  @override
  State<_ThreeDotsLoader> createState() => _ThreeDotsLoaderState();
}

class _ThreeDotsLoaderState extends State<_ThreeDotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dotOne;
  late Animation<double> _dotTwo;
  late Animation<double> _dotThree;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _dotOne = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );
    _dotTwo = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );
    _dotThree = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder:
          (context, child) => Padding(
            padding: EdgeInsets.only(bottom: animation.value),
            child: child,
          ),
      child: Container(
        width: 16,
        height: 16,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [_buildDot(_dotOne), _buildDot(_dotTwo), _buildDot(_dotThree)],
    );
  }
}

class _NoScrollbarBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child; // disables the scrollbar
  }
}
