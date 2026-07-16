import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/screens/chat_screen.dart';
import '../ui/screens/connected_hub_details_screen.dart';
import '../ui/screens/contacts_screen.dart';
import '../ui/screens/communication_shell_screen.dart';
import '../ui/screens/emergency_alerts_screen.dart';
import '../ui/screens/nearby_hub_screen.dart';
import '../ui/screens/pending_messages_screen.dart';
import '../ui/screens/profile_screen.dart';
import '../ui/screens/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  errorBuilder: (context, state) => const PendingMessagesScreen(),
  routes: [
    GoRoute(path: '/home', pageBuilder: (context, state) => _instantPage(state, const CommunicationShellScreen(initialIndex: 0))),
    GoRoute(path: '/schedules', pageBuilder: (context, state) => _instantPage(state, const CommunicationShellScreen(initialIndex: 2))),
    GoRoute(path: '/others', pageBuilder: (context, state) => _instantPage(state, const CommunicationShellScreen(initialIndex: 3))),
    GoRoute(path: '/contacts', pageBuilder: (context, state) => _page(state, const ContactsScreen())),
    GoRoute(path: '/pending_messages', pageBuilder: (context, state) => _page(state, const PendingMessagesScreen())),
    GoRoute(path: '/connected_hub', pageBuilder: (context, state) => _page(state, const ConnectedHubDetailsScreen())),
    GoRoute(path: '/emergency_alerts', pageBuilder: (context, state) => _page(state, const EmergencyAlertsScreen())),
    GoRoute(path: '/nearby_hub', pageBuilder: (context, state) => _page(state, const NearbyHubScreen())),
    GoRoute(
      path: '/chat',
      pageBuilder: (context, state) => _page(
        state,
        ChatScreen(
          contactID: state.uri.queryParameters['contactID'] ?? '',
          contactName: state.uri.queryParameters['contactName'] ?? '',
        ),
      ),
    ),
    GoRoute(path: '/settings', pageBuilder: (context, state) => _page(state, const SettingsScreen())),
    GoRoute(path: '/emergency_broadcast', pageBuilder: (context, state) => _instantPage(state, const CommunicationShellScreen(initialIndex: 1))),
    GoRoute(path: '/profile', pageBuilder: (context, state) => _page(state, const ProfileScreen())),
  ],
);

CustomTransitionPage<void> _page(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0.015, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));

      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: SlideTransition(
          position: animation.drive(slide),
          child: child,
        ),
      );
    },
  );
}

CustomTransitionPage<void> _instantPage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      final scale = Tween<double>(begin: 0.975, end: 1).animate(fade);
      return FadeTransition(
        opacity: fade,
        child: ScaleTransition(scale: scale, child: child),
      );
    },
  );
}
