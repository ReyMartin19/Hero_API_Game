import 'package:flutter/material.dart';

class EndMatchDialog extends StatelessWidget {
  final String winnerText;
  final int userScore;
  final int botScore;
  final VoidCallback onClose;

  const EndMatchDialog({
    super.key,
    required this.winnerText,
    required this.userScore,
    required this.botScore,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  winnerText,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "Your Score: $userScore\nBot's Score: $botScore",
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
