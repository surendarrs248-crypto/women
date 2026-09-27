import 'package:flutter/material.dart';

import '../core/constants.dart';

enum BtnStyle { rose, guard, amber, ghost, plain }

enum PillKind { live, safe, idle, warn }

class H1 extends StatelessWidget {
  final String text;

  const H1(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
      );
}

class H2 extends StatelessWidget {
  final String text;

  const H2(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      );
}

class Sub extends StatelessWidget {
  final String text;

  const Sub(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(color: C.muted, fontSize: 12.5, height: 1.45),
      );
}

class Eyebrow extends StatelessWidget {
  final String text;

  const Eyebrow(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: C.faint,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      );
}

class SakhiCard extends StatelessWidget {
  final Widget child;
  final bool tight;
  final EdgeInsetsGeometry? margin;

  const SakhiCard({
    super.key,
    required this.child,
    this.tight = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: margin ?? const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(tight ? 13 : 16),
        decoration: BoxDecoration(
          color: C.panel,
          border: Border.all(color: C.line),
          borderRadius: BorderRadius.circular(C.r),
        ),
        child: child,
      );
}

class SakhiButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final BtnStyle style;
  final bool small;
  final bool block;

  const SakhiButton(
    this.label, {
    super.key,
    required this.onTap,
    this.style = BtnStyle.rose,
    this.small = false,
    this.block = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = switch (style) {
      BtnStyle.rose => C.rose,
      BtnStyle.guard => C.guard,
      BtnStyle.amber => C.amber,
      BtnStyle.ghost => C.panel2,
      BtnStyle.plain => Colors.transparent,
    };
    final foreground = switch (style) {
      BtnStyle.guard => C.night,
      BtnStyle.amber => C.night,
      BtnStyle.ghost || BtnStyle.plain => C.ink,
      BtnStyle.rose => Colors.white,
    };
    final button = Material(
      color: onTap == null ? C.panel2 : color,
      borderRadius: BorderRadius.circular(C.rSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(C.rSm),
        child: Container(
          constraints: BoxConstraints(minHeight: small ? 34 : 44),
          padding: EdgeInsets.symmetric(
            horizontal: small ? 11 : 15,
            vertical: small ? 7 : 11,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: style == BtnStyle.ghost || style == BtnStyle.plain
                  ? C.line
                  : color,
            ),
            borderRadius: BorderRadius.circular(C.rSm),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: onTap == null ? C.faint : foreground,
              fontSize: small ? 11 : 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
    return block ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class StatusPill extends StatelessWidget {
  final PillKind kind;
  final String label;

  const StatusPill(this.kind, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = switch (kind) {
      PillKind.live => C.rose,
      PillKind.safe => C.guard,
      PillKind.idle => C.faint,
      PillKind.warn => C.amber,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        border: Border.all(color: color.withValues(alpha: .45)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: .4,
        ),
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  final String text;

  const Avatar(this.text, {super.key});

  @override
  Widget build(BuildContext context) => CircleAvatar(
        radius: 21,
        backgroundColor: C.violet.withValues(alpha: .18),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: const TextStyle(color: C.ink, fontWeight: FontWeight.w800),
        ),
      );
}

class IconBtn extends StatelessWidget {
  final String icon;
  final String? tooltip;
  final VoidCallback onTap;

  const IconBtn(this.icon, {super.key, this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        onPressed: onTap,
        icon: Text(icon, style: const TextStyle(fontSize: 18)),
      );
}

class Chip2 extends StatelessWidget {
  final String label;
  final bool on;
  final VoidCallback onTap;

  const Chip2(this.label, {super.key, required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(C.rSm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: on ? C.rose.withValues(alpha: .12) : C.panel,
            border: Border.all(color: on ? C.rose : C.line),
            borderRadius: BorderRadius.circular(C.rSm),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: on ? C.rose : C.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}

class ShieldLogo extends StatelessWidget {
  final double size;

  const ShieldLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: C.rose.withValues(alpha: .13),
          border: Border.all(color: C.rose.withValues(alpha: .55)),
          borderRadius: BorderRadius.circular(size * .28),
        ),
        child: Icon(Icons.shield_outlined, color: C.rose, size: size * .62),
      );
}

class ToastLayer extends StatelessWidget {
  final bool visible;
  final String message;

  const ToastLayer({super.key, required this.visible, required this.message});

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Positioned(
      left: 20,
      right: 20,
      bottom: 92,
      child: IgnorePointer(
        child: Material(
          color: C.toastBg,
          borderRadius: BorderRadius.circular(C.rSm),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Text(message, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}