import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

/// Icon button wrapped with an optional badge.
class IconWithBadge extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final int badgeCount;
  final bool showBadge;
  final String? semanticsLabel;

  const IconWithBadge({
    super.key,
    required this.icon,
    required this.onPressed,
    this.badgeCount = 0,
    this.showBadge = false,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = IconButton(icon: Icon(icon), onPressed: onPressed);
    if (showBadge) {
      button = badges.Badge(badgeContent: Text('$badgeCount'), child: button);
    }
    if (semanticsLabel != null) {
      button = Semantics(label: semanticsLabel!, button: true, child: button);
    }
    return button;
  }
}
