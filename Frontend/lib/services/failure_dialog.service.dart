import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FailureDialog{
  showFailure(BuildContext context, ColorScheme colorScheme, String message) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.highlight_remove, size: 30, color: colorScheme.error,),
            const Text(' เกิดข้อผิดพลาด', style: TextStyle(fontSize: 30,),),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 20,),),
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
            ),
            onPressed: () => context.pop(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close, size: 22, color: colorScheme.onSecondary,),
                Text(' ปิด', style: TextStyle(fontSize: 20, color: colorScheme.onSecondary,),),
              ],
            ),
          ),
        ],
      ),
    );
  }
}