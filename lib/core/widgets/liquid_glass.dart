import 'dart:ui';

import 'package:flutter/material.dart';

class AppGradientBackground extends StatelessWidget {
  final Widget child;

  const AppGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF07111F), Color(0xFF0E1A30), Color(0xFF08192A)]
              : const [Color(0xFFF7FAFF), Color(0xFFEAF2FF), Color(0xFFF9FCFF)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -120,
            left: -90,
            child: _GlowOrb(
              size: 280,
              color: isDark ? const Color(0x3344A8FF) : const Color(0x665FA8FF),
            ),
          ),
          Positioned(
            top: 90,
            right: -80,
            child: _GlowOrb(
              size: 220,
              color: isDark ? const Color(0x22FFB36B) : const Color(0x55FFD2A5),
            ),
          ),
          Positioned(
            bottom: -100,
            left: 30,
            child: _GlowOrb(
              size: 240,
              color: isDark ? const Color(0x2244E0C7) : const Color(0x5548D7C0),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? Colors.white.withAlpha(16) : Colors.white.withAlpha(180);
    final borderColor =
        isDark ? Colors.white.withAlpha(28) : Colors.white.withAlpha(150);
    final shadowColor = isDark
        ? Colors.black.withAlpha(45)
        : const Color(0xFF9CB6D8).withAlpha(70);

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor,
            isDark ? Colors.white.withAlpha(8) : Colors.white.withAlpha(120),
          ],
        ),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: Colors.transparent,
          child: onTap == null
              ? content
              : InkWell(
                  onTap: onTap,
                  borderRadius: borderRadius,
                  child: content,
                ),
        ),
      ),
    );
  }
}

class GlassButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const GlassButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GlassPanel(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: theme.textTheme.bodySmall?.color,
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withAlpha(0)],
          ),
        ),
      ),
    );
  }
}
