import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/data/communication_mock_data.dart';

class EmergencyAlertsScreen extends StatelessWidget {
  const EmergencyAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Alerts')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        children: [
          const _HeroCard(
            title: 'Emergency Alerts',
            subtitle: 'All active alerts in the area',
            icon: Icons.warning_amber_rounded,
          ),
          const SizedBox(height: 14),
          ...emergencyAlertsMock.map(
              (alert) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AlertCard(item: alert),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _HeroCard({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFFF75E5E), Color(0xFFE73B3B)]),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFFEAF4FB)),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Color(0xFFA2B6C8), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final MockEmergencyAlert item;

  const _AlertCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: item.type == 'Medical' ? const Color(0xFFF75E5E).withValues(alpha: 0.18) : const Color(0xFF7DC8E8).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              item.type == 'Medical' ? Icons.local_hospital : Icons.notifications_active_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.type,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFEAF4FB)),
                    ),
                    const Spacer(),
                    _SeverityChip(label: item.severity),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.location,
                  style: const TextStyle(fontSize: 13, color: Color(0xFFA2B6C8), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  item.time,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF8CA3B6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeverityChip extends StatelessWidget {
  final String label;

  const _SeverityChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final color = switch (label) {
      'High' => const Color(0xFFF75E5E),
      'Medium' => const Color(0xFF7DC8E8),
      _ => const Color(0xFF7FD3C5),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0x1AFFFFFF), Color(0x75163049)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF243A4F).withValues(alpha: 0.95)),
            boxShadow: const [
              BoxShadow(color: Color(0x44112635), blurRadius: 16, offset: Offset(0, 6)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
