import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'core/constants/app_constants.dart';
import 'providers/settings_provider.dart';
import 'routing/app_router.dart';
import 'services/auth_service.dart';
import 'services/database/database_service.dart';
import 'ui/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: XenCommBootstrap()));
}

class XenCommBootstrap extends ConsumerStatefulWidget {
  const XenCommBootstrap({super.key});

  @override
  ConsumerState<XenCommBootstrap> createState() => _XenCommBootstrapState();
}

class _XenCommBootstrapState extends ConsumerState<XenCommBootstrap> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await DatabaseService().database;
    await AuthService().init();
    if (!mounted) return;
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 700),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        final scale = Tween<double>(begin: 0.96, end: 1).animate(fade);
        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(scale: scale, child: child),
        );
      },
      child: _ready ? const XenCommApp(key: ValueKey('app')) : const _SplashGate(key: ValueKey('splash')),
    );
  }
}

class _SplashGate extends StatelessWidget {
  const _SplashGate({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? Colors.white : Colors.black;
    return SizedBox.expand(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    const FlutterLogo(size: 88),
                    const SizedBox(height: 18),
                    Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: fg,
                        fontFamily: 'Comfortaa',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Delay-Tolerant Emergency Communication Platform',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: fg.withValues(alpha: 0.72), fontFamily: 'Comfortaa'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class XenCommApp extends ConsumerWidget {
  const XenCommApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _overlayStyle(),
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: themeMode,
        routerConfig: appRouter,
      ),
    );
  }
}

SystemUiOverlayStyle _overlayStyle() {
  return const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFF08111B),
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.transparent,
  );
}
