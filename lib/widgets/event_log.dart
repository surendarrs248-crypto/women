import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/sos_event.dart';

class EventLog extends StatelessWidget {
  final List<SosEvent> events;
  final String emptyText;

  const EventLog(this.events, {super.key, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Text(
        emptyText,
        style: const TextStyle(color: C.muted, fontSize: 12),
      );
    }
    return Column(
      children: [
        for (final event in events.reversed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.t,
                  style: kMono.copyWith(fontSize: 10.5, color: C.faint),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    event.msg,
                    style: const TextStyle(fontSize: 12, color: C.ink),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  event.kind == 'safe'
                      ? Icons.check_circle_outline
                      : Icons.circle,
                  size: 12,
                  color: event.kind == 'safe' ? C.guard : C.rose,
                ),
              ],
            ),
          ),
      ],
    );
  }
}