import 'package:flutter/material.dart';

import '../core/constants.dart';

class SosButton extends StatelessWidget {
  final bool live;
  final VoidCallback onTap;

  const SosButton({super.key, required this.live, required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 22),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 214,
                height: 214,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: live ? C.roseDeep : C.rose,
                  border: Border.all(color: Colors.white.withValues(alpha: .2)),
                  boxShadow: [
                    BoxShadow(
                      color: C.rose.withValues(alpha: live ? .42 : .24),
                      blurRadius: live ? 42 : 28,
                      spreadRadius: live ? 7 : 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(live ? Icons.shield_rounded : Icons.sos_rounded,
                        size: 54, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      live ? 'RESOLVE SOS' : 'SOS',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      live ? 'Tap when safe' : 'Tap to arm',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}