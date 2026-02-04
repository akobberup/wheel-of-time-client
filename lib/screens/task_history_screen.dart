// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/task_instance.dart';
import '../providers/task_history_provider.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_strings.dart';
import '../config/api_config.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/status_badge.dart';
import '../widgets/common/animated_card.dart';

/// Filtrerings-muligheder for opgave historik efter dato
enum DateFilter { all, thisWeek, thisMonth, last3Months }

/// Skærm der viser fuldførelseshistorik for en specifik opgave
///
/// Viser alle opgave-instanser sorteret efter fuldførelsesdato (nyeste først).
/// Inkluderer pull-to-refresh, dato-filtrering og tom tilstand håndtering.
class TaskHistoryScreen extends ConsumerStatefulWidget {
  final int taskId;
  final String taskName;
  final Color? primaryColor;
  final Color? secondaryColor;

  const TaskHistoryScreen({
    super.key,
    required this.taskId,
    required this.taskName,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  ConsumerState<TaskHistoryScreen> createState() => _TaskHistoryScreenState();
}

class _TaskHistoryScreenState extends ConsumerState<TaskHistoryScreen> {
  DateFilter _selectedFilter = DateFilter.all;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final historyAsync = ref.watch(taskHistoryProvider(widget.taskId));
    final themeState = ref.watch(themeProvider);
    // Brug opgavelistens farver hvis tilgængelige, ellers fallback til global primaryColor
    final primaryColor = widget.primaryColor ?? themeState.seedColor;
    final secondaryColor = widget.secondaryColor ?? primaryColor;
    final isDark = themeState.isDarkMode;

    return Scaffold(
      backgroundColor: isDark 
          ? const Color(0xFF121214) 
          : const Color(0xFFFAFAF8),
      body: RefreshIndicator(
        onRefresh: () => ref.read(taskHistoryProvider(widget.taskId).notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context, strings, primaryColor, secondaryColor, isDark),
            historyAsync.when(
              data: (instances) => _buildHistoryContent(instances, strings, primaryColor, secondaryColor, isDark),
              loading: () => _buildLoadingSliver(strings),
              error: (error, stack) => _buildErrorSliver(error, strings, primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  /// Bygger custom SliverAppBar med organisk design
  Widget _buildSliverAppBar(BuildContext context, AppStrings strings, Color primaryColor, Color secondaryColor, bool isDark) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF1A1A1C) : Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16, right: 16),
        title: Text(
          widget.taskName,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: isDark ? const Color(0xFFF5F5F5) : const Color(0xFF1A1A1A),
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withOpacity(0.08),
                secondaryColor.withOpacity(0.03),
              ],
            ),
          ),
        ),
      ),
      actions: [_buildFilterButton(strings, primaryColor, isDark)],
    );
  }

  Widget _buildFilterButton(AppStrings strings, Color primaryColor, bool isDark) {
    return PopupMenuButton<DateFilter>(
      icon: const Icon(Icons.filter_list_rounded),
      tooltip: strings.filter,
      onSelected: _handleFilterSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        _buildFilterMenuItem(DateFilter.all, strings.allTime, primaryColor),
        _buildFilterMenuItem(DateFilter.thisWeek, strings.thisWeek, primaryColor),
        _buildFilterMenuItem(DateFilter.thisMonth, strings.thisMonth, primaryColor),
        _buildFilterMenuItem(DateFilter.last3Months, strings.last3Months, primaryColor),
      ],
    );
  }

  PopupMenuItem<DateFilter> _buildFilterMenuItem(DateFilter filter, String label, Color primaryColor) {
    final isSelected = _selectedFilter == filter;
    return PopupMenuItem(
      value: filter,
      child: Row(
        children: [
          if (isSelected) ...[
            Icon(Icons.check_circle_rounded, size: 20, color: primaryColor),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  void _handleFilterSelected(DateFilter filter) {
    setState(() => _selectedFilter = filter);
  }

  /// Bygger hovedindhold med historik-liste
  Widget _buildHistoryContent(List<TaskInstanceResponse> instances, AppStrings strings, Color primaryColor, Color secondaryColor, bool isDark) {
    final filteredInstances = _applyFilter(instances);

    if (filteredInstances.isEmpty) {
      return SliverFillRemaining(
        child: EmptyState(
          title: strings.noCompletionsYet,
          subtitle: strings.noCompletionsYetDescription,
        ),
      );
    }

    final sortedInstances = _sortInstancesByDate(filteredInstances);

    return SliverList(
      delegate: SliverChildListDelegate([
        _buildSummaryHeader(sortedInstances.length, strings, primaryColor, secondaryColor, isDark),
        const SizedBox(height: 24),
        ...sortedInstances.map((instance) => 
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: _HistoryCard(
              instance: instance,
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
              isDark: isDark,
            ),
          ),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  List<TaskInstanceResponse> _sortInstancesByDate(List<TaskInstanceResponse> instances) {
    return List<TaskInstanceResponse>.from(instances)
      ..sort((a, b) {
        final aTime = a.completedDateTime ?? a.dismissedDateTime ?? DateTime(0);
        final bTime = b.completedDateTime ?? b.dismissedDateTime ?? DateTime(0);
        return bTime.compareTo(aTime);
      });
  }

  /// Bygger summary header med organisk design og subtil gradient
  Widget _buildSummaryHeader(int count, AppStrings strings, Color primaryColor, Color secondaryColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.15),
            secondaryColor.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            strings.totalCompletions(count),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: isDark ? const Color(0xFFF5F5F5) : const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSliver(AppStrings strings) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              strings.loadingHistory,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSliver(Object error, AppStrings strings, Color primaryColor) {
    return SliverFillRemaining(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: const Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              strings.errorLoadingHistory,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFFEF4444),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              strings.errorLoadingHistoryDetails(error.toString()),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B6B6B),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(taskHistoryProvider(widget.taskId)),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(strings.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Anvender det valgte dato-filter på listen af opgave-instanser
  List<TaskInstanceResponse> _applyFilter(List<TaskInstanceResponse> instances) {
    if (_selectedFilter == DateFilter.all) return instances;

    final cutoffDate = _getCutoffDate(_selectedFilter);
    return instances
        .where((instance) {
          final eventTime = instance.completedDateTime ?? instance.dismissedDateTime;
          return eventTime != null && eventTime.isAfter(cutoffDate);
        })
        .toList();
  }

  /// Beregner cutoff-datoen baseret på det valgte filter
  DateTime _getCutoffDate(DateFilter filter) {
    final now = DateTime.now();
    switch (filter) {
      case DateFilter.thisWeek:
        return now.subtract(const Duration(days: 7));
      case DateFilter.thisMonth:
        return DateTime(now.year, now.month - 1, now.day);
      case DateFilter.last3Months:
        return DateTime(now.year, now.month - 3, now.day);
      case DateFilter.all:
        return DateTime(0);
    }
  }
}

/// Kort der viser en enkelt opgave-fuldførelse med Design Version 1.0.0
///
/// Viser bruger, dato/tid, serie-bidrag og eventuel kommentar/billede.
/// Bruger organisk design med bløde hjørner og subtile skygger.
/// Viser status-indikation (PENDING, COMPLETED, EXPIRED) med farver og badges.
class _HistoryCard extends StatelessWidget {
  final TaskInstanceResponse instance;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDark;

  // Status farver (beholdes for tydelig status-indikation)
  static const Color _pendingColor = Color(0xFF3B82F6);   // Blå
  static const Color _completedColor = Color(0xFF22C55E); // Grøn
  static const Color _expiredColor = Color(0xFFEF4444);   // Rød
  static const Color _dismissedColor = Color(0xFFF59E0B); // Orange

  const _HistoryCard({
    required this.instance,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
  });

  /// Returnerer status-farven baseret på instance status
  Color get _statusColor {
    switch (instance.status) {
      case TaskInstanceStatus.pending:
        return _pendingColor;
      case TaskInstanceStatus.completed:
        return _completedColor;
      case TaskInstanceStatus.expired:
        return _expiredColor;
      case TaskInstanceStatus.dismissed:
        return _dismissedColor;
    }
  }

  /// Returnerer status-ikonet
  IconData get _statusIcon {
    switch (instance.status) {
      case TaskInstanceStatus.pending:
        return Icons.schedule_rounded;
      case TaskInstanceStatus.completed:
        return Icons.check_circle_rounded;
      case TaskInstanceStatus.expired:
        return Icons.cancel_rounded;
      case TaskInstanceStatus.dismissed:
        return Icons.event_busy_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222226) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status-farvet venstre kant
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: _statusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              // Indhold
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, strings),
                      const SizedBox(height: 16),
                      _buildBadges(strings),
                      if (_hasComment) _buildCommentSection(context, strings),
                      if (_hasImage) _buildImageSection(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppStrings strings) {
    return Row(
      children: [
        _buildAvatar(),
        const SizedBox(width: 12),
        Expanded(child: _buildUserInfo(strings)),
      ],
    );
  }

  Widget _buildAvatar() {
    // For system entries (expired/pending): brug status-farve, ellers tema-farve
    final bool isSystemEntry = instance.userName == null;
    final avatarColor = (isSystemEntry || instance.status == TaskInstanceStatus.expired)
        ? _statusColor
        : primaryColor;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            avatarColor,
            avatarColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: avatarColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        // Vis status-ikon for system entries, initial for brugere
        child: isSystemEntry
            ? Icon(_statusIcon, color: Colors.white, size: 24)
            : Text(
                instance.userName![0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
      ),
    );
  }

  Widget _buildUserInfo(AppStrings strings) {
    final dateFormat = DateFormat.yMMMd();
    final timeFormat = DateFormat.jm();
    // Brug completedDateTime, dismissedDateTime eller nu som fallback
    final eventTime = instance.completedDateTime ?? instance.dismissedDateTime ?? DateTime.now();
    final eventDate = dateFormat.format(eventTime);
    final eventTimeStr = timeFormat.format(eventTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          // Fallback til 'System' for auto-expired instances uden bruger
          instance.userName ?? strings.system,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: isDark ? const Color(0xFFF5F5F5) : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${strings.completedOn(eventDate)} ${strings.completedAt(eventTimeStr)}',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B),
          ),
        ),
      ],
    );
  }

  /// Returnerer status-teksten baseret på instance status
  String _getStatusLabel(AppStrings strings) {
    switch (instance.status) {
      case TaskInstanceStatus.pending:
        return strings.pending;
      case TaskInstanceStatus.completed:
        return strings.completed;
      case TaskInstanceStatus.expired:
        return strings.expired;
      case TaskInstanceStatus.dismissed:
        return strings.skipped;
    }
  }

  Widget _buildBadges(AppStrings strings) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Status badge vises altid først
        _buildBadge(
          icon: _statusIcon,
          label: _getStatusLabel(strings),
          color: _statusColor,
        ),
        if (instance.contributedToStreak)
          _buildBadge(
            icon: Icons.local_fire_department_rounded,
            label: strings.contributedToStreak,
            color: secondaryColor,
          ),
        if (_hasComment)
          _buildBadge(
            icon: Icons.comment_rounded,
            label: strings.withComment,
            color: primaryColor,
          ),
      ],
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection(BuildContext context, AppStrings strings) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark 
                ? const Color(0xFF1A1A1C) 
                : const Color(0xFFF5F4F2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark 
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 16,
                    color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    strings.comment,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                instance.optionalComment!,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark ? const Color(0xFFF5F5F5) : const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: ApiConfig.getImageUrl(instance.optionalImagePath!),
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildImagePlaceholder(),
            errorWidget: (context, url, error) => _buildImageError(),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1C) : const Color(0xFFF5F4F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1C) : const Color(0xFFF5F4F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.08),
        ),
      ),
      child: Icon(
        Icons.broken_image_rounded,
        size: 48,
        color: isDark ? const Color(0xFFA0A0A0) : const Color(0xFF6B6B6B),
      ),
    );
  }

  bool get _hasComment => instance.optionalComment != null && instance.optionalComment!.isNotEmpty;
  bool get _hasImage => instance.optionalImagePath != null && instance.optionalImagePath!.isNotEmpty;
}
