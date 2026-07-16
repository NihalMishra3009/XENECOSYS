import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../repositories/impl/data_mule_repository_impl.dart';
import '../widgets/feature_bottom_nav.dart';

class DataMuleDashboardScreen extends StatelessWidget {
  const DataMuleDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muleRepo = DataMuleRepositoryImpl();
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.muleDashboardTitle),
      ),
      body: FutureBuilder(
        future: muleRepo.getAllDataMules(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final mules = snapshot.data ?? [];
          return ListView.builder(
            itemCount: mules.length,
            itemBuilder: (context, index) {
              final mule = mules[index];
              return Card(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.65)),
                ),
                child: ExpansionTile(
                  title: Text(mule.vehicleID),
                  subtitle: Text('${mule.type} · ${mule.status}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Type: ${mule.type}'),
                          Text('Capacity: ${mule.capacity} bytes'),
                          Text('Current Hub: ${mule.currentHub}'),
                          Text('Next Hub: ${mule.nextHub}'),
                          Text('Speed: ${mule.speed} km/h'),
                          const Text('Arrival Estimate: ~2h'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const FeatureBottomNav(activeRoute: AppConstants.muleDashboardRoute),
    );
  }
}
