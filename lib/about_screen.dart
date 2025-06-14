import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'このアプリは英単語学習をサポートするために作られました。\n\n単語の閲覧、クイズ機能、学習履歴の確認などを通して効率的に学習できます。',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
