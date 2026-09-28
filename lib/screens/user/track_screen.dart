import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/utils.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/sakhi_map.dart';
import '../../widgets/telemetry_bar.dart';

class TrackScreen extends StatelessWidget {
  const TrackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final active = state.sosActive;
    final path = state.session?.path ?? const [];
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 110),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const H1('Live Track'),
            StatusPill(
              active ? PillKind.live : PillKind.idle,
              active ? 'Broadcasting' : 'Idle',
            ),
          ],
        ),
        const SizedBox(height: 10),
        SakhiMap(
          height: 380,
          zoom: 15,
          victim: state.lastPos,
          trail: [for (final point in path) LatLng(point.lat, point.lng)],
          follow: active || !state.geo.demo,
        ),
        const SizedBox(height: 10),
        TelemetryBar([
          ('POINTS', '${path.length}'),
          ('DISTANCE', fmtDist(state.pathDistance)),
          (
            'ELAPSED',
            active && state.session != null
                ? fmtEla(
                    Duration(
                      milliseconds:
                          DateTime.now().millisecondsSinceEpoch -
                          state.session!.startedAt,
                    ),
                  )
                : '00:00',
          ),
          ('SESSION', state.session?.id ?? '—'),
        ]),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SakhiButton(
                'Copy track link',
                style: BtnStyle.ghost,
                onTap: state.copyTrackInfo,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SakhiButton('Share location', onTap: state.shareLocation),
            ),
          ],
        ),
      ],
    );
  }
}
