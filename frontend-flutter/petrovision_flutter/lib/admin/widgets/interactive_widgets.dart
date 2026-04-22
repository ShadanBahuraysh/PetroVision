import 'package:flutter/material.dart';

class HoverSurface extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final Color hoverColor;
  final Color borderColor;
  final VoidCallback? onTap;

  const HoverSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.backgroundColor = Colors.white,
    this.hoverColor = const Color(0xFFF6F7F9), // softer grey
    this.borderColor = const Color(0xFFE5E7EB),
    this.onTap,
  });

  @override
  State<HoverSurface> createState() => _HoverSurfaceState();
}

class _HoverSurfaceState extends State<HoverSurface> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _hovered ? widget.hoverColor : widget.backgroundColor,
            borderRadius: widget.borderRadius,
            border: Border.all(
              color: _hovered
                  ? const Color(0xFFB8C0CC) // soft grey hover
                  : widget.borderColor,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF132935).withOpacity(0.04), // subtle navy shadow
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// ✅ PRIMARY BUTTON (navy)
ButtonStyle darkDesktopButtonStyle() {
  return ButtonStyle(
    mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click),
    animationDuration: const Duration(milliseconds: 140),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 22, vertical: 18),
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    foregroundColor: const WidgetStatePropertyAll(Colors.white),
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return const Color(0xFF0F1F28); // darker navy
      }
      if (states.contains(WidgetState.hovered)) {
        return const Color(0xFF1C3A47); // lighter navy
      }
      return const Color(0xFF132935); // main navy
    }),
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.hovered)) {
        return Colors.white.withOpacity(0.05);
      }
      if (states.contains(WidgetState.pressed)) {
        return Colors.white.withOpacity(0.10);
      }
      return null;
    }),
  );
}

/// ✅ OUTLINED BUTTON (clean grey + navy text)
ButtonStyle outlinedDesktopButtonStyle() {
  return ButtonStyle(
    mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click),
    animationDuration: const Duration(milliseconds: 140),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),

    /// TEXT COLOR
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.hovered)) {
        return const Color(0xFF132935); // navy
      }
      return const Color(0xFF8A959E); // grey
    }),

    /// BORDER
    side: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.hovered)) {
        return const BorderSide(color: Color(0xFF4195AF)); // blue accent
      }
      return const BorderSide(color: Color(0xFFE5E7EB)); // light grey
    }),

    /// BACKGROUND
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.hovered)) {
        return const Color(0xFFF6F7F9);
      }
      return Colors.white;
    }),
  );
}