import 'package:flutter/material.dart';

const _successColor = Color(0xFF16A34A);
const _errorColor = Color(0xFFDC2626);

void showSuccessToast(BuildContext context, String message) {
  _showAppToast(
    context,
    message,
    backgroundColor: _successColor,
    icon: Icons.check_circle_rounded,
  );
}

void showErrorToast(BuildContext context, String message) {
  _showAppToast(
    context,
    message,
    backgroundColor: _errorColor,
    icon: Icons.error_rounded,
  );
}

void _showAppToast(
  BuildContext context,
  String message, {
  required Color backgroundColor,
  required IconData icon,
}) {
  final messenger = ScaffoldMessenger.of(context);

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        elevation: 0,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}
