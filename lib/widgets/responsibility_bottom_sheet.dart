// Design Version: 1.0.0
// Ansvarlig-vælger bottom sheet med Material 3 design

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_responsible.dart';
import '../models/task_list_user.dart';

/// Callback type når ansvarskonfiguration gemmes
typedef OnResponsibilityConfigSaved = void Function(TaskResponsibleConfigRequest config);

/// Bottom sheet til valg af ansvarsstrategi og ansvarlige brugere for en task.
///
/// Understøtter tre strategier:
/// - Alle: Alle medlemmer er ansvarlige (default)
/// - Fast person: Én bestemt person er altid ansvarlig
/// - Skiftevis: Ansvaret roterer mellem udvalgte personer
class ResponsibilityBottomSheet extends ConsumerStatefulWidget {
  /// Liste af task list medlemmer der kan vælges som ansvarlige
  final List<TaskListUserResponse> members;

  /// Nuværende konfiguration (null = ingen config/ALL strategi)
  final TaskResponsibleConfigResponse? currentConfig;

  /// Callback når brugeren gemmer
  final OnResponsibilityConfigSaved onSave;

  /// Tema-farve fra task listen
  final Color? themeColor;

  const ResponsibilityBottomSheet({
    super.key,
    required this.members,
    required this.onSave,
    this.currentConfig,
    this.themeColor,
  });

  @override
  ConsumerState<ResponsibilityBottomSheet> createState() =>
      _ResponsibilityBottomSheetState();
}

