import 'package:flutter/material.dart';

class SuccessSnackBar {
  SnackBar showSuccess(String message, BoxConstraints constraints, ColorScheme colorScheme) {
    final isLg = constraints.maxWidth > 992;
    final isMd = constraints.maxWidth > 768;
    final isSm = constraints.maxWidth > 576;

    final snackbarSideMargin = isLg ? constraints.maxWidth * 0.3 : (isMd ? constraints.maxWidth * 0.2 : (isSm ? constraints.maxWidth * 0.15 : constraints.maxWidth * 0.05));

    return SnackBar(
      showCloseIcon: true,
      duration: const Duration(milliseconds: 2500),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(right: snackbarSideMargin, left: snackbarSideMargin, bottom: 30),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      backgroundColor: colorScheme.secondary,
      content: Row(
        children: [
          Icon(Icons.check_circle, color: colorScheme.brightness == Brightness.light ? const Color( 0xFF0FF000 ) : const Color( 0xFF009000 ),),
          Text(' $message', style: TextStyle(fontSize: 18, color: colorScheme.onSecondary),)
        ],
      ),
    );
  }
}