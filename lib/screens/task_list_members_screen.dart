// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/task_list_user_provider.dart';
import '../providers/invitation_provider.dart';
import '../providers/theme_provider.dart';
import '../models/task_list_user.dart';
import '../models/enums.dart';
import '../widgets/send_invitation_dialog.dart';
import '../l10n/app_strings.dart';
import '../widgets/common/skeleton_loader.dart';
import '../widgets/common/status_badge.dart';
import '../widgets/common/animated_card.dart';
import 'dart:math';

/// Skærm til administration af medlemmer i en opgaveliste.
/// Viser aktuelle medlemmer, afventende invitationer og tillader tilføjelse/fjernelse af medlemmer.
/// Bruger opgavelistens tema-farver for visuel konsistens.
class TaskListMembersScreen extends ConsumerWidget {
  final int taskListId;
  final String taskListName;

  /// Primær tema-farve fra opgavelisten
  final Color? primaryColor;

  /// Sekundær tema-farve fra opgavelisten
  final Color? secondaryColor;

  const TaskListMembersScreen({
    super.key,
    required this.taskListId,
    required this.taskListName,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final membersAsync = ref.watch(taskListUserNotifierProvider(taskListId));
    final invitationsAsync = ref.watch(taskListInvitationsProvider(taskListId));

    // Brug tema-farver fra opgavelisten, ellers fald tilbage til app tema
    final fallbackColor = ref.watch(themeProvider).seedColor;
    final themeColor = primaryColor ?? fallbackColor;
    final secColor = secondaryColor ?? themeColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Beregn baggrundstint baseret på tema-farven
    final backgroundColor = isDark
        ? const Color(0xFF121214)
        : Color.lerp(const Color(0xFFFAFAF8), themeColor, 0.03)!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: RefreshIndicator(
        onRefresh: () => _handleRefresh(ref),
        color: themeColor,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context, strings, themeColor, secColor, isDark),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _MembersSection(
                    taskListId: taskListId,
                    membersAsync: membersAsync,
                    themeColor: themeColor,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 32),
                  _InvitationsSection(
                    taskListId: taskListId,
                    invitationsAsync: invitationsAsync,
                    themeColor: themeColor,
                    isDark: isDark,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context, ref, strings, themeColor),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AppStrings strings, Color themeColor, Color secColor, bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: themeColor,
      foregroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          strings.membersIn(taskListName),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [themeColor, secColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          // Dekorative cirkulære elementer (wheel motiv)
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                right: 40,
                bottom: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRefresh(WidgetRef ref) async {
    await Future.wait([
      ref.read(taskListUserNotifierProvider(taskListId).notifier).loadUsers(),
      ref.refresh(taskListInvitationsProvider(taskListId).future),
    ]);
  }

  Widget _buildFAB(BuildContext context, WidgetRef ref, AppStrings strings, Color themeColor) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            themeColor,
            themeColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _handleInviteMember(context, ref),
        icon: const Icon(Icons.person_add_outlined, size: 22),
        label: Text(
          strings.invite,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
      ),
    );
  }

  Future<void> _handleInviteMember(BuildContext context, WidgetRef ref) async {
    final result = await showDialog(
      context: context,
      builder: (context) => SendInvitationDialog(
        taskListId: taskListId,
        taskListName: taskListName,
        themeColor: primaryColor,
        secondaryThemeColor: secondaryColor,
      ),
    );

    if (result == true && context.mounted) {
      ref.invalidate(taskListInvitationsProvider(taskListId));
    }
  }
}

/// Sektion der viser alle medlemmer af opgavelisten
class _MembersSection extends ConsumerWidget {
  final int taskListId;
  final AsyncValue membersAsync;
  final Color themeColor;
  final bool isDark;

