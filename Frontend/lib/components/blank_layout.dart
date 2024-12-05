import 'package:flutter/material.dart';

class BlankLayout extends StatelessWidget {
  const BlankLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
    );
  }
}