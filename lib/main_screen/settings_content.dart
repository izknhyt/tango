import 'package:flutter/material.dart';

import '../tabs_content/settings_tab_content.dart';

class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsTabContent(
      key: ValueKey('SettingsTabContent'),
    );
  }
}
