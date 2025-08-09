// lib/core/widgets/confirmation_dialog.dart
import 'package:flutter/material.dart';

Future<bool?> showStyledConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  String confirmText = 'DELETE',
  IconData icon = Icons.delete_forever_rounded,
}) {
  final textTheme = Theme.of(context).textTheme;

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.red.shade700, size: 40),
      ),
      title: Text(title,
          textAlign: TextAlign.center, style: textTheme.headlineSmall),
      content:
      Text(content, textAlign: TextAlign.center, style: textTheme.bodyMedium),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      actions: <Widget>[
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('CANCEL'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(confirmText),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}