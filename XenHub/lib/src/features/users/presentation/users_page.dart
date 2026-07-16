import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/user_account.dart';
import 'users_providers.dart';

class UsersPage extends ConsumerWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      body: SafeArea(
        child: usersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text(
              'Failed to load users: $error',
              textAlign: TextAlign.center,
            ),
          ),
          data: (users) {
            final viewModels = _AutoRegistrationSnapshot.fromUsers(users);

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const _Header(),
                const SizedBox(height: 24),
                _MetricsRow(items: viewModels),
                const SizedBox(height: 24),
                _UsersList(items: viewModels),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.secondary,
            theme.colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Auto-Registered Users',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Phones detected near a hub are registered automatically. Manual entry has been removed from this tab.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSecondary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({required this.items});

  final List<_AutoRegistrationSnapshot> items;

  @override
  Widget build(BuildContext context) {
    final total = items.length;
    final autoRegistered = items.where((item) => item.autoRegistered).length;
    final averageDistance = total == 0
        ? 0
        : items.map((item) => item.distanceMeters).reduce((a, b) => a + b) ~/
              total;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final cards = [
          _MetricCard(
            label: 'Detected phones',
            value: total.toString(),
            icon: Icons.radar_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          _MetricCard(
            label: 'Auto registered',
            value: autoRegistered.toString(),
            icon: Icons.hub_outlined,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          _MetricCard(
            label: 'Avg proximity',
            value: '$averageDistance m',
            icon: Icons.bluetooth_searching_outlined,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ];

        if (wide) {
          return Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 16),
              Expanded(child: cards[1]),
              const SizedBox(width: 16),
              Expanded(child: cards[2]),
            ],
          );
        }

        return GridView.count(
          crossAxisCount: constraints.maxWidth >= 700 ? 2 : 1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: 80,
          children: cards,
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 17),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(label, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsersList extends StatelessWidget {
  const _UsersList({required this.items});

  final List<_AutoRegistrationSnapshot> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nearby hub detections',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Each entry is created automatically when a phone comes within range of the hub.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            if (items.isEmpty)
              Text(
                'No nearby phones detected yet.',
                style: theme.textTheme.bodyMedium,
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 1000;
                  if (!isWide) {
                    return Column(
                      children: items
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _UserTile(item: item),
                            ),
                          )
                          .toList(growable: false),
                    );
                  }

                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 176,
                    children: items
                        .map((item) => _UserTile(item: item))
                        .toList(growable: false),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.item});

  final _AutoRegistrationSnapshot item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = item.autoRegistered
        ? theme.colorScheme.tertiary
        : theme.colorScheme.outline;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: theme.colorScheme.primaryContainer,
            foregroundColor: theme.colorScheme.onPrimaryContainer,
            child: Text(
              item.user.fullName.trim().isEmpty
                  ? '?'
                  : item.user.fullName.trim()[0].toUpperCase(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  item.user.fullName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.user.phone,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _InfoChip(icon: Icons.hub_outlined, label: item.hubName),
                    _InfoChip(
                      icon: Icons.location_on_outlined,
                      label: '${item.distanceMeters} m away',
                    ),
                    _InfoChip(
                      icon: Icons.schedule_outlined,
                      label: item.detectedLabel,
                    ),
                    _StatusChip(
                      label: item.autoRegistered
                          ? 'Inside range'
                          : 'Awaiting range',
                      color: statusColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Chip(
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      avatar: Icon(icon, size: 18, color: theme.colorScheme.primary),
      label: Text(label),
      side: BorderSide(color: theme.colorScheme.outlineVariant),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: Text(label),
      labelStyle: TextStyle(color: color),
      side: BorderSide(color: color.withValues(alpha: 0.35)),
      backgroundColor: color.withValues(alpha: 0.1),
    );
  }
}

class _AutoRegistrationSnapshot {
  const _AutoRegistrationSnapshot({
    required this.user,
    required this.hubName,
    required this.distanceMeters,
    required this.detectedAt,
  });

  final UserAccount user;
  final String hubName;
  final int distanceMeters;
  final DateTime detectedAt;

  bool get autoRegistered => distanceMeters <= 120;

  String get detectedLabel {
    final minutes = DateTime.now().difference(detectedAt).inMinutes;
    if (minutes <= 0) {
      return 'Just detected';
    }
    return '$minutes min ago';
  }

  static List<_AutoRegistrationSnapshot> fromUsers(List<UserAccount> users) {
    const hubs = <String>['North Hub', 'Central Hub', 'South Hub'];
    const distances = <int>[38, 62, 94, 118, 144, 182];

    return users
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final user = entry.value;
          return _AutoRegistrationSnapshot(
            user: user,
            hubName: hubs[index % hubs.length],
            distanceMeters: distances[index % distances.length],
            detectedAt: DateTime.now().subtract(
              Duration(minutes: index * 4 + 1),
            ),
          );
        })
        .toList(growable: false);
  }
}
