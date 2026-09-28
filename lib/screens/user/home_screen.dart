import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/sos_button.dart';
import '../../widgets/telemetry_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _holdTimer;

  void _down(AppState state) {
    _holdTimer?.cancel();
    _holdTimer = Timer(const Duration(seconds: 3), state.silentHoldTrigger);
  }

  void _up() => _holdTimer?.cancel();

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Listener(
      onPointerDown: (_) => _down(context.read<AppState>()),
      onPointerUp: (_) => _up(),
      onPointerCancel: (_) => _up(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 110),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('Hello'),
                  const SizedBox(height: 2),
                  H1(state.profile.name.isEmpty ? '—' : state.profile.name),
                ],
              ),
              StatusPill(
                state.sosActive ? PillKind.live : PillKind.idle,
                state.sosActive
                    ? 'SOS ACTIVE'
                    : state.geo.demo
                    ? 'Demo ready'
                    : state.hasRealFix
                    ? 'GPS ready'
                    : 'Locating GPS',
              ),
            ],
          ),
          SosButton(live: state.sosActive, onTap: state.armSos),
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text(
              'Tap once to arm · Hold anywhere 3s for silent trigger',
              textAlign: TextAlign.center,
              style: TextStyle(color: C.faint, fontSize: 11.5),
            ),
          ),
          const SizedBox(height: 14),
          TelemetryBar([
            ('LAT', state.lastPos?.latitude.toStringAsFixed(5) ?? '--'),
            ('LNG', state.lastPos?.longitude.toStringAsFixed(5) ?? '--'),
            ('SPEED', '${state.spd.toStringAsFixed(1)} km/h'),
            ('SIGNAL', state.accText),
          ]),
          const SizedBox(height: 14),
          Row(
            children: [
              _QuickAction(
                'Siren',
                on: state.sirenOn,
                onTap: state.toggleSiren,
              ),
              const SizedBox(width: 9),
              _QuickAction(
                'Flash',
                on: state.strobeOn,
                onTap: state.toggleStrobe,
              ),
              const SizedBox(width: 9),
              _QuickAction('Fake call', onTap: state.startFakeCall),
              const SizedBox(width: 9),
              _QuickAction('Evidence', onTap: state.capturePhoto),
            ],
          ),
          SakhiCard(
            tight: true,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const H2('Shake-to-SOS'),
                      const SizedBox(height: 3),
                      Sub(
                        state.motionArmed
                            ? 'Armed for this session.'
                            : 'Enable the motion trigger for this session.',
                      ),
                    ],
                  ),
                ),
                SakhiButton(
                  state.motionArmed ? 'Armed' : 'Enable',
                  small: true,
                  onTap: state.motionArmed ? null : state.enableMotion,
                ),
              ],
            ),
          ),
          SakhiCard(
            tight: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Eyebrow('How SAKHI works'),
                SizedBox(height: 9),
                _Step(C.rose, '1 · Trigger', ' — tap or hold to start SOS.'),
                _Step(
                  C.amber,
                  '2 · Alert',
                  ' — your alert and live trail appear in the console.',
                ),
                _Step(
                  C.guard,
                  '3 · Respond',
                  ' — guardians can follow your location until you are safe.',
                ),
              ],
            ),
          ),
          SakhiButton(
            'Run demo alert',
            style: BtnStyle.ghost,
            block: true,
            onTap: state.runDemoTour,
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final bool on;
  final VoidCallback onTap;

  const _QuickAction(this.label, {this.on = false, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      borderRadius: BorderRadius.circular(C.rSm),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 70),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: on ? C.amber.withValues(alpha: .08) : C.panel,
          border: Border.all(color: on ? C.amber : C.line),
          borderRadius: BorderRadius.circular(C.rSm),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_icon, size: 19, color: on ? C.amber : C.muted),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: on ? C.amber : C.muted,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  IconData get _icon => switch (label) {
    'Siren' => Icons.campaign_outlined,
    'Flash' => Icons.flash_on_outlined,
    'Fake call' => Icons.call_outlined,
    _ => Icons.photo_camera_outlined,
  };
}

class _Step extends StatelessWidget {
  final Color color;
  final String title;
  final String detail;

  const _Step(this.color, this.title, this.detail);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5, right: 9),
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: C.ink,
                  ),
                ),
                TextSpan(text: detail),
              ],
            ),
            style: const TextStyle(
              fontSize: 12.5,
              color: C.muted,
              height: 1.45,
            ),
          ),
        ),
      ],
    ),
  );
}
