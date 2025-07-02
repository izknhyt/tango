import 'package:flutter/material.dart';

import '../tabs_content/placeholder_tab_content.dart';

class FavoritesContent extends StatelessWidget {
  const FavoritesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderTabContent(
      key: ValueKey('PlaceholderTabContent'),
    );
  }
}
