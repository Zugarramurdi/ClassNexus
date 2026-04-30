import 'package:flutter/material.dart';

/// Clave global para mostrar SnackBars desde cualquier parte de la aplicación,
/// incluso durante cambios de ruta o reinicios de sesión.
final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

void showGlobalSnackBar(String message, {bool isError = false}) {
  messengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
