import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';

class SharedBottomNav extends StatelessWidget {
  final String activeRoute;
  final VoidCallback? onHomeTap;
  final VoidCallback? onBroadcastTap;

  const SharedBottomNav({
    super.key,
    required this.activeRoute,
    this.onHomeTap,
    this.onBroadcastTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Center(
        child: SizedBox(
          width: 196,
          height: 58,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(999),
              boxShadow: const [
                BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 8)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _navItem(
                  context,
                  label: 'Home',
                  selected: activeRoute == AppConstants.homeRoute,
                  route: AppConstants.homeRoute,
                  overrideTap: onHomeTap,
                ),
                const SizedBox(width: 4),
                _navItem(
                  context,
                  label: 'Broadcast',
                  selected: activeRoute == AppConstants.emergencyBroadcastRoute,
                  route: AppConstants.emergencyBroadcastRoute,
                  overrideTap: onBroadcastTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required String label,
    required bool selected,
    required String route,
    VoidCallback? overrideTap,
  }) {
    return InkWell(
      onTap: selected ? null : (overrideTap ?? () => context.go(route)),
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withValues(alpha: 0.28) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: selected ? 1.0 : 0.68),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
