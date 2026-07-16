import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/app_providers.dart';
import '../widgets/floating_tab_dock.dart';
import 'emergency_broadcast_screen.dart';
import 'home_screen.dart';
import 'others_screen.dart';
import 'schedules_screen.dart';

class CommunicationShellScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const CommunicationShellScreen({super.key, required this.initialIndex});

  @override
  ConsumerState<CommunicationShellScreen> createState() => _CommunicationShellScreenState();
}

class _CommunicationShellScreenState extends ConsumerState<CommunicationShellScreen> {
  late int _index = widget.initialIndex;

  String get _activeRoute {
    switch (_index) {
      case 0:
        return AppConstants.homeRoute;
      case 1:
        return AppConstants.emergencyBroadcastRoute;
      case 2:
        return AppConstants.schedulesRoute;
      case 3:
        return AppConstants.othersRoute;
      default:
        return AppConstants.homeRoute;
    }
  }

  void _openConnectedHub(BuildContext context) => context.push(AppConstants.connectedHubRoute);
  void _openPendingMessages(BuildContext context) => context.push(AppConstants.pendingMessagesRoute);
  void _openContacts(BuildContext context) => context.push(AppConstants.contactsRoute);
  void _openEmergencyAlerts(BuildContext context) => context.push(AppConstants.emergencyAlertsRoute);

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF08111B),
      body: Stack(
        children: [
          const _GlowBlob(
            top: -90,
            right: -70,
            size: 280,
            color: Color(0x334A8FD9),
          ),
          const _GlowBlob(
            top: 150,
            left: -90,
            size: 240,
            color: Color(0x224CCCE0),
          ),
          const _GlowBlob(
            bottom: 80,
            right: -50,
            size: 220,
            color: Color(0x224A78A8),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF09131D),
                    Color(0xFF0E1722),
                    Color(0xFF0A121B),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 88),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => context.push(AppConstants.profileRoute),
                              child: Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF20314A), Color(0xFF4A78A8)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF20314A).withValues(alpha: 0.32),
                                      blurRadius: 22,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.person, size: 28, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentUser?.name ?? AppConstants.appName,
                                      style: const TextStyle(
                                        color: Color(0xFFEAF4FB),
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        height: 1.02,
                                      ),
                                    ),
                                    Text(
                                      currentUser?.uniqueID ?? AppConstants.homeTitle,
                                      style: const TextStyle(
                                        color: Color(0xFFA2B6C8),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        height: 1.0,
                                      ),
                                    ),
                                    const Text(
                                      'Location: Navi Mumbai',
                                      style: TextStyle(
                                        color: Color(0xFFA2B6C8),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        height: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                        child: IndexedStack(
                          index: _index,
                          children: [
                            HomeScreen(
                              onConnectedHubTap: () => _openConnectedHub(context),
                              onPendingMessagesTap: () => _openPendingMessages(context),
                              onContactsTap: () => _openContacts(context),
                              onEmergencyAlertsTap: () => _openEmergencyAlerts(context),
                            ),
                            const EmergencyBroadcastScreen(),
                            const SchedulesScreen(),
                            const OthersScreen(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomInset + 14,
            child: Center(
              child: FloatingTabDock(
                activeRoute: _activeRoute,
                onHomeTap: () => setState(() => _index = 0),
                onBroadcastTap: () => setState(() => _index = 1),
                onSchedulesTap: () => setState(() => _index = 2),
                onOthersTap: () => setState(() => _index = 3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final double size;
  final Color color;

  const _GlowBlob({
    this.top,
    this.right,
    this.bottom,
    this.left,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
          ),
        ),
      ),
    );
  }
}
