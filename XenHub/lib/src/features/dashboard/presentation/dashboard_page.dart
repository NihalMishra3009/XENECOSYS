import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dtn/domain/dtn_bus.dart';
import '../../dtn/domain/dtn_hub.dart';
import '../../dtn/domain/dtn_simulator_snapshot.dart';
import '../../dtn/presentation/dtn_simulator_providers.dart';
import '../../message_queue/domain/message_bundle.dart';
import '../../message_queue/presentation/message_queue_providers.dart';
import '../../users/domain/user_account.dart';
import '../../users/presentation/users_providers.dart';
import '../domain/dashboard_stats.dart';
import 'dashboard_providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final usersAsync = ref.watch(usersProvider);
    final bundlesAsync = ref.watch(messageBundlesProvider);
    final relayAsync = ref.watch(dtnSnapshotProvider);

    if (statsAsync.isLoading ||
        usersAsync.isLoading ||
        bundlesAsync.isLoading ||
        relayAsync.isLoading) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    final error =
        statsAsync.error ??
        usersAsync.error ??
        bundlesAsync.error ??
        relayAsync.error;
    if (error != null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Text(
              'Failed to load dashboard: $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final stats = statsAsync.requireValue;
    final users = usersAsync.requireValue;
    final bundles = bundlesAsync.requireValue;
    final snapshot = relayAsync.requireValue;
    final completionRate = stats.totalTasks == 0
        ? 0.0
        : stats.completedTasks / stats.totalTasks;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _HeroCard(
              stats: stats,
              usersCount: users.length,
              bundlesCount: bundles.length,
              busesCount: snapshot.buses.length,
              completionRate: completionRate,
            ),
            const SizedBox(height: 24),
            _KpiGrid(
              stats: stats,
              usersCount: users.length,
              bundlesCount: bundles.length,
              busesCount: snapshot.buses.length,
            ),
            const SizedBox(height: 24),
            _ActivityBoard(
              users: users,
              bundles: bundles,
              snapshot: snapshot,
              stats: stats,
              completionRate: completionRate,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.stats,
    required this.usersCount,
    required this.bundlesCount,
    required this.busesCount,
    required this.completionRate,
  });

  final DashboardStats stats;
  final int usersCount;
  final int bundlesCount;
  final int busesCount;
  final double completionRate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completePercent = (completionRate * 100).round();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(28),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 900;
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Operations Command Center',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Seeded users, grouped queue bundles, and relay buses are tracked in one live view.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onPrimary.withValues(
                                  alpha: 0.92,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _HeaderPill(
                                  icon: Icons.people_outline,
                                  label: '$usersCount users',
                                ),
                                _HeaderPill(
                                  icon: Icons.inventory_2_outlined,
                                  label: '$bundlesCount bundle groups',
                                ),
                                _HeaderPill(
                                  icon: Icons.directions_bus_outlined,
                                  label: '$busesCount relay buses',
                                ),
                                _HeaderPill(
                                  icon: Icons.done_all_outlined,
                                  label: '$completePercent% phase progress',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      _SummaryPanel(
                        valueLabel: '$completePercent%',
                        title: 'Task completion',
                        subtitle:
                            '${stats.completedTasks}/${stats.totalTasks} tasks done',
                        accent: theme.colorScheme.onPrimary,
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Operations Command Center',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Seeded users, grouped queue bundles, and relay buses are tracked in one live view.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onPrimary.withValues(
                              alpha: 0.92,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _HeaderPill(
                              icon: Icons.people_outline,
                              label: '$usersCount users',
                            ),
                            _HeaderPill(
                              icon: Icons.inventory_2_outlined,
                              label: '$bundlesCount bundle groups',
                            ),
                            _HeaderPill(
                              icon: Icons.directions_bus_outlined,
                              label: '$busesCount relay buses',
                            ),
                            _HeaderPill(
                              icon: Icons.done_all_outlined,
                              label: '$completePercent% phase progress',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SummaryPanel(
                      valueLabel: '$completePercent%',
                      title: 'Task completion',
                      subtitle:
                          '${stats.completedTasks}/${stats.totalTasks} tasks done',
                      accent: theme.colorScheme.onPrimary,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({
    required this.stats,
    required this.usersCount,
    required this.bundlesCount,
    required this.busesCount,
  });

  final DashboardStats stats;
  final int usersCount;
  final int bundlesCount;
  final int busesCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1100
            ? 4
            : constraints.maxWidth >= 700
            ? 2
            : 1;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: columns == 1 ? 4.0 : 3.6,
          children: [
            _StatCard(
              title: 'Tasks tracked',
              value: stats.totalTasks,
              icon: Icons.fact_check_outlined,
              accent: Theme.of(context).colorScheme.primary,
            ),
            _StatCard(
              title: 'Registered users',
              value: usersCount,
              icon: Icons.people_outline,
              accent: const Color(0xFF1B7F4F),
            ),
            _StatCard(
              title: 'Bundle groups',
              value: bundlesCount,
              icon: Icons.inventory_2_outlined,
              accent: const Color(0xFFB76E00),
            ),
            _StatCard(
              title: 'Relay buses',
              value: busesCount,
              icon: Icons.directions_bus_outlined,
              accent: const Color(0xFF4C6FFF),
            ),
          ],
        );
      },
    );
  }
}

