import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/sakhi_map.dart';

class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 110),
      children: [
        const H1('Area Safety'),
        const SizedBox(height: 4),
            const Sub('Local demo reports and verified help nearby in Bengaluru.'),
        const SizedBox(height: 12),
        SakhiMap(
          height: 300,
          zoom: 13,
          victim: state.lastPos,
          heat: state.heatPoints,
          showHelp: true,
          onHelpTap: (spot) => state.toast('${spot.name} · ${spot.type}'),
        ),
        const SizedBox(height: 12),
        SakhiButton(
          'Report an unsafe area here',
          block: true,
          style: BtnStyle.amber,
          onTap: state.openReportSheet,
        ),
        const SizedBox(height: 14),
        SakhiCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const H2('Helplines'),
              const SizedBox(height: 10),
              for (var i = 0; i < helplines.length; i += 2) ...[
                if (i > 0) const SizedBox(height: 9),
                Row(
                  children: [
                    for (var j = i; j < i + 2 && j < helplines.length; j++) ...[
                      if (j > i) const SizedBox(width: 10),
                      Expanded(
                        child: SakhiButton(
                          '${helplines[j].number} ${helplines[j].label.substring(helplines[j].number.length).trim()}',
                          style: j == 0 ? BtnStyle.rose : BtnStyle.ghost,
                          onTap: () => state.launch(Uri(
                            scheme: 'tel',
                            path: helplines[j].number,
                          )),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
        SakhiCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const H2('Nearest help'),
              const SizedBox(height: 4),
              const Sub('Sample locations'),
              const SizedBox(height: 4),
              for (var i = 0; i < helpSpots.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Avatar(helpSpots[i].type == 'Police' ? 'P' : 'H'),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              helpSpots[i].name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${helpSpots[i].type}${state.lastPos != null ? ' · ${fmtDist(hav(state.lastPos!, helpSpots[i].point))}' : ''}',
                              style: kMono.copyWith(
                                fontSize: 10.5,
                                color: C.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconBtn(
                        '☎',
                        tooltip: 'Call emergency services',
                        onTap: () =>
                            state.launch(Uri(scheme: 'tel', path: '112')),
                      ),
                      IconBtn(
                        '↗',
                        tooltip: 'Directions',
                        onTap: () => state.launch(Uri.parse(
                          'https://www.openstreetmap.org/directions?to=${helpSpots[i].point.latitude}%2C${helpSpots[i].point.longitude}',
                        )),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}