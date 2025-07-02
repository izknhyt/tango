import 'package:flutter/material.dart';

import '../app_view.dart';
import '../tabs_content/home_tab_content.dart';

class HomeContent extends StatelessWidget {
  final void Function(AppScreen, {ScreenArguments? args}) navigateTo;

  const HomeContent({super.key, required this.navigateTo});

  @override
  Widget build(BuildContext context) {
    return HomeTabContent(
      key: const ValueKey('HomeTabContent'),
      navigateTo: navigateTo,
    );
  }
}
