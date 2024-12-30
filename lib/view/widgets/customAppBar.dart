import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String word1;
  final String word2;

  CustomAppBar({super.key, required this.word1, required this.word2});

  @override
  Widget build(BuildContext context) {
    TextStyle commonStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: Colors.black, // Default text color
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15), // Added padding
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: word1,
          style: commonStyle, // Apply common style to the first word
          children: [
            TextSpan(
              text: " $word2",
              style: commonStyle.copyWith(
                color: Colors.orangeAccent, // Unique color for the second word
                fontSize: 26, // Slightly larger font size for the second word
              ),
            ),
          ],
        ),
      ),
    );
  }
}
