import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../state/app_state.dart';
import 'common.dart';

class ReportSheet extends StatelessWidget {
  const ReportSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.showReportSheet) return const SizedBox.shrink();
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: .72),
        child: SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
              decoration: BoxDecoration(
                color: C.sheetBg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(C.r),
                ),
                border: Border.all(color: C.line),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const H2('Report this area'),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: state.closeReportSheet,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Sub('Choose the severity for this local demo report.'),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      for (final (label, weight) in [
                        ('Caution', .4),
                        ('Unsafe', .7),
                        ('Urgent', 1.0),
                      ]) ...[
                        if (weight > .4) const SizedBox(width: 8),
                        Expanded(
                          child: SakhiButton(
                            label,
                            style: weight == 1 ? BtnStyle.rose : BtnStyle.amber,
                            onTap: () => state.addReport(weight),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}