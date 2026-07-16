import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../message_queue/domain/message_bundle.dart';
import '../../message_queue/presentation/message_queue_providers.dart';
import '../domain/dtn_bundle_status.dart';
import '../domain/dtn_bus.dart';
import '../domain/dtn_hub.dart';
import '../domain/dtn_simulator_snapshot.dart';
import '../domain/dtn_transit_simulation.dart';
import 'dtn_simulator_providers.dart';

class DtnSimulatorPage extends ConsumerStatefulWidget {
  const DtnSimulatorPage({super.key});

  @override
  ConsumerState<DtnSimulatorPage> createState() => _DtnSimulatorPageState();
}

class _DtnSimulatorPageState extends ConsumerState<DtnSimulatorPage> {
  @override
  Widget build(BuildContext context) {
    final snapshotAsync = ref.watch(dtnSnapshotProvider);
    final queueBundlesAsync = ref.watch(messageBundlesProvider);
    final clockAsync = ref.watch(simulationClockProvider);
    final now = clockAsync.asData?.value ?? DateTime.now();

    return Scaffold(
      body: SafeArea(
        child: snapshotAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text(
              'Failed to load DTN relay monitor: $error',
              textAlign: TextAlign.center,
            ),
          ),
          data: (snapshot) {
            return queueBundlesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text(
                  'Failed to load queue bundles for relay view: $error',
                  textAlign: TextAlign.center,
                ),
              ),
              data: (queueBundles) {
                return ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _Header(now: now),
                    const SizedBox(height: 24),
                    _HubGrid(snapshot: snapshot),
                    const SizedBox(height: 24),
                    _FleetSummary(snapshot: snapshot, now: now),
                    const SizedBox(height: 24),
                    _BusList(
                      snapshot: snapshot,
                      queueBundles: queueBundles,
                      now: now,
                    ),
                    const SizedBox(height: 24),
                    _BundleList(queueBundles: queueBundles),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DTN Relay Monitor',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Relay buses are auto-registered near hubs. Open Bundles onboard to inspect the messages inside each relay.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 16),
          _HeaderPill(
            icon: Icons.schedule,
            label: 'Live sim ${TimeOfDay.fromDateTime(now).format(context)}',
          ),
        ],
      ),
    );
  }
}

class _HubGrid extends StatelessWidget {
  const _HubGrid({required this.snapshot});

