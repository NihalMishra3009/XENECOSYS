import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';

class FeatureBottomNav extends StatelessWidget {
  final String activeRoute;

  const FeatureBottomNav({super.key, required this.activeRoute});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = scheme.primary;
    final inactive = scheme.onPrimary.withValues(alpha: 0.72);
    final active = scheme.onPrimary;
    Widget item(String label, String route) {
      final selected = activeRoute == route;
      return InkResponse(
        onTap: selected ? null : () => context.go(route),
        radius: 18,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? bg : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? active : inactive,
            ),
          ),
        ),
      );
    }

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(8, 0, 8, 10),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: bg,
          elevation: 10,
          shadowColor: scheme.primary.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(999),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  item('Home', AppConstants.homeRoute),
                  const SizedBox(width: 8),
                  item('Broadcast', AppConstants.emergencyBroadcastRoute),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
