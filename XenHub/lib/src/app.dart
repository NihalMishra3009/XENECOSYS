import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/navigation/xenhub_shell.dart';
import 'core/theme/xenhub_theme.dart';

class XenHubApp extends StatelessWidget {
  const XenHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF43D9FF),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'XenHub',
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: const TextScaler.linear(1.06)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: buildXenHubTheme(scheme),
      home: const _SplashGate(),
    );
  }
}

class _SplashGate extends StatelessWidget {
  const _SplashGate();

  @override
  Widget build(BuildContext context) {
    return const _SplashThenApp(child: XenHubShell());
  }
}

class _SplashThenApp extends StatefulWidget {
  const _SplashThenApp({required this.child});

  final Widget child;

  @override
  State<_SplashThenApp> createState() => _SplashThenAppState();
}

class _SplashThenAppState extends State<_SplashThenApp> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() => _showSplash = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _showSplash ? const _SplashScreen() : widget.child,
    );
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF43D9FF),
      brightness: Brightness.dark,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF07111D),
              const Color(0xFF0A1727),
              scheme.primary.withValues(alpha: 0.08),
              const Color(0xFF07111D),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF43D9FF).withValues(alpha: 0.35),
                      width: 1.4,
                    ),
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF43D9FF).withValues(alpha: 0.18),
                        const Color(0xFF43D9FF).withValues(alpha: 0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.hub_outlined,
                    size: 42,
                    color: Color(0xFFEAF6FF),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'XenHub',
                  style: GoogleFonts.orbitron(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEAF6FF),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Loading the command center',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8AA3BF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
