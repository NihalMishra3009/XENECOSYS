import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/message_bundle.dart';
import '../domain/message_queue_row.dart';
import '../domain/message_status.dart';
import 'message_queue_providers.dart';

class MessageQueuePage extends ConsumerWidget {
  const MessageQueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bundlesAsync = ref.watch(messageBundlesProvider);

    return Scaffold(
      body: SafeArea(
        child: bundlesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text('Failed to load queue: $error')),
          data: (bundles) {
            final messageCount = bundles.fold<int>(
              0,
              (total, bundle) => total + bundle.messageCount,
            );
            final destinationCount = bundles.length;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _Header(
                  bundleCount: bundles.length,
                  messageCount: messageCount,
                  destinationCount: destinationCount,
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 1200
                        ? 3
                        : constraints.maxWidth >= 800
                        ? 2
                        : 1;

                    return GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                      mainAxisExtent: columns == 1 ? 86 : 90,
                      children: [
                        _MetricCard(
                          title: 'Destination bundles',
                          value: destinationCount,
                          icon: Icons.route_outlined,
                        ),
                        _MetricCard(
                          title: 'Total messages',
                          value: messageCount,
                          icon: Icons.mark_email_unread_outlined,
                        ),
                        _MetricCard(
                          title: 'Live groups',
                          value: bundles
                              .where((bundle) => bundle.messages.isNotEmpty)
                              .length,
                          icon: Icons.layers_outlined,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                _BundleList(
                  bundles: bundles,
                  onStatusChanged: (messageId, status) async {
                    await ref
                        .read(messageQueueRepositoryProvider)
                        .updateMessageStatus(messageId, status);
                    ref.invalidate(messageBundlesProvider);
                  },
                  onDelete: (bundle) async {
                    await ref
                        .read(messageQueueRepositoryProvider)
                        .deleteBundle(bundle.id);
                    ref.invalidate(messageBundlesProvider);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.bundleCount,
    required this.messageCount,
    required this.destinationCount,
  });

  final int bundleCount;
  final int messageCount;
  final int destinationCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.tertiary,
            theme.colorScheme.tertiaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
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
                  'Message Queue',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF1A2436),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Messages arrive grouped by destination address and move through shared bundles automatically.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF2A3548),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _HeaderPill(
                      icon: Icons.inventory_2_outlined,
                      label: '$bundleCount bundles',
                    ),
                    _HeaderPill(
                      icon: Icons.mail_outline,
                      label: '$messageCount messages',
                    ),
                    _HeaderPill(
                      icon: Icons.hub_outlined,
                      label: '$destinationCount destinations',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _QueuePanel(messageCount: messageCount),
        ],
      ),
    );
  }
}

class _QueuePanel extends StatelessWidget {
  const _QueuePanel({required this.messageCount});

  final int messageCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 220,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFB7B8D9).withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF8D90B8).withValues(alpha: 0.26),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$messageCount',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: const Color(0xFF172033),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Messages in queue',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              color: const Color(0xFF334158),
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
  });

  final String title;
  final int value;
  final IconData icon;

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
                  const SizedBox(height: 2),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: value),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedValue, child) {
                      return Text(
                        '$animatedValue',
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

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onTertiary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.onTertiary.withValues(alpha: 0.15),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onTertiary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BundleList extends StatelessWidget {
  const _BundleList({
    required this.bundles,
    required this.onStatusChanged,
    required this.onDelete,
  });

  final List<MessageBundle> bundles;
  final Future<void> Function(int messageId, MessageStatus status)
  onStatusChanged;
  final Future<void> Function(MessageBundle bundle) onDelete;

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
              'Destination groups',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            if (bundles.isEmpty)
              Text(
                'No messages yet. Once messages arrive, XenHub will group them by destination automatically.',
                style: theme.textTheme.bodyMedium,
              )
            else
              ...bundles.map(
                (bundle) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _BundleCard(
                    bundle: bundle,
                    onStatusChanged: onStatusChanged,
                    onDelete: onDelete,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BundleCard extends StatelessWidget {
  const _BundleCard({
    required this.bundle,
    required this.onStatusChanged,
    required this.onDelete,
  });

  final MessageBundle bundle;
  final Future<void> Function(int messageId, MessageStatus status)
  onStatusChanged;
  final Future<void> Function(MessageBundle bundle) onDelete;

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
                      bundle.destinationAddress,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${bundle.messageCount} messages | queued ${bundle.queuedCount} | sent ${bundle.sentCount} | failed ${bundle.failedCount}',
                    ),
                  ],
                ),
              ),
              IconButton(
                key: ValueKey('delete-bundle-${bundle.id}'),
                onPressed: () => onDelete(bundle),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...bundle.messages.map(
            (message) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MessageRow(
                message: message,
                onStatusChanged: onStatusChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageRow extends StatelessWidget {
  const _MessageRow({required this.message, required this.onStatusChanged});

  final MessageQueueRow message;
  final Future<void> Function(int messageId, MessageStatus status)
  onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Message #${message.id}'),
                const SizedBox(height: 4),
                Text('Destination: ${message.destinationAddress}'),
                const SizedBox(height: 4),
                Text(message.body),
                const SizedBox(height: 4),
                Text('Encrypted at rest', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<MessageStatus>(
            value: message.status,
            onChanged: (value) {
              if (value != null) {
                onStatusChanged(message.id, value);
              }
            },
            items: MessageStatus.values
                .map(
                  (status) =>
                      DropdownMenuItem(value: status, child: Text(status.name)),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}