  final DtnSimulatorSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final columns = MediaQuery.of(context).size.width >= 900 ? 3 : 1;

    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 3.1,
      children: snapshot.hubs
          .map(
            (hub) => Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      hub.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 34),
                    Text('Relay buses: ${hub.busCount}'),
                    const SizedBox(height: 6),
                    Text('Bundles waiting: ${hub.bundleCount}'),
                  ],
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _FleetSummary extends StatelessWidget {
  const _FleetSummary({required this.snapshot, required this.now});

  final DtnSimulatorSnapshot snapshot;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final simulations = snapshot.buses
        .map((bus) => DtnTransitSimulation.fromBus(bus, snapshot.hubs, now))
        .toList(growable: false);
    final loading = simulations
        .where((info) => info.status == 'loading')
        .length;
    final transit = simulations
        .where((info) => info.status == 'in-transit')
        .length;
    final waiting = simulations
        .where((info) => info.status == 'waiting')
        .length;
    final carrying = snapshot.bundles
        .where((bundle) => bundle.status == DtnBundleStatus.queued)
        .length;
    final delivered = snapshot.bundles
        .where((bundle) => bundle.status == DtnBundleStatus.delivered)
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1600
            ? 6
            : constraints.maxWidth >= 1200
            ? 3
            : constraints.maxWidth >= 700
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
              label: 'Registered buses',
              value: snapshot.buses.length.toString(),
              icon: Icons.directions_bus_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            _MetricCard(
              label: 'Moving now',
              value: transit.toString(),
              icon: Icons.route_outlined,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            _MetricCard(
              label: 'Loading',
              value: loading.toString(),
              icon: Icons.all_inbox_outlined,
              color: Theme.of(context).colorScheme.secondary,
            ),
            _MetricCard(
              label: 'Waiting',
              value: waiting.toString(),
              icon: Icons.pause_circle_outline,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            _MetricCard(
              label: 'Bundles onboard',
              value: carrying.toString(),
              icon: Icons.inventory_2_outlined,
              color: Theme.of(context).colorScheme.secondary,
            ),
            _MetricCard(
              label: 'Delivered',
              value: delivered.toString(),
              icon: Icons.verified_outlined,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
          ],
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
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

class _BusList extends StatelessWidget {
  const _BusList({
    required this.snapshot,
    required this.queueBundles,
    required this.now,
  });

  final DtnSimulatorSnapshot snapshot;
  final List<MessageBundle> queueBundles;
  final DateTime now;

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
              'Relay buses',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Each bus is auto-registered near a hub, shows its route, and reveals the bundle groups it is carrying.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            if (snapshot.buses.isEmpty)
              Text(
                'No relay buses detected yet.',
                style: theme.textTheme.bodyMedium,
              )
            else
              ...snapshot.buses.map(
                (bus) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BusCard(
                    bus: bus,
                    hubs: snapshot.hubs,
                    queueBundles: queueBundles,
                    now: now,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BusCard extends StatefulWidget {
  const _BusCard({
    required this.bus,
    required this.hubs,
    required this.queueBundles,
    required this.now,
  });

  final DtnBus bus;
  final List<DtnHub> hubs;
  final List<MessageBundle> queueBundles;
  final DateTime now;

  @override
  State<_BusCard> createState() => _BusCardState();
}

class _BusCardState extends State<_BusCard> {
  bool _showBundles = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = DtnTransitSimulation.fromBus(
      widget.bus,
      widget.hubs,
      widget.now,
    );
    final originHub = _hubName(widget.hubs, widget.bus.originHubId);
    final destinationHub = _hubName(widget.hubs, widget.bus.destinationHubId);
    final carriedBundles = widget.queueBundles
        .where((bundle) => bundle.destinationAddress == destinationHub)
        .toList(growable: false);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.bus.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Chip(
                          label: _hubName(widget.hubs, widget.bus.originHubId),
                          icon: Icons.trip_origin_outlined,
                        ),
                        _Chip(
                          label: _hubName(
                            widget.hubs,
                            widget.bus.destinationHubId,
                          ),
                          icon: Icons.flag_outlined,
                        ),
                        _StatusChip(
                          label: info.phaseLabel,
                          status: info.status,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Position', style: theme.textTheme.labelMedium),
                  Text(
                    info.positionLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.schedule_outlined,
                label:
                    '${info.nextEventLabel} ${_formatDuration(info.timeToNextEvent)}',
              ),
              _InfoChip(
                icon: Icons.timer_outlined,
                label: 'Since last ${_formatDuration(info.timeSinceLastEvent)}',
              ),
              _InfoChip(
                icon: Icons.alt_route_outlined,
                label: 'Route $originHub -> $destinationHub',
              ),
            ],
          ),
          const SizedBox(height: 14),
          TweenAnimationBuilder<double>(
            tween: Tween(
              begin: 0,
              end: info.progress.clamp(0.0, 1.0).toDouble(),
            ),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return LinearProgressIndicator(value: value);
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _RouteNode(
                  title: 'Origin',
                  hubName: originHub,
                  active: info.positionLabel == 'At $originHub',
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
                  active: info.positionLabel == 'At $destinationHub',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            key: ValueKey('bundles-onboard-${widget.bus.id}'),
            borderRadius: BorderRadius.circular(12),
            onTap: carriedBundles.isEmpty
                ? null
                : () {
                    setState(() {
                      _showBundles = !_showBundles;
                    });
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    'Bundles onboard',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _showBundles ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: carriedBundles.isEmpty
                        ? theme.colorScheme.outline
                        : theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (carriedBundles.isEmpty)
            Text(
              'No bundle group assigned to this bus yet.',
              style: theme.textTheme.bodyMedium,
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: carriedBundles
                  .map(
                    (bundle) => Chip(
                      avatar: const Icon(Icons.inventory_2_outlined, size: 18),
                      label: Text(bundle.destinationAddress),
                    ),
                  )
                  .toList(growable: false),
            ),
          if (_showBundles && carriedBundles.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...carriedBundles.map(
              (bundle) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _BundleMessagePanel(bundle: bundle),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BundleMessagePanel extends StatelessWidget {
  const _BundleMessagePanel({required this.bundle});

  final MessageBundle bundle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bundle.destinationAddress,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (bundle.messages.isEmpty)
            Text(
              'No messages in this bundle.',
              style: theme.textTheme.bodyMedium,
            )
          else
            ...bundle.messages.map(
              (message) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Message #${message.id}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(message.body)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BundleList extends StatelessWidget {
  const _BundleList({required this.queueBundles});

  final List<MessageBundle> queueBundles;

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
              'Destination bundle groups',
              key: const ValueKey('destination-bundle-groups-heading'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'These are the same destination groups from the Queue tab, now shown as relay cargo.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            if (queueBundles.isEmpty)
              Text('No relay bundles yet.', style: theme.textTheme.bodyMedium)
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1100
                      ? 3
                      : constraints.maxWidth >= 700
                      ? 2
                      : 1;

                    return GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    mainAxisExtent: columns == 1 ? 180 : 160,
                    children: queueBundles
                        .map((bundle) => _QueueBundleCard(bundle: bundle))
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

class _QueueBundleCard extends StatelessWidget {
  const _QueueBundleCard({required this.bundle});

  final MessageBundle bundle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              bundle.destinationAddress,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${bundle.messageCount} messages queued in this group',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: bundle.messages
                  .map(
                    (message) => Chip(
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      avatar: const Icon(Icons.mail_outline, size: 13),
                      label: Text('Message #${message.id}'),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        icon,
        size: 18,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: Text(label),
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
          color: theme.colorScheme.onPrimary.withValues(alpha: 0.14),
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
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.72)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(14),
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
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
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
    final color = switch (status) {
      'idle' => Theme.of(context).colorScheme.outline,
      'loading' => Theme.of(context).colorScheme.tertiary,
      'in-transit' => Theme.of(context).colorScheme.primary,
      'waiting' => Theme.of(context).colorScheme.secondary,
      _ => Theme.of(context).colorScheme.primaryContainer,
    };

    return Chip(
      label: Text(label),
      labelStyle: TextStyle(color: color),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.35)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        icon,
        size: 18,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: Text(label),
    );
  }
}

String _hubName(List<DtnHub> hubs, int hubId) {
  for (final hub in hubs) {
    if (hub.id == hubId) {
      return hub.name;
    }
  }
  return 'Hub $hubId';
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
