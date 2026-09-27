import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/event_log.dart';
import '../../widgets/sakhi_map.dart';

class GuardianScreen extends StatefulWidget {
  const GuardianScreen({super.key});

  @override
  State<GuardianScreen> createState() => _GuardianScreenState();
}

class _GuardianScreenState extends State<GuardianScreen> {
  final _watchId = TextEditingController();

  @override
  void dispose() {
    _watchId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final target = state.guardianTarget;
    final active = target?.active ?? false;
    final path = target?.path ?? const [];
    final last = path.isNotEmpty
        ? LatLng(path.last.lat, path.last.lng)
        : (target == null ? null : state.lastPos);

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const H1('Guardian Console'),
            StatusPill(
              active ? PillKind.live : PillKind.safe,
              active ? 'Live alert' : 'All clear',
            ),
          ],
        ),
        const SizedBox(height: 4),
        Sub(target == null
            ? 'No active alert on this device. Cloud watch-by-ID is unavailable in local mode.'
            : 'Tracking ${target.victim} on this device.'),
        const SizedBox(height: 12),
        if (state.cloudEnabled)
          SakhiCard(
            tight: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Watch by alert ID'),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _watchId,
                        textCapitalization: TextCapitalization.characters,
                        decoration:
                            const InputDecoration(hintText: 'e.g. BLR-1234'),
                        onSubmitted: state.watchRemote,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SakhiButton(
                      'Watch',
                      onTap: () => state.watchRemote(_watchId.text),
                    ),
                  ],
                ),
                if (state.remoteWatchId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Watching ${state.remoteWatchId}',
                            style: kMono.copyWith(
                              fontSize: 12,
                              color: C.guard,
                            ),
                          ),
                        ),
                        SakhiButton(
                          'Stop',
                          small: true,
                          onTap: state.stopRemoteWatch,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          )
        else
          const SakhiCard(
            tight: true,
            child: Sub(
              'Cloud sync is off. Watch-by-ID requires Firebase; local demo alerts appear below.',
            ),
          ),
        if (target != null) ...[
          SakhiCard(
            child: Row(
              children: [
                Avatar(initials(target.victim)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        target.victim,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${target.id} · started ${hhmm(DateTime.fromMillisecondsSinceEpoch(target.startedAt))}',
                        style: kMono.copyWith(fontSize: 10.5, color: C.muted),
                      ),
                    ],
                  ),
                ),
                if (target.phone.isNotEmpty)
                  IconBtn(
                    '☎',
                    tooltip: 'Call victim',
                    onTap: () => state.launch(
                      Uri(scheme: 'tel', path: telSafe(target.phone)),
                    ),
                  ),
              ],
            ),
          ),
          SakhiMap(
            height: 340,
            zoom: 15,
            victim: last,
            trail: [for (final point in path) LatLng(point.lat, point.lng)],
            follow: active,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SakhiButton(
                  'Call 112',
                  style: BtnStyle.rose,
                  onTap: () => state.launch(Uri(scheme: 'tel', path: '112')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SakhiButton(
                  'Mark victim safe',
                  style: BtnStyle.guard,
                  onTap: state.guardianResolve,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SakhiCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const H2('Event log'),
                const SizedBox(height: 10),
                EventLog(
                  target.events,
                  emptyText: 'Awaiting events from the victim device…',
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}