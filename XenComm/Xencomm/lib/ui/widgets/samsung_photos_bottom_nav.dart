import 'package:flutter/material.dart';

class SamsungPhotosBottomNav extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;

  const SamsungPhotosBottomNav({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = scheme.onPrimary;
    final inactive = scheme.onSurface.withValues(alpha: 0.58);

    Widget item({
      required int index,
      required IconData icon,
      required String label,
    }) {
      final selected = activeIndex == index;
      return Expanded(
        child: InkResponse(
          onTap: () => onTap(index),
          radius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: selected ? active : inactive),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  height: 1,
                  fontWeight: FontWeight.w500,
                  color: selected ? active : inactive,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            children: [
              item(index: 0, icon: Icons.photo_library_outlined, label: 'Photos'),
              const SizedBox(width: 32),
              item(index: 1, icon: Icons.collections_outlined, label: 'Albums'),
              const SizedBox(width: 32),
              item(index: 2, icon: Icons.more_horiz, label: 'Menu'),
            ],
          ),
        ),
      ),
    );
  }
}
