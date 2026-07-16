import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';

class ConnectedHubDetailsScreen extends ConsumerWidget {
  const ConnectedHubDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final hubId = user?.currentHubID ?? 'HUB-001';

    const details = [
      ('Hub Name', 'Nexus Central Hub'),
      ('Location', 'Navi Mumbai'),
      ('Status', 'Online'),
      ('Connection', 'Stable'),
      ('Last Sync', 'Just now'),
      ('Active Nodes', '14'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Connected Hub')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        children: [
          _GlassCard(
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF20314A), Color(0xFF4A78A8)],
                    ),
                  ),
                  child: const Icon(Icons.hub_outlined, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Connected Hub',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFFEAF4FB)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hubId,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF7DC8E8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...details.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DetailTile(label: item.$1, value: item.$2),
            ),
          ),
        ],
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

class _DetailTile extends StatelessWidget {
  final String label;
  final String value;

  const _DetailTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: _GlassCard(
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF1A2A3C),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.memory_outlined, color: Color(0xFF7DC8E8), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: Color(0xFFA2B6C8), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 16, color: Color(0xFFEAF4FB), fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
