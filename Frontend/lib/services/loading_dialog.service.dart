import 'package:flutter/material.dart';

class LoadingDialogService {
  presentLoading(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    var isDark = colorScheme.brightness == Brightness.dark;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),),
                const SizedBox(
                  height: 15,
                ),
                Text('กำลังโหลด...', style: TextStyle(color: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF)),)
              ],
            ),
          ),
        );
      }
    );
  }
}