class _ActivityBoard extends StatelessWidget {
  const _ActivityBoard({
    required this.users,
    required this.bundles,
    required this.snapshot,
    required this.stats,
    required this.completionRate,
  });

  final List<UserAccount> users;
  final List<MessageBundle> bundles;
  final DtnSimulatorSnapshot snapshot;
  final DashboardStats stats;
  final double completionRate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pendingShare = stats.totalTasks == 0
        ? 0.0
        : stats.pendingTasks / stats.totalTasks;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1000;
        final leftColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionCard(
              title: 'Queue groups',
              subtitle:
                  'Destination-address bundles now auto-group messages as they arrive.',
              child: Column(
                children: bundles
                    .take(3)
                    .map(
                      (bundle) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _QueueRow(bundle: bundle),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
            const SizedBox(height: 20),
            _SectionCard(
              title: 'Registered operators',
              subtitle:
                  'Auto-detected users near the hub are seeded into the live roster.',
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 146),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.start,
                      children: users
                          .map((user) => _PersonChip(user: user))
                          .toList(growable: false),
                    ),
                    Text(
                      '${users.length} operators detected',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

        final rightColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionCard(
              title: 'Relay fleet',
              subtitle:
                  'Buses carry the same destination groups that appear in Queue.',
              child: Column(
                children: snapshot.buses
                    .take(3)
                    .map(
                      (bus) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _FleetRow(
                          bus: bus,
                          hubs: snapshot.hubs,
                          bundles: bundles,
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
            const SizedBox(height: 20),
            _SectionCard(
              title: 'Operational pulse',
              subtitle: 'A compact readout of the seeded workspace state.',
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 146),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _PulseRow(
                      label: 'Completion',
                      value: '${(completionRate * 100).round()}%',
                      color: theme.colorScheme.primary,
                    ),
                    _PulseRow(
                      label: 'Pending tasks',
                      value: '${stats.pendingTasks}',
                      color: const Color(0xFFB76E00),
                    ),
                    _PulseRow(
                      label: 'Workload split',
                      value: '${(pendingShare * 100).round()}% pending',
                      color: theme.colorScheme.tertiary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: leftColumn),
              const SizedBox(width: 20),
              Expanded(child: rightColumn),
            ],
          );
        }

        return Column(
          children: [leftColumn, const SizedBox(height: 16), rightColumn],
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _QueueRow extends StatelessWidget {
  const _QueueRow({required this.bundle});

  final MessageBundle bundle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ids = bundle.messages
        .take(3)
        .map((message) => '#${message.id}')
        .join(', ');

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bundle.destinationAddress,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text('${bundle.messageCount} messages | IDs $ids'),
              ],
            ),
          ),
          _StatusPill(
            text: bundle.queuedCount == bundle.messageCount
                ? 'Queued'
                : 'Mixed',
          ),
        ],
      ),
    );
  }
}

class _FleetRow extends StatelessWidget {
  const _FleetRow({
    required this.bus,
    required this.hubs,
    required this.bundles,
  });

  final DtnBus bus;
  final List<DtnHub> hubs;
  final List<MessageBundle> bundles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final carriedBundles = bundles
        .where(
          (bundle) =>
              bundle.destinationAddress == _hubName(hubs, bus.originHubId),
        )
        .toList(growable: false);
    final cargoCount = carriedBundles.fold<int>(
      0,
      (sum, bundle) => sum + bundle.messageCount,
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.directions_bus_outlined,
              color: theme.colorScheme.tertiary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bus.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_hubName(hubs, bus.originHubId)} -> ${_hubName(hubs, bus.destinationHubId)} | $cargoCount messages onboard',
                ),
              ],
            ),
          ),
          _StatusPill(text: bus.status),
        ],
      ),
    );
  }
}

class _PersonChip extends StatelessWidget {
  const _PersonChip({required this.user});

  final UserAccount user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 150),
      child: Chip(
        avatar: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            user.fullName.trim().isEmpty
                ? '?'
                : user.fullName.trim()[0].toUpperCase(),
          ),
        ),
        label: Text(user.fullName),
      ),
    );
  }
}

class _PulseRow extends StatelessWidget {
  const _PulseRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.onPrimary.withValues(alpha: 0.15),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onPrimary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({
    required this.valueLabel,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final String valueLabel;
  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 208,
      constraints: const BoxConstraints(minHeight: 140),
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.onPrimary.withValues(alpha: 0.12),
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            valueLabel,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: const Color(0xFF0F1B2D),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              color: const Color(0xFF152236),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF2A3A52),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String title;
  final int value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: value),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedValue, child) {
                      return Text(
                        '$animatedValue',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    },
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

String _hubName(List<DtnHub> hubs, int hubId) {
  final matches = hubs.where((hub) => hub.id == hubId).toList(growable: false);
  return matches.isEmpty ? 'Hub $hubId' : matches.first.name;
}
