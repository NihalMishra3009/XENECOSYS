import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _darkModeEnabled = prefs.getBool('darkModeEnabled') ??
          WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.settingsTitle),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _section(AppConstants.notificationsTitle),
          SwitchListTile(
            title: const Text(AppConstants.enableNotifications),
            subtitle: const Text(AppConstants.receiveAlerts),
            value: _notificationsEnabled,
            onChanged: (value) async {
              final prefs = await SharedPreferences.getInstance();
              setState(() => _notificationsEnabled = value);
              await prefs.setBool('notificationsEnabled', value);
              if (!mounted) return;
              await _showPopupNotification(
                value ? 'Notifications enabled' : 'Notifications muted',
                value ? 'You will see alerts and updates.' : 'Alerts are hidden for now.',
                value,
              );
            },
          ),
          const Divider(),
          _section(AppConstants.displayTitle),
          SwitchListTile(
            title: const Text(AppConstants.darkMode),
            subtitle: const Text(AppConstants.useDarkTheme),
            value: _darkModeEnabled,
            onChanged: (value) async {
              final prefs = await SharedPreferences.getInstance();
              setState(() => _darkModeEnabled = value);
              await prefs.setBool('darkModeEnabled', value);
              await ref.read(themeModeProvider.notifier).setDarkMode(value);
            },
          ),
          const Divider(),
          _section(AppConstants.dataTitle),
          ListTile(
            title: const Text(AppConstants.clearLocalCache),
            subtitle: const Text(AppConstants.removeTempFiles),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showClearCacheDialog,
          ),
          const ListTile(
            title: Text(AppConstants.databaseSize),
            subtitle: Text('0 MB'),
            trailing: Icon(Icons.chevron_right),
          ),
          const Divider(),
          _section(AppConstants.aboutTitle),
          const ListTile(title: Text(AppConstants.appName), subtitle: Text(AppConstants.appVersion)),
          const ListTile(title: Text('Delay-Tolerant Emergency Communication')),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppConstants.clearCache),
        content: const Text('Are you sure? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text(AppConstants.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(AppConstants.cacheCleared)));
            },
            child: const Text(AppConstants.clear),
          ),
        ],
      ),
    );
  }

  Future<void> _showPopupNotification(String title, String message, bool enabled) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      barrierLabel: 'notification',
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.15),
                  end: Offset.zero,
                ).animate(curved),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 360),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.14),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: enabled ? 0.12 : 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              enabled ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
                              size: 20,
                              color: enabled ? Theme.of(context).colorScheme.primary : Theme.of(context).hintColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(message, style: const TextStyle(fontSize: 12, height: 1.25)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
