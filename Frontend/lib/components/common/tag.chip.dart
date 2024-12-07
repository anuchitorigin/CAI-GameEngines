import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5,),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.tertiary,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(tag, style: TextStyle(fontSize: 12, color: colorScheme.onTertiary,)),
        ),
      ),
    );
  }
}