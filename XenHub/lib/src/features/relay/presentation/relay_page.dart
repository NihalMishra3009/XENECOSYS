import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dtn/domain/dtn_bus.dart';
import '../../dtn/domain/dtn_hub.dart';
import '../../dtn/domain/dtn_simulator_snapshot.dart';
import '../../dtn/domain/dtn_transit_simulation.dart';
import '../../dtn/presentation/dtn_simulator_providers.dart';

class RelayPage extends ConsumerStatefulWidget {
  const RelayPage({super.key});

  @override
  ConsumerState<RelayPage> createState() => _RelayPageState();
}

class _RelayPageState extends ConsumerState<RelayPage> {
  @override
  Widget build(BuildContext context) {
    final snapshotAsync = ref.watch(dtnSnapshotProvider);
    final clockAsync = ref.watch(simulationClockProvider);
    final now = clockAsync.asData?.value ?? DateTime.now();

    return Scaffold(
      body: SafeArea(
        child: snapshotAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text('Failed to load relay network: $error')),
          data: (snapshot) {
            final buses = List<DtnBus>.from(snapshot.buses)
              ..sort((left, right) => left.id.compareTo(right.id));
            final simulations = buses
                .map(
                  (bus) =>
                      DtnTransitSimulation.fromBus(bus, snapshot.hubs, now),
                )
                .toList(growable: false);

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _Header(snapshot: snapshot, simulations: simulations),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 1200
                        ? 4
                        : constraints.maxWidth >= 800
                        ? 2
                        : 1;

                    return GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: columns == 1 ? 84 : 88,
                      children: [
                        _MetricCard(
                          title: 'Tracked vehicles',
                          value: buses.length,
                          icon: Icons.directions_bus_filled_outlined,
                        ),
                        _MetricCard(
                          title: 'Ready at hub',
                          value: simulations
                              .where((info) => info.status == 'loading')
                              .length,
                          icon: Icons.hub_outlined,
                        ),
                        _MetricCard(
                          title: 'Reached destination',
                          value: simulations
                              .where((info) => info.status == 'waiting')
                              .length,
                          icon: Icons.flag_outlined,
                        ),
                        _MetricCard(
                          title: 'Next event',
                          value: buses.isEmpty
                              ? 0
                              : _soonestMinutes(simulations),
                          suffix: 'm',
                          icon: Icons.schedule_outlined,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                if (buses.isEmpty)
                  const _EmptyState()
                else
                  ...buses.map(
                    (bus) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _RelayBusCard(
                        bus: bus,
                        hubs: snapshot.hubs,
                        info: DtnTransitSimulation.fromBus(
                          bus,
                          snapshot.hubs,
                          now,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  int _soonestMinutes(List<DtnTransitInfo> simulations) {
    final seconds = simulations
        .map((info) => info.timeToNextEvent.inSeconds)
        .reduce((left, right) => left < right ? left : right);
    return (seconds / 60).ceil();
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.snapshot, required this.simulations});

  final DtnSimulatorSnapshot snapshot;
  final List<DtnTransitInfo> simulations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buses = snapshot.buses;
    final nextEta = buses.isEmpty
        ? Duration.zero
        : simulations
              .map((info) => info.timeToNextEvent)
              .reduce((left, right) => left < right ? left : right);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.tertiary, theme.colorScheme.primary],
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.all(28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Relay Network',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Track relay buses as they move through a shared live simulation, with dispatch and arrival timing mirrored in DTN.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.92),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _HeaderPill(
                      icon: Icons.directions_bus_filled_outlined,
                      label: '${buses.length} vehicles',
                    ),
                    _HeaderPill(
                      icon: Icons.schedule_outlined,
                      label: 'Next change ${_formatDuration(nextEta)}',
                    ),
                    _HeaderPill(
                      icon: Icons.my_location_outlined,
                      label: 'Simulated live timing',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _EtaPanel(nextEta: nextEta),
        ],
      ),
    );
  }
}

class _EtaPanel extends StatelessWidget {
  const _EtaPanel({required this.nextEta});

  final Duration nextEta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 220,
      height: 180,
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.onPrimary.withValues(alpha: 0.12),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _formatDuration(nextEta),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Next change',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    this.suffix = '',
  });

  final String title;
  final int value;
  final IconData icon;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer.withValues(
                  alpha: 0.6,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.onTertiaryContainer,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
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
                  const SizedBox(height: 4),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: value),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedValue, child) {
                      return Text(
                        '$animatedValue$suffix',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
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

class _RelayBusCard extends StatelessWidget {
  const _RelayBusCard({
    required this.bus,
    required this.hubs,
    required this.info,
  });

  final DtnBus bus;
  final List<DtnHub> hubs;
  final DtnTransitInfo info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final originHub = _hubName(hubs, bus.originHubId);
    final destinationHub = _hubName(hubs, bus.destinationHubId);
    final eta = info.timeToNextEvent;
    final progress = info.progress;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bus.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _StatusChip(
                            label: info.phaseLabel,
                            status: info.status,
                          ),
                          _StatusChip(
                            label: info.positionLabel,
                            status: info.status,
                          ),
                          _StatusChip(
                            label:
                                '${info.nextEventLabel} ${_formatDuration(eta)}',
                            status: info.status,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  eta == Duration.zero ? 'Now' : _formatDuration(eta),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return LinearProgressIndicator(value: value);
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _RouteNode(
                    title: 'Origin',
                    hubName: originHub,
                    active: info.positionLabel.startsWith('At $originHub'),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.trending_flat, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: _RouteNode(
                    title: 'Position',
                    hubName: info.positionLabel,
                    active: true,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.trending_flat, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: _RouteNode(
                    title: 'Destination',
                    hubName: destinationHub,
                    active: info.positionLabel.startsWith('At $destinationHub'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteNode extends StatelessWidget {
  const _RouteNode({
    required this.title,
    required this.hubName,
    required this.active,
  });

  final String title;
  final String hubName;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: active
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.7)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hubName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.status});

  final String label;
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (status) {
      'loading' => theme.colorScheme.tertiary,
      'in-transit' => theme.colorScheme.primary,
      'waiting' => theme.colorScheme.secondary,
      'idle' => theme.colorScheme.outline,
      _ => theme.colorScheme.primaryContainer,
    };

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: color,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No relay vehicles yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a bus in DTN first, then come back here to see its route, current hub, and timing details.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
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

String _formatDuration(Duration duration) {
  final positive = duration.isNegative ? Duration.zero : duration;
  if (positive.inHours > 0) {
    final minutes = positive.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '${positive.inHours}h ${minutes}m';
  }
  if (positive.inMinutes > 0) {
    final seconds = positive.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${positive.inMinutes}m ${seconds}s';
  }
  return '${positive.inSeconds}s';
}
