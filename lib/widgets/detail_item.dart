import 'package:flutter/material.dart';

class DetailItem extends StatelessWidget {
  final String label;
  final String? value;

  const DetailItem({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (value == null ||
        value!.isEmpty ||
        value!.toLowerCase() == 'nan' ||
        value == 'ー') {
      return const SizedBox.shrink();
    }

    final displayValue = value!.replaceAllMapped(
      RegExp(r'\\n'),
      (match) => '\n',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            displayValue,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color,
                ),
          ),
        ],
      ),
    );
  }
}
