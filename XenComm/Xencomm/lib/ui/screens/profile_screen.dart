import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/app_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(AppConstants.profileTitle),
          leading: BackButton(onPressed: () => context.pop()),
        ),
        body: const Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.profileTitle),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          TextButton.icon(
            onPressed: () => _editName(context, ref, currentUser.name),
            icon: const Icon(Icons.edit, size: 18),
            label: const Text(AppConstants.editProfile),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              child: Text(
                currentUser.name.isNotEmpty ? currentUser.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _info('Name', currentUser.name),
          _copyableInfo(context, 'User ID', currentUser.uniqueID),
          _info('Device ID', currentUser.deviceID),
          _info('Home Hub', currentUser.homeHubID),
          _info('Current Hub', currentUser.currentHubID),
          _info('Member Since', currentUser.createdAt.toString().split(' ')[0]),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _editName(context, ref, currentUser.name),
            icon: const Icon(Icons.edit),
            label: const Text('Edit name'),
          ),
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _copyableInfo(BuildContext context, String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(value, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: value));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User ID copied')));
                }
              },
              icon: const Icon(Icons.copy),
              tooltip: 'Copy user ID',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editName(BuildContext context, WidgetRef ref, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppConstants.editProfile),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Name'),
          textInputAction: TextInputAction.done,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppConstants.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved != true) {
      controller.dispose();
      return;
    }

    final name = controller.text.trim();
    controller.dispose();
    if (name.isEmpty) return;

    await ref.read(currentUserProvider.notifier).updateName(name);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(AppConstants.profileUpdated)));
    }
  }
}