class _ResponsibilityBottomSheetState
    extends ConsumerState<ResponsibilityBottomSheet>
    with SingleTickerProviderStateMixin {
  // Valgt strategi
  late ResponsibleStrategy _selectedStrategy;

  // For FIXED_PERSON: Den valgte bruger
  int? _selectedUserId;

  // For ROUND_ROBIN: Liste af valgte brugere i rækkefølge
  late List<int> _selectedUserIds;

  // Animation controller for strategi-skift
  late AnimationController _transitionController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialiser fra eksisterende config eller default
    if (widget.currentConfig != null) {
      _selectedStrategy = widget.currentConfig!.strategy;
      final responsibleIds =
          widget.currentConfig!.responsibles.map((r) => r.userId).toList();

      if (_selectedStrategy == ResponsibleStrategy.fixedPerson &&
          responsibleIds.isNotEmpty) {
        _selectedUserId = responsibleIds.first;
      }
      _selectedUserIds = List.from(responsibleIds);
    } else {
      _selectedStrategy = ResponsibleStrategy.all;
      _selectedUserIds = [];
    }

    // Animation setup
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    );
    _transitionController.value = 1.0;
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  void _onStrategyChanged(ResponsibleStrategy? strategy) {
    if (strategy == null || strategy == _selectedStrategy) return;

    HapticFeedback.selectionClick();

    // Animate transition
    _transitionController.reverse().then((_) {
      setState(() {
        _selectedStrategy = strategy;
        // Reset selections når strategi skiftes
        if (strategy == ResponsibleStrategy.all) {
          _selectedUserId = null;
          _selectedUserIds.clear();
        }
      });
      _transitionController.forward();
    });
  }

  void _onFixedPersonChanged(int? userId) {
    if (userId == null) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedUserId = userId;
    });
  }

  void _toggleRoundRobinUser(int userId) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _selectedUserIds.removeAt(oldIndex);
      _selectedUserIds.insert(newIndex, item);
    });
  }

  bool get _canSave {
    switch (_selectedStrategy) {
      case ResponsibleStrategy.all:
        return true;
      case ResponsibleStrategy.fixedPerson:
        return _selectedUserId != null;
      case ResponsibleStrategy.roundRobin:
        return _selectedUserIds.length >= 2;
    }
  }

  void _save() {
    if (!_canSave) return;

    HapticFeedback.heavyImpact();

    List<int> userIds;
    switch (_selectedStrategy) {
      case ResponsibleStrategy.all:
        userIds = [];
        break;
      case ResponsibleStrategy.fixedPerson:
        userIds = [_selectedUserId!];
        break;
      case ResponsibleStrategy.roundRobin:
        userIds = List.from(_selectedUserIds);
        break;
    }

    final request = TaskResponsibleConfigRequest(
      strategy: _selectedStrategy,
      responsibleUserIds: userIds,
    );

    widget.onSave(request);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveThemeColor = widget.themeColor ?? colorScheme.primary;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          _buildDragHandle(colorScheme),

          // Header
          _buildHeader(theme, colorScheme, effectiveThemeColor),

          const Divider(height: 1),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Strategi vælger
                  _buildStrategySelector(theme, colorScheme, effectiveThemeColor),

                  const SizedBox(height: 20),

                  // Conditional content baseret på strategi
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildStrategyContent(
                        theme, colorScheme, effectiveThemeColor),
                  ),
                ],
              ),
            ),
          ),

          // Action buttons
          _buildActionBar(theme, colorScheme, effectiveThemeColor),
        ],
      ),
    );
  }

  Widget _buildDragHandle(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 32,
      height: 4,
      decoration: BoxDecoration(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(
      ThemeData theme, ColorScheme colorScheme, Color themeColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 16, 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeColor.withValues(alpha: 0.2),
                  themeColor.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.people_alt_rounded,
              color: themeColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ansvarlig',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Vælg hvem der skal udføre opgaven',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategySelector(
      ThemeData theme, ColorScheme colorScheme, Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Strategi',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        ...ResponsibleStrategy.values.map((strategy) =>
            _buildStrategyOption(strategy, theme, colorScheme, themeColor)),
      ],
    );
  }

  Widget _buildStrategyOption(ResponsibleStrategy strategy, ThemeData theme,
      ColorScheme colorScheme, Color themeColor) {
    final isSelected = _selectedStrategy == strategy;

    final (icon, title, subtitle) = switch (strategy) {
      ResponsibleStrategy.all => (
          Icons.groups_rounded,
          'Alle',
          'Alle medlemmer er ansvarlige'
        ),
      ResponsibleStrategy.fixedPerson => (
          Icons.person_rounded,
          'Fast person',
          'Én person er altid ansvarlig'
        ),
      ResponsibleStrategy.roundRobin => (
          Icons.sync_rounded,
          'Skiftevis',
          'Ansvaret roterer mellem valgte'
        ),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onStrategyChanged(strategy),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? themeColor.withValues(alpha: 0.08)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? themeColor.withValues(alpha: 0.4)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? themeColor.withValues(alpha: 0.15)
                        : colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? themeColor : colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? themeColor : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? themeColor
                          : colorScheme.outline.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStrategyContent(
      ThemeData theme, ColorScheme colorScheme, Color themeColor) {
    switch (_selectedStrategy) {
      case ResponsibleStrategy.all:
        return _buildAllStrategyInfo(theme, colorScheme);
      case ResponsibleStrategy.fixedPerson:
        return _buildFixedPersonSelector(theme, colorScheme, themeColor);
      case ResponsibleStrategy.roundRobin:
        return _buildRoundRobinSelector(theme, colorScheme, themeColor);
    }
  }

  Widget _buildAllStrategyInfo(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Alle medlemmer modtager påmindelser og kan fuldføre opgaven.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedPersonSelector(
      ThemeData theme, ColorScheme colorScheme, Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vælg ansvarlig',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        ...widget.members.map((member) => _buildMemberTile(
              member,
              isSelected: _selectedUserId == member.userId,
              onTap: () => _onFixedPersonChanged(member.userId),
              theme: theme,
              colorScheme: colorScheme,
              themeColor: themeColor,
            )),
      ],
    );
  }

  Widget _buildRoundRobinSelector(
      ThemeData theme, ColorScheme colorScheme, Color themeColor) {
    // Filtrér valgte user IDs til kun dem der findes i members listen.
    // Beskytter mod crash hvis et medlem fjernes mens bottom sheet er åben.
    final validMemberIds = widget.members.map((m) => m.userId).toSet();
    final validSelectedIds =
        _selectedUserIds.where((id) => validMemberIds.contains(id)).toList();

    final selectedMembers = validSelectedIds
        .map((id) => widget.members.firstWhere((m) => m.userId == id))
        .toList();
    final unselectedMembers = widget.members
        .where((m) => !_selectedUserIds.contains(m.userId))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Validation message
        if (_selectedUserIds.length < 2)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Vælg mindst 2 personer til rotation',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Selected members (draggable)
        if (selectedMembers.isNotEmpty) ...[
          Row(
            children: [
              Text(
                'Rækkefølge',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.drag_indicator_rounded,
                size: 16,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 4),
              Text(
                'Træk for at ændre',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: selectedMembers.length,
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final scale = 1.0 + (animation.value * 0.03);
                  return Transform.scale(
                    scale: scale,
                    child: Material(
                      elevation: 8 * animation.value,
                      borderRadius: BorderRadius.circular(14),
                      shadowColor: themeColor.withValues(alpha: 0.3),
                      child: child,
                    ),
                  );
                },
                child: child,
              );
            },
            onReorder: _onReorder,
            itemBuilder: (context, index) {
              final member = selectedMembers[index];
              return _buildReorderableMemberTile(
                key: ValueKey(member.userId),
                member: member,
                index: index,
                onRemove: () => _toggleRoundRobinUser(member.userId),
                theme: theme,
                colorScheme: colorScheme,
                themeColor: themeColor,
              );
            },
          ),
          const SizedBox(height: 16),
        ],

        // Unselected members
        if (unselectedMembers.isNotEmpty) ...[
          Text(
            selectedMembers.isEmpty ? 'Vælg deltagere' : 'Tilføj flere',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          ...unselectedMembers.map((member) => _buildMemberTile(
                member,
                isSelected: false,
                onTap: () => _toggleRoundRobinUser(member.userId),
                theme: theme,
                colorScheme: colorScheme,
                themeColor: themeColor,
                showAddIcon: true,
              )),
        ],
      ],
    );
  }

  Widget _buildMemberTile(
    TaskListUserResponse member, {
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required Color themeColor,
    bool showAddIcon = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? themeColor.withValues(alpha: 0.1)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? themeColor.withValues(alpha: 0.4)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                _buildAvatar(member, themeColor, colorScheme, isSelected),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.userName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        member.userEmail,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showAddIcon)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: themeColor,
                      size: 20,
                    ),
                  )
                else if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: themeColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReorderableMemberTile({
    required Key key,
    required TaskListUserResponse member,
    required int index,
    required VoidCallback onRemove,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required Color themeColor,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: themeColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Drag handle
          ReorderableDragStartListener(
            index: index,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.drag_indicator_rounded,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ),

          // Number badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: themeColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Avatar and name
          _buildAvatar(member, themeColor, colorScheme, true),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              member.userName,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Remove button
          IconButton(
            onPressed: onRemove,
            icon: Icon(
              Icons.close_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor:
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildAvatar(TaskListUserResponse member, Color themeColor,
      ColorScheme colorScheme, bool isSelected) {
    final initials = _getInitials(member.userName);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSelected
              ? [themeColor, themeColor.withValues(alpha: 0.7)]
              : [
                  colorScheme.surfaceContainerHigh,
                  colorScheme.surfaceContainerHighest
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// Henter initialer fra et navn (f.eks. "Anders Kobberup" → "AK").
  /// Filtrerer tomme dele væk for at undgå crashes ved malformed navne.
  String _getInitials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts.first[0].toUpperCase();
    }
    return '?';
  }

  Widget _buildActionBar(
      ThemeData theme, ColorScheme colorScheme, Color themeColor) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                'Annuller',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: _canSave
                    ? LinearGradient(
                        colors: [themeColor, themeColor.withValues(alpha: 0.85)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                color: _canSave ? null : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
                boxShadow: _canSave
                    ? [
                        BoxShadow(
                          color: themeColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: ElevatedButton.icon(
                onPressed: _canSave ? _save : null,
                icon: const Icon(Icons.check_rounded, size: 20),
                label: const Text('Gem'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: _canSave
                      ? Colors.white
                      : colorScheme.onSurface.withValues(alpha: 0.4),
                  disabledBackgroundColor: Colors.transparent,
                  disabledForegroundColor:
                      colorScheme.onSurface.withValues(alpha: 0.4),
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hjælper til at vise ResponsibilityBottomSheet
Future<void> showResponsibilityBottomSheet({
  required BuildContext context,
  required List<TaskListUserResponse> members,
  required OnResponsibilityConfigSaved onSave,
  TaskResponsibleConfigResponse? currentConfig,
  Color? themeColor,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ResponsibilityBottomSheet(
      members: members,
      onSave: onSave,
      currentConfig: currentConfig,
      themeColor: themeColor,
    ),
  );
}
