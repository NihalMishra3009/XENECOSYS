import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/communication_mock_data.dart';
import '../../providers/app_providers.dart';
import '../widgets/dashboard_cards_section.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback onConnectedHubTap;
  final VoidCallback onPendingMessagesTap;
  final VoidCallback onContactsTap;
  final VoidCallback onEmergencyAlertsTap;

  const HomeScreen({
    super.key,
    required this.onConnectedHubTap,
    required this.onPendingMessagesTap,
    required this.onContactsTap,
    required this.onEmergencyAlertsTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final contactCount = ref.watch(contactCountProvider).maybeWhen(
          data: (value) => value,
          orElse: () => contactSeeds.length,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        DashboardCardsSection(
          connectedHubId: currentUser?.currentHubID ?? 'HUB-001',
          pendingMessagesCount: pendingMessagesMock.length,
          contactsCount: contactCount,
          emergencyAlertsCount: emergencyAlertsMock.length,
          onConnectedHubTap: onConnectedHubTap,
          onPendingMessagesTap: onPendingMessagesTap,
          onContactsTap: onContactsTap,
          onEmergencyAlertsTap: onEmergencyAlertsTap,
          selectedRecipient: 'Aarav Sharma',
          onSendTap: () {},
        ),
      ],
    );
  }
}
