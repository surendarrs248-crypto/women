import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/sakhi_map.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  late final TextEditingController _eta;

  @override
  void initState() {
    super.initState();
    _eta = TextEditingController(text: '${context.read<AppState>().etaMinutes}');
  }

  @override
  void dispose() {
    _eta.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final journey = state.journey;
    final path = state.session?.path ?? const <TrackPoint>[];
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 110),
      children: [
        const H1('Journey Mode'),
        const SizedBox(height: 4),
        const Sub(
          'Set a destination and ETA. Journey monitoring can flag a route deviation or an extended stop.',
        ),
        const SizedBox(height: 12),
        SakhiCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('Destination'),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < destOptions.length; i++)
                    Chip2(
                      destOptions[i].label,
                      on: state.destIndex == i,
                      onTap: () => state.setDest(i),
                    ),
                ],
              ),
              const SizedBox(height: 11),
              const Eyebrow('Expected time (minutes)'),
              const SizedBox(height: 6),
              TextField(
                controller: _eta,
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    state.setEta(int.tryParse(value) ?? state.etaMinutes),
              ),
              const SizedBox(height: 11),
              SakhiButton(
                journey == null ? 'Start guarded journey' : 'End journey',
                style: journey == null ? BtnStyle.rose : BtnStyle.plain,
                block: true,
                onTap: state.toggleJourney,
              ),
            ],
          ),
        ),
        SakhiMap(
          height: 300,
          victim: state.lastPos,
          routeFrom: journey?.from,
          routeTo: journey?.to,
          dest: journey?.to,
          trail: [for (final point in path) LatLng(point.lat, point.lng)],
          fitStamp: state.journeyFitStamp,
        ),
        if (journey != null) ...[
          const SizedBox(height: 12),
          SakhiCard(
            tight: true,
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: StatusPill(PillKind.warn, state.jStateText),
                    ),
                    Text(
                      state.jClockText,
                      style: kMono.copyWith(fontSize: 12.5, color: C.muted),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SakhiButton(
                        'Simulate deviation',
                        small: true,
                        style: BtnStyle.ghost,
                        onTap: state.simulateDeviation,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SakhiButton(
                        'Simulate stop',
                        small: true,
                        style: BtnStyle.ghost,
                        onTap: state.simulateStop,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}