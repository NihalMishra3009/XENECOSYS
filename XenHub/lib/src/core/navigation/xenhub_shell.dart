import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/dtn/presentation/dtn_simulator_page.dart';
import '../../features/message_queue/presentation/message_queue_page.dart';
import '../../features/relay/presentation/relay_page.dart';
import '../../features/users/presentation/users_page.dart';

class XenHubShell extends StatefulWidget {
  const XenHubShell({super.key});

  @override
  State<XenHubShell> createState() => _XenHubShellState();
}

class _XenHubShellState extends State<XenHubShell>
    with SingleTickerProviderStateMixin {
  late final TabController _controller = TabController(length: 5, vsync: this);

  static const _pages = [
    DashboardPage(),
    UsersPage(),
    MessageQueuePage(),
    RelayPage(),
    DtnSimulatorPage(),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'XenHub',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: _showEmergencyBroadcast,
              icon: const Icon(Icons.warning_amber_rounded, size: 18),
              label: const Text('Alert'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFFD66B),
                backgroundColor: const Color(
                  0xFFFFD66B,
                ).withValues(alpha: 0.12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(68),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0E1A2B).withValues(alpha: 0.84),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF2A4561).withValues(alpha: 0.48),
                ),
              ),
              child: TabBar(
                controller: _controller,
                onTap: (index) => _controller.animateTo(
                  index,
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                ),
                isScrollable: false,
                tabAlignment: TabAlignment.fill,
                labelPadding: EdgeInsets.zero,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: const Color(0xFF43D9FF).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                tabs: const [
                  Tab(text: 'Dashboard'),
                  Tab(text: 'Users'),
                  Tab(text: 'Queue'),
                  Tab(text: 'Relay'),
                  Tab(text: 'DTN'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF07111D),
              const Color(0xFF0A1727),
              const Color(0xFF0D2238),
              const Color(0xFF07111D),
            ],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              right: -120,
              top: -80,
              child: _AmbientGlow(color: Color(0x3343D9FF), size: 280),
            ),
            const Positioned(
              left: -140,
              bottom: -120,
              child: _AmbientGlow(color: Color(0x339B7BFF), size: 320),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final page = _controller.index;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final slide = Tween<Offset>(
                      begin: const Offset(0.02, 0),
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: slide, child: child),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(page),
                    child: _pages[page],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEmergencyBroadcast() async {
    final controller = TextEditingController();

    final sent = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101A29),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: const Color(0xFF4B6A86).withValues(alpha: 0.45),
            ),
          ),
          title: const Text('Emergency Broadcast'),
          content: SizedBox(
            width: 420,
            child: TextField(
              controller: controller,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              style: const TextStyle(color: Color(0xFFEAF6FF)),
              cursorColor: const Color(0xFF43D9FF),
              decoration: InputDecoration(
                labelText: 'Broadcast message',
                hintText: 'Type emergency message here...',
                filled: true,
                fillColor: const Color(0xFF152335),
                labelStyle: const TextStyle(color: Color(0xFF8AA3BF)),
                hintStyle: const TextStyle(color: Color(0xFF6F8198)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Color(0xFF2C445B)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Color(0xFF2C445B)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: Color(0xFF43D9FF),
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (!mounted || sent != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E7A4D),
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Color(0xFFEAF6FF)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Emergency broadcast sent successfully',
                style: TextStyle(color: Color(0xFFEAF6FF)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
