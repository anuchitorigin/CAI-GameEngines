import 'package:flutter/material.dart';

class SearchCriteriaChip extends StatelessWidget {
  const SearchCriteriaChip({super.key, required this.visible, required this.children});

  final bool visible;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Visibility(
      visible: visible,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5,),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.tertiary,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 3, left: 5, bottom: 3, right: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}