import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/task_instance.dart';
import '../providers/task_history_provider.dart';
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

  const TaskHistoryScreen({
    super.key,
    required this.taskId,
    required this.taskName,
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

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.taskHistoryFor(widget.taskName)),
        actions: [_buildFilterButton(strings)],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(taskHistoryProvider(widget.taskId).notifier).refresh(),
        child: historyAsync.when(
          data: (instances) => _buildHistoryList(instances, strings),
          loading: () => _buildLoadingState(strings),
          error: (error, stack) => _buildErrorState(error, strings),
        ),
      ),
    );
  }

  Widget _buildFilterButton(AppStrings strings) {
    return PopupMenuButton<DateFilter>(
      icon: const Icon(Icons.filter_list),
      tooltip: strings.filter,
      onSelected: _handleFilterSelected,
      itemBuilder: (context) => [
        _buildFilterMenuItem(DateFilter.all, strings.allTime),
        _buildFilterMenuItem(DateFilter.thisWeek, strings.thisWeek),
        _buildFilterMenuItem(DateFilter.thisMonth, strings.thisMonth),
        _buildFilterMenuItem(DateFilter.last3Months, strings.last3Months),
      ],
    );
  }

  PopupMenuItem<DateFilter> _buildFilterMenuItem(DateFilter filter, String label) {
    return PopupMenuItem(
      value: filter,
      child: Row(
        children: [
          if (_selectedFilter == filter) ...[
            const Icon(Icons.check, size: 20),
            const SizedBox(width: 8),
          ],
          Text(label),
        ],
      ),
    );
  }

  void _handleFilterSelected(DateFilter filter) {
    setState(() => _selectedFilter = filter);
  }

  Widget _buildHistoryList(List<TaskInstanceResponse> instances, AppStrings strings) {
    final filteredInstances = _applyFilter(instances);

    if (filteredInstances.isEmpty) {
      return EmptyState(
        title: strings.noCompletionsYet,
        subtitle: strings.noCompletionsYetDescription,
      );
    }

    final sortedInstances = _sortInstancesByDate(filteredInstances);

    return Column(
      children: [
        _buildSummaryHeader(sortedInstances.length, strings),
        _buildCompletionsList(sortedInstances),
      ],
    );
  }

  List<TaskInstanceResponse> _sortInstancesByDate(List<TaskInstanceResponse> instances) {
    return List<TaskInstanceResponse>.from(instances)
      ..sort((a, b) => b.completedDateTime.compareTo(a.completedDateTime));
  }

  Widget _buildSummaryHeader(int count, AppStrings strings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            strings.totalCompletions(count),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionsList(List<TaskInstanceResponse> instances) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: instances.length,
        itemBuilder: (context, index) => _HistoryCard(instance: instances[index]),
      ),
    );
  }

  Widget _buildLoadingState(AppStrings strings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(strings.loadingHistory, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, AppStrings strings) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 60),
        Icon(Icons.error_outline, size: 100, color: Colors.red[300]),
        const SizedBox(height: 24),
        Text(
          strings.errorLoadingHistory,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          strings.errorLoadingHistoryDetails(error.toString()),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            onPressed: () => ref.invalidate(taskHistoryProvider(widget.taskId)),
            icon: const Icon(Icons.refresh),
            label: Text(strings.retry),
          ),
        ),
      ],
    );
  }

  /// Anvender det valgte dato-filter på listen af opgave-instanser
  List<TaskInstanceResponse> _applyFilter(List<TaskInstanceResponse> instances) {
    if (_selectedFilter == DateFilter.all) return instances;

    final cutoffDate = _getCutoffDate(_selectedFilter);
    return instances
        .where((instance) => instance.completedDateTime.isAfter(cutoffDate))
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

/// Kort der viser en enkelt opgave-fuldførelse
///
/// Viser bruger, dato/tid, serie-bidrag og eventuel kommentar/billede.
class _HistoryCard extends StatelessWidget {
  final TaskInstanceResponse instance;

  const _HistoryCard({required this.instance});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return AnimatedCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, strings),
            const SizedBox(height: 12),
            _buildBadges(strings),
            if (_hasComment) _buildCommentSection(context, strings),
            if (_hasImage) _buildImageSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppStrings strings) {
    return Row(
      children: [
        _buildAvatar(context),
        const SizedBox(width: 12),
        Expanded(child: _buildUserInfo(context, strings)),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Text(
        instance.userName.isNotEmpty ? instance.userName[0].toUpperCase() : '?',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, AppStrings strings) {
    final dateFormat = DateFormat.yMMMd();
    final timeFormat = DateFormat.jm();
    final completedDate = dateFormat.format(instance.completedDateTime);
    final completedTime = timeFormat.format(instance.completedDateTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          instance.userName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          '${strings.completedOn(completedDate)} ${strings.completedAt(completedTime)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildBadges(AppStrings strings) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (instance.contributedToStreak)
          StatusBadge(
            icon: Icons.local_fire_department,
            label: strings.contributedToStreak,
            color: Colors.orange,
          ),
        if (_hasComment)
          StatusBadge(
            icon: Icons.comment,
            label: strings.withComment,
            color: Colors.blue,
          ),
      ],
    );
  }

  Widget _buildCommentSection(BuildContext context, AppStrings strings) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    strings.comment,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                instance.optionalComment!,
                style: Theme.of(context).textTheme.bodyMedium,
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
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: ApiConfig.getImageUrl(instance.optionalImagePath!),
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildImagePlaceholder(context),
            errorWidget: (context, url, error) => _buildImageError(context),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildImageError(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.broken_image,
        size: 48,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  bool get _hasComment => instance.optionalComment != null && instance.optionalComment!.isNotEmpty;
  bool get _hasImage => instance.optionalImagePath != null && instance.optionalImagePath!.isNotEmpty;
}
