import 'package:flutter/material.dart';

class FavoriteStarButton extends StatelessWidget {
  final bool isFavorite;
  final Color activeColor;
  final VoidCallback onPressed;
  final String tooltip;
  final Color? inactiveColor;

  const FavoriteStarButton({
    Key? key,
    required this.isFavorite,
    required this.activeColor,
    required this.onPressed,
    required this.tooltip,
    this.inactiveColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color offColor =
        inactiveColor ?? Theme.of(context).colorScheme.outline;
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.star : Icons.star_border,
        color: isFavorite ? activeColor : offColor,
        size: 28,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}
