import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 54});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: const BoxDecoration(color: Color(0xFF252629), shape: BoxShape.circle),
    child: Icon(Icons.key_rounded, color: AppColors.lime, size: size * .58),
  );
}
