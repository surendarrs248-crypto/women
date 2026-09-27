import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/sakhi_map.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final cards = state.alertCards;
    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth > 720;
        final queue = _AlertQueue(state: state, cards: cards);
        final map = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SakhiMap(
              height: 380,
              zoom: 12,
              alertPaths: [
                for (final card in cards)
                  AlertPath(state.pathFor(card), card.active),
              ],
            ),
            const SizedBox(height: 12),
            SakhiButton(
              'Export alerts (JSON)',
              style: BtnStyle.ghost,
              block: true,
              onTap: state.exportAlerts,
            ),
          ],
        );

        return ListView(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const H1('Control Room'),
                const StatusPill(PillKind.live, 'Monitoring'),
              ],
            ),
            const SizedBox(height: 4),
            const Sub('City-wide view of alerts recorded on this device.'),
            const SizedBox(height: 14),
            Row(
              children: [
                _Stat('${state.statActive}', 'Active', C.rose),
                const SizedBox(width: 8),
                _Stat('${state.statResolved}', 'Resolved', C.guard),
                const SizedBox(width: 8),
                _Stat('${state.statGuardians}', 'Guardians', C.violet),
                const SizedBox(width: 8),
                const _Stat('Local', 'Cloud', C.amber),
              ],
            ),
            const SizedBox(height: 14),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: queue),
                  const SizedBox(width: 14),
                  Expanded(flex: 6, child: map),
                ],
              )
            else ...[
              queue,
              map,
            ],
          ],
        );
      },
    );
  }
}

class _AlertQueue extends StatelessWidget {
  final AppState state;
  final List<AlertCardData> cards;

  const _AlertQueue({required this.state, required this.cards});

  @override
  Widget build(BuildContext context) => SakhiCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const H2('Alert queue'),
                Text(
                  state.cloudEnabled ? 'live · cloud' : 'local',
                  style: kMono.copyWith(fontSize: 10.5, color: C.faint),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (cards.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Sub('No alerts yet. Trigger an SOS to populate.'),
              )
            else
              for (final card in cards) ...[
                const Divider(height: 1),
                InkWell(
                  onTap: () => state.focusAlert(card),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          margin: const EdgeInsets.only(right: 11),
                          decoration: BoxDecoration(
                            color: card.active ? C.rose : C.guard,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.victim,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${card.id} · ${card.points} pts · ${hhmm(DateTime.fromMillisecondsSinceEpoch(card.startedAt))}',
                                style: kMono.copyWith(
                                  fontSize: 10.5,
                                  color: C.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (card.active)
                          SakhiButton(
                            'Resolve',
                            small: true,
                            style: BtnStyle.guard,
                            onTap: () => state.resolveAlert(card),
                          )
                        else
                          const StatusPill(PillKind.safe, 'Resolved'),
                      ],
                    ),
                  ),
                ),
              ],
          ],
        ),
      );
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _Stat(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: C.panel,
            border: Border.all(color: C.line),
            borderRadius: BorderRadius.circular(C.rSm),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: C.muted,
                ),
              ),
            ],
          ),
        ),
      );
}