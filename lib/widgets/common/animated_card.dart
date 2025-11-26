import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Animeret kort med elevation og skala-animation ved tryk
/// Bruges til at give kort en mere levende og interaktiv følelse
class AnimatedCard extends StatefulWidget {
  /// Kortets indhold
  final Widget child;

  /// Callback når kortet trykkes
  final VoidCallback? onTap;

  /// Callback ved langt tryk
  final VoidCallback? onLongPress;

  /// Margin omkring kortet
  final EdgeInsetsGeometry margin;

  /// Baggrundsfarve for kortet
  final Color? color;

  /// Border omkring kortet
  final BorderSide? borderSide;

  /// Border radius for kortet
  final double borderRadius;

  /// Basis elevation for kortet
  final double baseElevation;

  /// Elevation ved hover/tryk
  final double pressedElevation;

  /// Om kortet skal give haptisk feedback ved tryk
  final bool enableHapticFeedback;

  /// Clip behavior for kortet
  final Clip clipBehavior;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.margin = const EdgeInsets.only(bottom: 12),
    this.color,
    this.borderSide,
    this.borderRadius = 16.0,
    this.baseElevation = 1.0,
    this.pressedElevation = 4.0,
    this.enableHapticFeedback = true,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(
      begin: widget.baseElevation,
      end: widget.pressedElevation,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void _handleTap() {
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isInteractive = widget.onTap != null || widget.onLongPress != null;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            margin: widget.margin,
            elevation: _elevationAnimation.value,
            color: widget.color ?? colorScheme.surface,
            shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
            clipBehavior: widget.clipBehavior,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              side: widget.borderSide ?? BorderSide.none,
            ),
            child: child,
          ),
        );
      },
      child: isInteractive
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                onTap: widget.onTap != null ? _handleTap : null,
                onLongPress: widget.onLongPress,
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                splashColor: colorScheme.primary.withValues(alpha: 0.1),
                highlightColor: colorScheme.primary.withValues(alpha: 0.05),
                child: widget.child,
              ),
            )
          : widget.child,
    );
  }
}
