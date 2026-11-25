import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Tombol ikon melingkar bergaris tipis (seperti tombol `+` dan `≡` pada template UI).
class CircularOutlineButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final double size;

  const CircularOutlineButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.size = 42,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.circleBorder,
                width: 1.2,
              ),
            ),
            child: Icon(
              icon,
              size: size * 0.48,
              color: AppTheme.inkSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
