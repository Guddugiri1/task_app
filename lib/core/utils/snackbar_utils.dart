import 'package:flutter/material.dart';

void showStyledSnackBar({
  required BuildContext context,
  required String content,
  VoidCallback? onUndo,
}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  final snackBar = SnackBar(
    content: Text(content),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
    action: onUndo != null
        ? SnackBarAction(
      label: 'UNDO',
      textColor: Colors.yellowAccent,
      onPressed: onUndo,
    )
        : null,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}