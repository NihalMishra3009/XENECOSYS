import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/data/communication_mock_data.dart';

class PendingMessagesScreen extends StatelessWidget {
  const PendingMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFF08111B),
      appBar: AppBar(
        title: const Text(AppConstants.pendingMessages),
        foregroundColor: const Color(0xFFEAF4FB),
        titleTextStyle: const TextStyle(
          color: Color(0xFFEAF4FB),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.65)),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.mail_outline, color: scheme.onPrimary),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pending messages',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFFEAF4FB)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Queued outbound messages waiting to be sent',
                        style: TextStyle(color: Color(0xFFA2B6C8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...pendingMessagesMock.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PendingMessageCard(
                item: item,
                onTap: () => context.push(
                  '${AppConstants.chatRoute}?contactID=${item.userID}&contactName=${Uri.encodeComponent(item.name)}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingMessageCard extends StatelessWidget {
  const _PendingMessageCard({required this.item, required this.onTap});

  final MockPendingMessage item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.65)),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: scheme.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: scheme.onSecondary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFEAF4FB)),
                        ),
                      ),
                      _UnreadDot(count: item.unreadCount),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Color(0xFFA2B6C8), height: 1.35),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        item.userID,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9AB0C3)),
                      ),
                      const Spacer(),
                      const Icon(Icons.schedule, size: 15, color: Color(0xFF9AB0C3)),
                      const SizedBox(width: 4),
                      Text(
                        item.time,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9AB0C3)),
                      ),
                    ],
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

class _UnreadDot extends StatelessWidget {
  const _UnreadDot({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}
