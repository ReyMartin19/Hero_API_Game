import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class BattleLoaderOrDistribute extends StatelessWidget {
  final bool isLoadingDeck;
  final VoidCallback onDistribute;

  const BattleLoaderOrDistribute({
    super.key,
    required this.isLoadingDeck,
    required this.onDistribute,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingDeck) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingAnimationWidget.fourRotatingDots(
              color: Colors.blue,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              "Distributing . . .",
              style: GoogleFonts.gruppo(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: ElevatedButton.icon(
          onPressed: onDistribute,
          icon: Icon(Icons.shuffle, color: Color(0xFF661FFF)),
          label: Text(
            "Distribute Cards",
            style: GoogleFonts.gruppo(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            textStyle: GoogleFonts.gruppo(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
            elevation: 8,
            // ignore: deprecated_member_use
            shadowColor: Colors.blue.withOpacity(0.4),
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF661FFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
    }
  }
}
