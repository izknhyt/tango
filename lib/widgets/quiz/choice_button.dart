import 'package:flutter/material.dart';

import '../../flashcard_model.dart';

class ChoiceButton extends StatelessWidget {
  final Flashcard card;
  final VoidCallback onPressed;

  const ChoiceButton({
    super.key,
    required this.card,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(card.term),
      ),
    );
  }
}
