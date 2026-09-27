import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../state/app_state.dart';
import 'common.dart';

class SosSheet extends StatelessWidget {
  const SosSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final session = state.session;
    if (!state.sosActive || session == null) return const SizedBox.shrink();
    return Positioned(
      left: 14,
      right: 14,
      top: MediaQuery.of(context).padding.top + 8,
      child: Material(
        color: C.sheetBg,
        borderRadius: BorderRadius.circular(C.r),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            border: Border.all(color: C.rose.withValues(alpha: .55)),
            borderRadius: BorderRadius.circular(C.r),
          ),
          child: Row(
            children: [
              const Icon(Icons.sos_rounded, color: C.rose),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SOS ACTIVE',
                      style: TextStyle(
                        color: C.rose,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '${session.id} · ${session.path.length} location points',
                      style: kMono.copyWith(fontSize: 10, color: C.muted),
                    ),
                  ],
                ),
              ),
              SakhiButton(
                'Resolve',
                small: true,
                style: BtnStyle.guard,
                onTap: state.resolveSos,
              ),
            ],
          ),
        ),
      ),
    );
  }
}