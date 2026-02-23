import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_strings.dart';
import '../models/task_instance.dart';
import '../models/task_list_user.dart';
import '../providers/auth_provider.dart';

/// Bottom sheet til retroaktiv completion af en expired task instance.
/// Viser brugervælger (task list medlemmer), optional note og fuldfør-knap.
class RetroactiveCompleteSheet extends ConsumerStatefulWidget {
  final TaskInstanceResponse taskInstance;
  final int taskListId;

  const RetroactiveCompleteSheet({
    super.key,
    required this.taskInstance,
    required this.taskListId,
  });

  /// Vis bottom sheet og returner den opdaterede TaskInstanceResponse ved success.
  static Future<TaskInstanceResponse?> show(
    BuildContext context, {
    required TaskInstanceResponse taskInstance,
    required int taskListId,
  }) {
    return showModalBottomSheet<TaskInstanceResponse>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RetroactiveCompleteSheet(
        taskInstance: taskInstance,
        taskListId: taskListId,
      ),
    );
  }

  @override
  ConsumerState<RetroactiveCompleteSheet> createState() =>
      _RetroactiveCompleteSheetState();
}

class _RetroactiveCompleteSheetState
    extends ConsumerState<RetroactiveCompleteSheet> {
  List<TaskListUserResponse>? _members;
  bool _isLoadingMembers = true;
  String? _loadError;
  int? _selectedUserId;
  bool _showNoteField = false;
  final _noteController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final members =
          await apiService.getUsersByTaskList(widget.taskListId);

      if (mounted) {
        setState(() {
          _members = members;
          _isLoadingMembers = false;
          // Auto-select hvis solo bruger (kun ét medlem og ingen andre)
          if (members.length == 1) {
            _selectedUserId = members.first.userId;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = e.toString();
          _isLoadingMembers = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_isSending || _selectedUserId == null) return;
    setState(() => _isSending = true);
    HapticFeedback.mediumImpact();

    final note = _showNoteField && _noteController.text.trim().isNotEmpty
        ? _noteController.text.trim()
        : null;

    try {
      final apiService = ref.read(apiServiceProvider);
      final result = await apiService.completeRetroactive(
        widget.taskInstance.id,
        RetroactiveCompleteRequest(
          completedByUserId: _selectedUserId!,
          optionalComment: note,
        ),
      );

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppStrings.of(context).failedToCompleteRetroactive),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Håndtag
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.replay,
                    color: Color(0xFF22C55E),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.retroactiveCompleteTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.taskInstance.taskName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),

          // Brugervælger
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                strings.whoCompletedTask,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Medlemsliste
          _buildMemberList(theme, colorScheme),

          // Tilføj note
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildNoteSection(strings, theme, colorScheme),
          ),

          const SizedBox(height: 12),

          // Action bar
          _buildActionBar(strings, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildMemberList(ThemeData theme, ColorScheme colorScheme) {
    if (_isLoadingMembers) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Text(
          _loadError!,
          style: TextStyle(color: colorScheme.error),
        ),
      );
    }

    final members = _members ?? [];
    final themeColor = colorScheme.primary;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 250),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          final isSelected = _selectedUserId == member.userId;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _selectedUserId = member.userId),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? themeColor.withValues(alpha: 0.1)
                        : colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
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
                      if (isSelected)
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
        },
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
                  colorScheme.surfaceContainerHighest,
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

  String _getInitials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts.first[0].toUpperCase();
    }
    return '?';
  }

  Widget _buildNoteSection(
      AppStrings strings, ThemeData theme, ColorScheme colorScheme) {
    if (!_showNoteField) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => setState(() => _showNoteField = true),
          icon: const Icon(Icons.chat_bubble_outline, size: 18),
          label: Text(strings.addNote),
        ),
      );
    }

    return TextField(
      controller: _noteController,
      maxLength: 200,
      maxLines: 2,
      decoration: InputDecoration(
        hintText: strings.addNoteHint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      autofocus: true,
    );
  }

  Widget _buildActionBar(
      AppStrings strings, ThemeData theme, ColorScheme colorScheme) {
    final canSubmit = _selectedUserId != null && !_isSending;

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
              onPressed: _isSending ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(strings.cancel),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: canSubmit ? _submit : null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                disabledBackgroundColor:
                    const Color(0xFF22C55E).withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      strings.completeTask,
                      style: const TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}