import 'package:flutter/material.dart';

import '../core/constants.dart';

class TelemetryBar extends StatelessWidget {
  final List<(String, String)> values;

  const TelemetryBar(this.values, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
        decoration: BoxDecoration(
          color: C.panel,
          border: Border.all(color: C.line),
          borderRadius: BorderRadius.circular(C.rSm),
        ),
        child: Row(
          children: [
            for (var i = 0; i < values.length; i++)
              Expanded(
                child: Column(
                  children: [
                    Text(
                      values[i].$1,
                      style: const TextStyle(
                        color: C.faint,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      values[i].$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: kMono.copyWith(color: C.ink, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
}