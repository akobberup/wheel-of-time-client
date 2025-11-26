import 'package:flutter/material.dart';
import 'dart:math';

/// Animationsforsinkelse mellem hver avatar ved indlæsning
const _animationDelayPerAvatar = Duration(milliseconds: 50);

/// Animationsvarighed for avatar fade-in og scale
const _avatarAnimationDuration = Duration(milliseconds: 300);

/// Data klasse for et medlem i avatar stack
class AvatarData {
  /// Fulde navn på medlemmet
  final String name;

  /// URL til profilbillede (null = vis initialer)
  final String? imageUrl;

  const AvatarData({
    required this.name,
    this.imageUrl,
  });
}

/// Stablet avatar widget der viser medlemmer i en overlappende række
/// Viser op til [maxVisible] avatarer og "+X" for resten
class StackedAvatars extends StatelessWidget {
  /// Liste af medlemmer der skal vises
  final List<AvatarData>? members;

  /// Alternativt: antal medlemmer (bruges når vi kun har tallet)
  final int? memberCount;

  /// Maksimalt antal synlige avatarer
  final int maxVisible;

  /// Størrelse på hver avatar
  final double avatarSize;

  /// Overlap mellem avatarer
  final double overlap;

  /// Callback når der trykkes på avatar stakken
  final VoidCallback? onTap;

  const StackedAvatars({
    super.key,
    this.members,
    this.memberCount,
    this.maxVisible = 3,
    this.avatarSize = 28,
    this.overlap = 10,
    this.onTap,
  }) : assert(members != null || memberCount != null);

  @override
  Widget build(BuildContext context) {
    final count = members?.length ?? memberCount ?? 0;

    if (count == 0) {
      return const SizedBox.shrink();
    }

    final visibleCount = min(count, maxVisible);
    final remainingCount = count - visibleCount;
    // Beregner total bredde: første avatar + overlappende avatarer + eventuel overflow badge
    final totalWidth = avatarSize + (visibleCount - 1) * (avatarSize - overlap) +
        (remainingCount > 0 ? avatarSize - overlap : 0);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: totalWidth,
        height: avatarSize,
        child: Stack(
          children: [
            // Synlige avatarer
            for (int i = 0; i < visibleCount; i++)
              Positioned(
                left: i * (avatarSize - overlap),
                child: _buildAvatar(context, i, _animationDelayPerAvatar * i),
              ),
            // "+X" badge hvis der er flere medlemmer
            if (remainingCount > 0)
              Positioned(
                left: visibleCount * (avatarSize - overlap),
                child: _buildOverflowBadge(context, remainingCount, _animationDelayPerAvatar * visibleCount),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, int index, Duration delay) {
    final colorScheme = Theme.of(context).colorScheme;
    final member = members != null && index < members!.length
        ? members![index]
        : null;

    final colors = _avatarColors;
    final colorIndex = member != null
        ? member.name.hashCode.abs() % colors.length
        : index % colors.length;
    final bgColor = colors[colorIndex];

    return _AnimatedAvatar(
      delay: delay,
      child: Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
          border: Border.all(
            color: colorScheme.surface,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: member?.imageUrl != null
            ? ClipOval(
                child: Image.network(
                  member!.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildInitials(member.name, bgColor),
                ),
              )
            : _buildInitials(
                member?.name ?? '?',
                bgColor,
              ),
      ),
    );
  }

  Widget _buildInitials(String name, Color bgColor) {
    final initials = _getInitials(name);
    final textColor = _getContrastColor(bgColor);

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: textColor,
          fontSize: avatarSize * 0.35,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildOverflowBadge(BuildContext context, int count, Duration delay) {
    final colorScheme = Theme.of(context).colorScheme;

    return _AnimatedAvatar(
      delay: delay,
      child: Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: colorScheme.surface,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '+$count',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: avatarSize * 0.32,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// Henter initialer fra et navn
  String _getInitials(String name) {
    if (name.isEmpty || name == '?') return '?';

    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return name.substring(0, min(2, name.length)).toUpperCase();
  }

  /// Beregner kontrastfarve for tekst
  Color _getContrastColor(Color bgColor) {
    final luminance = bgColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}

/// Animeret avatar med fade-in og scale effekt
class _AnimatedAvatar extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _AnimatedAvatar({
    required this.child,
    required this.delay,
  });

  @override
  State<_AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<_AnimatedAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _avatarAnimationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Foruddefinerede farver til avatarer
const List<Color> _avatarColors = [
  Color(0xFF7C3AED), // Lilla
  Color(0xFF2563EB), // Blå
  Color(0xFF059669), // Grøn
  Color(0xFFF97316), // Orange
  Color(0xFFF43F5E), // Rosa
  Color(0xFF0891B2), // Cyan
  Color(0xFF8B5CF6), // Violet
  Color(0xFFEA580C), // Dyb orange
];
