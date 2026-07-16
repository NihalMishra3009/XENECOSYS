import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/app_providers.dart';
import '../../repositories/impl/hub_repository_impl.dart';
import '../widgets/feature_bottom_nav.dart';

class HubDashboardScreen extends ConsumerStatefulWidget {
  const HubDashboardScreen({super.key});

  @override
  ConsumerState<HubDashboardScreen> createState() => _HubDashboardScreenState();
}

class _HubDashboardScreenState extends ConsumerState<HubDashboardScreen> {
  final _hubRepo = HubRepositoryImpl();

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.hubDashboardTitle),
      ),
      body: FutureBuilder(
        future: _hubRepo.getHubByID(currentUser?.currentHubID ?? ''),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final hub = snapshot.data;
          if (hub == null) return const Center(child: Text('Hub not found'));
          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.92,
              children: [
                _stat(context, 'Hub Name', hub.hubName),
                _stat(context, 'Hub ID', hub.hubID),
                _stat(context, 'Registered Users', '${hub.registeredUsers.length}'),
                _stat(context, 'Pending Bundles', '${hub.pendingBundles.length}'),
                _stat(context, 'Received Bundles', '${hub.receivedBundles.length}'),
                _stat(context, 'Connected Data Mules', '${hub.connectedDataMules.length}'),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const FeatureBottomNav(activeRoute: AppConstants.hubDashboardRoute),
    );
  }

  Widget _stat(BuildContext context, String title, String value) => Card(
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.65)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
}
