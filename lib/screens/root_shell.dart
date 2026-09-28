import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/report_sheet.dart';
import '../widgets/sos_sheet.dart';
import 'admin/admin_screen.dart';
import 'guardian/guardian_screen.dart';
import 'user/contacts_screen.dart';
import 'user/home_screen.dart';
import 'user/journey_screen.dart';
import 'user/safety_screen.dart';
import 'user/track_screen.dart';

class RootShell extends StatelessWidget {
  const RootShell({super.key});

  static const _userTabs = [
    (Icons.home_outlined, 'Home'),
    (Icons.location_on_outlined, 'Track'),
    (Icons.explore_outlined, 'Journey'),
    (Icons.people_outline, 'Guardians'),
    (Icons.shield_outlined, 'Safety'),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _TopBar(state: state),
                Expanded(child: _body(state)),
              ],
            ),
            if (state.role == AppRole.user) _BottomTabs(state: state),
            ToastLayer(visible: state.toastVisible, message: state.toastMsg),
            const SosSheet(),
            const ReportSheet(),
          ],
        ),
      ),
    );
  }

  Widget _body(AppState state) {
    switch (state.role) {
      case AppRole.guardian:
        return const GuardianScreen();
      case AppRole.admin:
        return const AdminScreen();
      case AppRole.user:
        return IndexedStack(
          index: state.tabIndex,
          children: const [
            HomeScreen(),
            TrackScreen(),
            JourneyScreen(),
            ContactsScreen(),
            SafetyScreen(),
          ],
        );
    }
  }
}

class _TopBar extends StatelessWidget {
  final AppState state;

  const _TopBar({required this.state});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
    decoration: BoxDecoration(
      color: C.night.withValues(alpha: .94),
      border: Border(bottom: BorderSide(color: C.line)),
    ),
    child: Column(
      children: [
        Row(
          children: [
            const ShieldLogo(size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SAKHI',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                  Text(
                    state.geo.demo
                        ? 'Safety Network · Demo GPS'
                        : state.hasRealFix
                        ? 'Safety Network · Live GPS'
                        : 'Safety Network · Locating GPS',
                    style: kMono.copyWith(fontSize: 9, color: C.faint),
                  ),
                ],
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: state.toggleDemo,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: state.geo.demo
                      ? C.violet.withValues(alpha: .10)
                      : C.guard.withValues(alpha: .10),
                  border: Border.all(
                    color: state.geo.demo
                        ? C.violet.withValues(alpha: .55)
                        : C.guard.withValues(alpha: .55),
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      state.geo.demo ? Icons.science_outlined : Icons.gps_fixed,
                      size: 14,
                      color: state.geo.demo ? C.violet : C.guard,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      state.geo.demo ? 'DEMO GPS' : 'REAL GPS',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: state.geo.demo ? C.violet : C.guard,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (kIsWeb)
              IconButton(
                tooltip: 'Download Android APK',
                onPressed: () => state.launch(Uri.base.resolve('sakhi.apk')),
                icon: const Icon(Icons.download_rounded),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _RoleSegment(state: state),
      ],
    ),
  );
}

class _RoleSegment extends StatelessWidget {
  final AppState state;

  const _RoleSegment({required this.state});

  static const _roles = [
    (AppRole.user, 'User'),
    (AppRole.guardian, 'Guardian'),
    (AppRole.admin, 'Control Room'),
  ];

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: .28),
      border: Border.all(color: C.line),
      borderRadius: BorderRadius.circular(C.rSm),
    ),
    child: Row(
      children: [
        for (final role in _roles)
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => state.setRole(role.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: state.role == role.$1 ? C.rose : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  role.$2,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: state.role == role.$1 ? Colors.white : C.muted,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _BottomTabs extends StatelessWidget {
  final AppState state;

  const _BottomTabs({required this.state});

  @override
  Widget build(BuildContext context) => Positioned(
    left: 14,
    right: 14,
    bottom: 14 + MediaQuery.of(context).padding.bottom,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: C.night2.withValues(alpha: .97),
        border: Border.all(color: C.line),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .45),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < RootShell._userTabs.length; i++)
            Expanded(
              child: _Tab(
                icon: RootShell._userTabs[i].$1,
                label: RootShell._userTabs[i].$2,
                active: state.tabIndex == i,
                onTap: () => state.setTab(i),
              ),
            ),
        ],
      ),
    ),
  );
}

class _Tab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: onTap,
    child: Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: active ? C.rose.withValues(alpha: .12) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: active ? C.rose : C.faint),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: active ? C.rose : C.faint,
            ),
          ),
        ],
      ),
    ),
  );
}