  const _MembersSection({
    required this.taskListId,
    required this.membersAsync,
    required this.themeColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, strings),
        const SizedBox(height: 8),
        _buildMembersList(context, ref, strings),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, AppStrings strings) {
    return Text(
      strings.members,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildMembersList(BuildContext context, WidgetRef ref, AppStrings strings) {
    return membersAsync.when(
      data: (members) => _buildMembersData(members, strings),
      loading: () => const SkeletonListLoader(itemCount: 3),
      error: (error, stack) => _buildError(context, strings, error),
    );
  }

  Widget _buildMembersData(List<dynamic> members, AppStrings strings) {
    if (members.isEmpty) {
      return _buildEmptyState(strings);
    }

    return Column(
      children: members
          .map((member) => _MemberCard(
                taskListId: taskListId,
                member: member,
                themeColor: themeColor,
                isDark: isDark,
              ))
          .toList(),
    );
  }

  Widget _buildEmptyState(AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222226) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Center(
        child: Text(
          strings.noMembers,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, AppStrings strings, Object error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222226) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Text(
        strings.errorLoadingMembers(error.toString()),
        style: const TextStyle(color: Color(0xFFEF4444)),
      ),
    );
  }
}

/// Kort der viser et enkelt medlem med handlinger
class _MemberCard extends HookConsumerWidget {
  final int taskListId;
  final TaskListUserResponse member;
  final Color themeColor;
  final bool isDark;

