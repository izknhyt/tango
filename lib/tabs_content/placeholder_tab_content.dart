import 'package:flutter/material.dart';

/// A placeholder screen used while the third tab is being reworked.
class PlaceholderTabContent extends StatelessWidget {
  const PlaceholderTabContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'このタブは準備中です。',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
