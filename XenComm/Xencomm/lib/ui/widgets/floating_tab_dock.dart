import 'package:flutter/material.dart';
import 'dart:ui';

import '../../core/constants/app_constants.dart';

class FloatingTabDock extends StatelessWidget {
  final String activeRoute;
  final VoidCallback onHomeTap;
  final VoidCallback onBroadcastTap;
  final VoidCallback onSchedulesTap;
  final VoidCallback onOthersTap;

  const FloatingTabDock({
    super.key,
    required this.activeRoute,
    required this.onHomeTap,
    required this.onBroadcastTap,
    required this.onSchedulesTap,
    required this.onOthersTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 350,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xE620314A), Color(0xE6111D2A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0x334B8DD8)),
            boxShadow: const [
              BoxShadow(color: Color(0x3320374F), blurRadius: 24, offset: Offset(0, 10)),
            ],
          ),
          padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                Expanded(
                  child: _item(
                    label: 'Home',
                    selected: activeRoute == AppConstants.homeRoute,
                    onTap: onHomeTap,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _item(
                    label: 'Broadcast',
                    selected: activeRoute == AppConstants.emergencyBroadcastRoute,
                    onTap: onBroadcastTap,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _item(
                    label: 'Schedules',
                    selected: activeRoute == AppConstants.schedulesRoute,
                    onTap: onSchedulesTap,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _item(
                    label: 'Others',
                    selected: activeRoute == AppConstants.othersRoute,
                    onTap: onOthersTap,
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }

  Widget _item({required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: selected ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF7FBFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? const [
                  BoxShadow(color: Color(0x15324D6B), blurRadius: 14, offset: Offset(0, 4)),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF20314A) : const Color(0xFFD8E2EC),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