  const _MemberCard({
    required this.taskListId,
    required this.member,
    required this.themeColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222226) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: _buildAvatar(context),
        title: _buildTitle(),
        subtitle: _buildSubtitle(context, strings),
        trailing: _buildMenu(context, ref, strings),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    // Generer gradient baseret på brugerens navn
    final baseHue = (member.userName.hashCode.abs() % 360).toDouble();
    final color1 = HSLColor.fromAHSL(1.0, baseHue, 0.7, 0.5).toColor();
    final color2 = HSLColor.fromAHSL(1.0, (baseHue + 30) % 360, 0.7, 0.4).toColor();

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _getInitials(member.userName),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      member.userName,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context, AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 2),
        _buildEmail(context),
        const SizedBox(height: 4),
        _buildPermissionBadge(strings),
      ],
    );
  }

  Widget _buildEmail(BuildContext context) {
    return Text(
      member.userEmail,
      style: TextStyle(
        fontSize: 13,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildPermissionBadge(AppStrings strings) {
    final isEditor = member.userAdminLevel == AdminLevel.CAN_EDIT;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isEditor
            ? (isDark ? themeColor.withOpacity(0.2) : themeColor.withOpacity(0.15))
            : (isDark ? const Color(0xFF333337) : const Color(0xFFF5F4F2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isEditor ? strings.canEdit : strings.canView,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isEditor
              ? (isDark ? themeColor.withOpacity(0.9) : themeColor)
              : (isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B)),
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context, WidgetRef ref, AppStrings strings) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: themeColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: themeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      itemBuilder: (context) => [
        _buildChangePermissionMenuItem(strings),
        _buildRemoveMemberMenuItem(strings),
      ],
      onSelected: (value) => _handleMenuAction(context, ref, value),
    );
  }

  PopupMenuItem<String> _buildChangePermissionMenuItem(AppStrings strings) {
    return PopupMenuItem(
      value: 'change_permission',
      child: Row(
        children: [
          Icon(
            Icons.edit,
            size: 20,
            color: themeColor,
          ),
          const SizedBox(width: 12),
          Text(strings.changePermission),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildRemoveMemberMenuItem(AppStrings strings) {
    return PopupMenuItem(
      value: 'remove',
      child: Row(
        children: [
          const Icon(Icons.person_remove, size: 20, color: Colors.red),
          const SizedBox(width: 12),
          Text(
            strings.removeMember,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    if (action == 'change_permission') {
      await _handleChangePermission(context, ref);
    } else if (action == 'remove') {
      await _handleRemoveMember(context, ref);
    }
  }

  Future<void> _handleChangePermission(BuildContext context, WidgetRef ref) async {
    final strings = AppStrings.of(context);
    final newLevel = await _showChangeAdminLevelDialog(context, strings);

    if (newLevel != null && newLevel != member.userAdminLevel && context.mounted) {
      final success = await ref
          .read(taskListUserNotifierProvider(taskListId).notifier)
          .updateUserAdminLevel(member.userId, newLevel);

      if (context.mounted) {
        _showPermissionUpdateResult(context, success);
      }
    }
  }

  Future<void> _handleRemoveMember(BuildContext context, WidgetRef ref) async {
    final strings = AppStrings.of(context);
    final confirmed = await _showRemoveMemberConfirmation(context, strings);

    if (confirmed) {
      HapticFeedback.heavyImpact();
      final success = await ref
          .read(taskListUserNotifierProvider(taskListId).notifier)
          .removeUser(member.userId);

      if (context.mounted) {
        _showRemoveMemberResult(context, success);
      }
    }
  }

  /// Viser dialog til ændring af administratorniveau for en bruger
  Future<AdminLevel?> _showChangeAdminLevelDialog(
    BuildContext context,
    AppStrings strings,
  ) {
    AdminLevel? selectedLevel = member.userAdminLevel;

    return showDialog<AdminLevel>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(
              color: themeColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: isDark ? const Color(0xFF222226) : Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Themed header icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        themeColor,
                        themeColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: themeColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  strings.changePermissionLevel,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  strings.changePermissionFor(member.userName),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Permission options
                _buildThemedPermissionOption(
                  context,
                  setState,
                  selectedLevel,
                  (value) => selectedLevel = value,
                  strings.canEdit,
                  strings.canEditDescription,
                  AdminLevel.CAN_EDIT,
                ),
                const SizedBox(height: 12),
                _buildThemedPermissionOption(
                  context,
                  setState,
                  selectedLevel,
                  (value) => selectedLevel = value,
                  strings.canView,
                  strings.canViewDescription,
                  AdminLevel.CAN_VIEW,
                ),
                const SizedBox(height: 28),
                
                // Action buttons
                Row(
                  children: [
                    // Cancel button (outlined)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: themeColor.withOpacity(0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          strings.cancel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: themeColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Confirm button (gradient)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              themeColor,
                              themeColor.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: themeColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: selectedLevel != null
                              ? () => Navigator.of(context).pop(selectedLevel)
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            strings.save,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemedPermissionOption(
    BuildContext context,
    StateSetter setState,
    AdminLevel? currentSelection,
    Function(AdminLevel?) onChanged,
    String title,
    String description,
    AdminLevel level,
  ) {
    final isSelected = currentSelection == level;
    
    return InkWell(
      onTap: () {
        setState(() => onChanged(level));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? themeColor.withOpacity(0.15) : themeColor.withOpacity(0.08))
              : (isDark ? const Color(0xFF1A1A1C) : const Color(0xFFF5F4F2)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? themeColor.withOpacity(0.5)
                : (isDark ? const Color(0xFF333337) : const Color(0xFFE5E5E5)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Themed radio button
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? themeColor : (isDark ? const Color(0xFF6B6B6B) : const Color(0xFFCCCCCC)),
                  width: 2,
                ),
                color: isSelected ? themeColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.circle,
                        size: 12,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? themeColor : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showRemoveMemberConfirmation(
    BuildContext context,
    AppStrings strings,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(strings.removeMember),
            content: Text(strings.confirmRemoveMember(member.userName)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(strings.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(strings.remove),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showPermissionUpdateResult(BuildContext context, bool success) {
    final strings = AppStrings.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? strings.permissionUpdatedSuccess
              : strings.failedToUpdatePermission,
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  void _showRemoveMemberResult(BuildContext context, bool success) {
    final strings = AppStrings.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? strings.memberRemovedSuccess
              : strings.failedToRemoveMember,
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  /// Henter initialer fra et fuldt navn.
  /// Returnerer første bogstav i for- og efternavn hvis tilgængeligt, ellers op til 2 tegn.
  String _getInitials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return fullName.substring(0, min(2, fullName.length)).toUpperCase();
  }
}

/// Sektion der viser afventende invitationer
class _InvitationsSection extends ConsumerWidget {
  final int taskListId;
  final AsyncValue invitationsAsync;
  final Color themeColor;
  final bool isDark;

  const _InvitationsSection({
    required this.taskListId,
    required this.invitationsAsync,
    required this.themeColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, strings),
        const SizedBox(height: 8),
        _buildInvitationsList(context, ref, strings),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, AppStrings strings) {
    return Text(
      strings.pendingInvitations,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildInvitationsList(BuildContext context, WidgetRef ref, AppStrings strings) {
    return invitationsAsync.when<Widget>(
      data: (invitations) => _buildInvitationsData(invitations, strings),
      loading: () => const SkeletonListLoader(itemCount: 3),
      error: (error, stack) => _buildError(context, strings, error),
    );
  }

  Widget _buildInvitationsData(List<dynamic> invitations, AppStrings strings) {
    final pending = invitations
        .where((inv) => inv.currentState == InvitationState.SENT)
        .toList();

    if (pending.isEmpty) {
      return _buildEmptyState(strings);
    }

    return Column(
      children: pending
          .map<Widget>((invitation) => _InvitationCard(
                taskListId: taskListId,
                invitation: invitation,
                themeColor: themeColor,
                isDark: isDark,
              ))
          .toList(),
    );
  }

  Widget _buildEmptyState(AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222226) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Center(
        child: Text(
          strings.noPendingInvitations,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, AppStrings strings, Object error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222226) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Text(
        strings.errorLoadingInvitations(error.toString()),
        style: const TextStyle(color: Color(0xFFEF4444)),
      ),
    );
  }
}

/// Kort der viser en enkelt invitation med annullerings-handling
class _InvitationCard extends HookConsumerWidget {
  final int taskListId;
  final dynamic invitation;
  final Color themeColor;
  final bool isDark;

  const _InvitationCard({
    required this.taskListId,
    required this.invitation,
    required this.themeColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final isLoading = useState(false);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222226) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                themeColor.withOpacity(0.2),
                themeColor.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mail_outline,
            color: themeColor,
            size: 24,
          ),
        ),
        title: Text(
          invitation.emailAddress,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: _buildSubtitle(context, strings),
        trailing: _buildCancelButton(context, ref, strings, isLoading),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context, AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 2),
        Text(
          strings.invitedBy(invitation.initiatedByUserName),
          style: TextStyle(
            fontSize: 13,
            color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFFF59E0B).withOpacity(0.2) : const Color(0xFFF59E0B).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            strings.pending,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFFF59E0B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    ValueNotifier<bool> isLoading,
  ) {
    return Semantics(
      label: '${strings.cancelInvitation} ${invitation.emailAddress}',
      button: true,
      child: IconButton(
        icon: const Icon(Icons.cancel),
        tooltip: strings.cancelInvitation,
        color: Colors.red,
        onPressed: isLoading.value
            ? null
            : () => _handleCancelInvitation(context, ref, strings, isLoading),
      ),
    );
  }

  Future<void> _handleCancelInvitation(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    ValueNotifier<bool> isLoading,
  ) async {
    final confirmed = await _showCancelInvitationConfirmation(context, strings);
    if (!confirmed) return;

    isLoading.value = true;
    HapticFeedback.heavyImpact();

    try {
      final success = await ref
          .read(invitationProvider.notifier)
          .cancelInvitation(invitation.id);

      if (context.mounted) {
        _showCancelResult(context, ref, strings, success);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _showCancelInvitationConfirmation(
    BuildContext context,
    AppStrings strings,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(strings.cancelInvitation),
            content: Text(strings.confirmCancelInvitation(invitation.emailAddress)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(strings.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(strings.cancelInvite),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showCancelResult(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    bool success,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? strings.invitationCancelledSuccess
              : strings.failedToCancelInvitation,
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      ref.invalidate(taskListInvitationsProvider(taskListId));
    }
  }
}
