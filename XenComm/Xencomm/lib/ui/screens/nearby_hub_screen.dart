import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/app_providers.dart';
import '../../repositories/impl/hub_repository_impl.dart';
import '../widgets/feature_bottom_nav.dart';

class NearbyHubScreen extends ConsumerWidget {
  const NearbyHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final hubRepo = HubRepositoryImpl();
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.nearbyHubTitle)),
      body: FutureBuilder(
        future: hubRepo.getHubByID(currentUser?.currentHubID ?? ''),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final hub = snapshot.data;
          if (hub == null) {
            return const Center(child: Text('Hub not found'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _tile(context, 'Hub Name', hub.hubName),
              _tile(context, 'Hub ID', hub.hubID),
              _tile(context, 'Location', _formatLocation(hub.location)),
              _tile(context, 'Registered Users', '${hub.registeredUsers.length}'),
              _tile(context, 'Connected Data Mules', '${hub.connectedDataMules.length}'),
            ],
          );
        },
      ),
      bottomNavigationBar: const FeatureBottomNav(activeRoute: AppConstants.homeRoute),
    );
  }

  Widget _tile(BuildContext context, String title, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.65)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Theme.of(context).hintColor)),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatLocation(Map<String, dynamic> location) {
    final entries = location.entries
        .where((entry) => entry.value != null && entry.value.toString().trim().isNotEmpty)
        .map((entry) => '${entry.key}: ${entry.value}')
        .toList();
    return entries.isEmpty ? 'Unknown' : entries.join(', ');
  }
}
