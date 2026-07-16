import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/data/communication_mock_data.dart';
import '../../providers/app_providers.dart';
import '../../services/database/database_service.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  final _db = DatabaseService();
  final _scrollController = ScrollController();

  late final List<(String, String)> _contacts = [...contactSeeds];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSavedContacts());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.contactsTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: _showAddContactDialog,
              icon: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.add, color: scheme.onPrimary, size: 19),
              ),
              tooltip: 'Add contact',
            ),
          ),
        ],
      ),
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          children: [
            const _SearchCard(),
            const SizedBox(height: 14),
            if (_contacts.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(child: Text('No contacts yet')),
              )
            else
              Column(
                children: [
                  for (final contact in _contacts) ...[
                    _contactCard(
                      context,
                      contact: contact,
                      onTap: () => context.push(
                        '${AppConstants.chatRoute}?contactID=${contact.$2}&contactName=${Uri.encodeComponent(contact.$1)}',
                      ),
                      onDelete: () => _deleteContact(contact),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _contactCard(
    BuildContext context, {
    required (String, String) contact,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.65), width: 1),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Dismissible(
          key: ValueKey(contact.$2),
          direction: DismissDirection.endToStart,
          dismissThresholds: const {DismissDirection.endToStart: 0.24},
          confirmDismiss: (_) async {
            onDelete();
            return false;
          },
          background: Container(
            color: const Color(0xFFEF4444),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete_outline, color: Colors.white, size: 18),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            minLeadingWidth: 0,
            horizontalTitleGap: 14,
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: scheme.secondary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.person, color: scheme.onSecondary),
            ),
            title: Text(contact.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            subtitle: Text(contact.$2, style: const TextStyle(color: Color(0xFF9AB0C3), fontSize: 13, height: 1.2)),
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  Future<void> _loadSavedContacts() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final saved = await _db.query('contacts', where: 'userID = ?', whereArgs: [user.uniqueID]);
    if (!mounted) return;
    setState(() {
      final merged = <(String, String)>[...contactSeeds];
      for (final row in saved) {
        final name = row['name'] as String? ?? '';
        final id = row['contactUserID'] as String? ?? '';
        if (name.isEmpty || id.isEmpty) continue;
        if (!merged.any((c) => c.$2 == id)) merged.add((name, id));
      }
      _contacts
        ..clear()
        ..addAll(merged);
    });
    ref.invalidate(contactCountProvider);
  }

  Future<void> _showAddContactDialog() async {
    final nameController = TextEditingController();
    final idController = TextEditingController();
    final added = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Contact name'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: 'User ID'),
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppConstants.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final id = idController.text.trim();
              if (name.isEmpty || id.isEmpty) return;
              final user = ref.read(currentUserProvider);
              if (user == null) return;
              try {
                await ref.read(contactRepositoryProvider).addContact(user.uniqueID, id, name);
                ref.invalidate(contactCountProvider);
                if (context.mounted) Navigator.pop(context, true);
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Could not save contact'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    nameController.dispose();
    idController.dispose();
    if (added == true && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadSavedContacts();
      });
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Contact saved'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteContact((String, String) contact) async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      await ref.read(contactRepositoryProvider).removeContact(user.uniqueID, contact.$2);
    }
    if (!mounted) return;
    setState(() => _contacts.removeWhere((item) => item.$2 == contact.$2));
    ref.invalidate(contactCountProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${contact.$1} deleted'),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.65)),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: AppConstants.searchAddContacts,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.search, color: scheme.onPrimary),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 52, minHeight: 52),
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: scheme.primary),
          ),
        ),
      ),
    );
  }
}
