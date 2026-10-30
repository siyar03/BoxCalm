import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';
import 'breathe_screen.dart';
import 'presets_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  bool _seeded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final box = BoxTheme.of(context);
    final settings = context.watch<SettingsProvider>();

    // Keep the system chrome readable in both themes.
    final overlay = dark
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          );
    if (!_seeded) {
      _seeded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          SystemChrome.setSystemUIOverlayStyle(overlay);
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        }
      });
    }

    final pages = [
      BreatheScreen(onOpenPresets: () => setState(() => _index = 1)),
      const PresetsScreen(),
      const StatsScreen(),
      const SettingsScreen(),
    ];

    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _index != 0) {
          setState(() => _index = 0);
        }
      },
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(index: _index, children: pages),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(
            14,
            0,
            14,
            MediaQuery.of(context).padding.bottom > 0 ? 6 : 12,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: Container(
                decoration: BoxDecoration(
                  color: dark
                      ? const Color(0xFF0B1825).withValues(alpha: 0.88)
                      : Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: dark
                        ? Colors.white.withValues(alpha: 0.09)
                        : const Color(0xFFDDE8E5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  height: 68,
                  destinations: [
                    NavigationDestination(
                      icon: Icon(Icons.air_rounded,
                          color: box.muted),
                      selectedIcon: Icon(Icons.air_rounded,
                          color: box.palette.accent),
                      label: 'Breathe',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.grid_view_rounded,
                          color: box.muted, size: 22),
                      selectedIcon: Icon(Icons.grid_view_rounded,
                          color: box.palette.accent, size: 22),
                      label: 'Presets',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.insights_rounded,
                          color: box.muted, size: 22),
                      selectedIcon: Icon(Icons.insights_rounded,
                          color: box.palette.accent, size: 22),
                      label: 'Progress',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.tune_rounded,
                          color: box.muted, size: 22),
                      selectedIcon: Icon(Icons.tune_rounded,
                          color: box.palette.accent, size: 22),
                      label: 'Settings',
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
