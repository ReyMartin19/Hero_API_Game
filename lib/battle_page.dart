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
import 'end_match_dialog.dart'; // <-- Add this import

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
  bool _showFightGif = false;

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
      diceResult = 0; // <-- Reset diceResult when distributing cards
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

  // Remove the _showEndMatchDialog method and replace with showDialog using EndMatchDialog
  void _showEndMatchDialog(String winnerText) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        bool dialogOpen = true;
        Future.delayed(const Duration(seconds: 5), () {
          if (dialogOpen && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });
        return WillPopScope(
          onWillPop: () async {
            dialogOpen = false;
            return true;
          },
          child: EndMatchDialog(
            winnerText: winnerText,
            userScore: userScore,
            botScore: botScore,
            onClose: () {
              dialogOpen = false;
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
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

    // Show fight GIF overlay
    setState(() {
      _showFightGif = true;
    });
    await Future.delayed(const Duration(seconds: 2)); // Show GIF for 2 seconds
    setState(() {
      _showFightGif = false;
    });

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

    // --- FIX LOGIC FOR LAST CARD ---
    // If both decks are empty, show end popup
    if (userDeck.isEmpty && botDeck.isEmpty) {
      String winnerText;
      if (userScore > botScore) {
        battleResult = "You Win the Game!";
        winnerText = "You Win the Match!";
      } else if (botScore > userScore) {
        battleResult = "Bot Wins the Game!";
        winnerText = "Bot Wins the Match!";
      } else {
        battleResult = "It's a Draw!";
        winnerText = "It's a Draw!";
      }
      decksReady = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showEndMatchDialog(winnerText);
      });
    }
    // If user has no cards left after this round
    else if (userDeck.isEmpty &&
        selectedUserCard != null &&
        selectedBotCard != null) {
      // If user lost or draw, show restart and popup
      if (userPoints <= botPoints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showEndMatchDialog(
            botPoints > userPoints ? "Bot Wins the Match!" : "It's a Draw!",
          );
        });
      }
      // If user won, DO NOT show restart, allow spin to continue (showDice remains true)
      // No popup, game continues
    }
    // If bot has no cards left after this round
    else if (botDeck.isEmpty &&
        selectedUserCard != null &&
        selectedBotCard != null) {
      // If bot lost or draw, show restart and popup
      if (userPoints >= botPoints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showEndMatchDialog(
            userPoints > botPoints ? "You Win the Match!" : "It's a Draw!",
          );
        });
      }
      // If bot won, DO NOT show restart, allow spin to continue (showDice remains true)
      // No popup, game continues
    }

    setState(() {});
  }

  void _restartGame() async {
    // Safely close any open dialogs before resetting state
    // Only pop if a dialog is open, not the main route
    try {
      if (ModalRoute.of(context)?.isCurrent == false &&
          Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint("Error while popping dialog: $e");
    }
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
      diceResult = 0; // <-- Reset diceResult when restarting the game
    });
  }

  // Add this getter to determine if the game is over (no more cards to play)
  bool get isGameOver {
    if (userDeck.isEmpty && botDeck.isEmpty) return true;
    if (userDeck.isEmpty &&
        selectedUserCard != null &&
        selectedBotCard != null) {
      // Only game over if user lost or draw last round
      int userPoints = 0, botPoints = 0;
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
        if (userStat > botStat)
          userPoints++;
        else if (botStat > userStat)
          botPoints++;
      }
      return userPoints <= botPoints;
    }
    if (botDeck.isEmpty &&
        selectedUserCard != null &&
        selectedBotCard != null) {
      // Only game over if bot lost or draw last round
      int userPoints = 0, botPoints = 0;
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
        if (userStat > botStat)
          userPoints++;
        else if (botStat > userStat)
          botPoints++;
      }
      return userPoints >= botPoints;
    }
    return false;
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
      showRestart: isGameOver, // <-- pass this flag
      onRestart: _restartGame, // <-- pass the restart callback
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
      body: Stack(
        children: [
          isDiceSpinning
              ? _buildDiceSpinner()
              : Padding(
                padding: EdgeInsets.zero,
                child:
                    isLoadingDeck
                        ? Center(
                          child: LoadingAnimationWidget.fourRotatingDots(
                            color: Colors.blue,
                            size: 48,
                          ),
                        )
                        : decksReady ||
                            userDeck.isNotEmpty ||
                            botDeck.isNotEmpty
                        ? ScrollConfiguration(
                          behavior: ScrollConfiguration.of(
                            context,
                          ).copyWith(scrollbars: false),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
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
                          ),
                        )
                        : Center(
                          child: ElevatedButton(
                            onPressed: _generateDeck,
                            child: const Text("Distribute Cards"),
                          ),
                        ),
              ),
          // Fight GIF overlay
          if (_showFightGif)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Image.asset(
                    'assets/fight.gif',
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NoScrollbarBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
    BuildContext context,
    Widget child,
    AxisDirection axisDirection,
  ) {
    return child;
  }
}

// ...existing code...
