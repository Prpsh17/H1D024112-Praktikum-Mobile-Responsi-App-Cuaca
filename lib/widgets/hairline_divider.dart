import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Garis pemisah horizontal tipis di tengah layar sesuai template UI.
class HairlineDivider extends StatelessWidget {
  final double width;

  const HairlineDivider({
    super.key,
    this.width = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        height: 1.0,
        color: AppTheme.hairline,
      ),
    );
  }
}
