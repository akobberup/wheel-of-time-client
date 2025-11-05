import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/task_instance.dart';
import '../providers/task_history_provider.dart';
import '../l10n/app_strings.dart';
import '../config/api_config.dart';

/// Screen displaying the completion history for a specific task.
/// Shows all task instances sorted by completion date (most recent first).
/// Includes pull-to-refresh and empty state handling.
class TaskHistoryScreen extends ConsumerWidget {
  final int taskId;
  final String taskName;

  const TaskHistoryScreen({
    super.key,
    required this.taskId,
    required this.taskName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final historyAsync = ref.watch(taskHistoryProvider(taskId));

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.taskHistoryFor(taskName)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(taskHistoryProvider(taskId).notifier).refresh();
        },
        child: historyAsync.when(
          data: (instances) {
            if (instances.isEmpty) {
              return _buildEmptyState(context, strings);
            }

            // Sort instances by completion date (most recent first)
            final sortedInstances = List<TaskInstanceResponse>.from(instances)
              ..sort((a, b) => b.completedDateTime.compareTo(a.completedDateTime));

            return Column(
              children: [
                // Summary header with total completions
                Container(
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
                        strings.totalCompletions(instances.length),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                // List of completions
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sortedInstances.length,
                    itemBuilder: (context, index) {
                      final instance = sortedInstances[index];
                      return _buildHistoryCard(context, strings, instance);
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  strings.loadingHistory,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          error: (error, stack) => _buildErrorState(context, ref, strings, error),
        ),
      ),
    );
  }

  /// Builds a card displaying a single task completion instance.
  /// Shows user, date/time, streak contribution, and optional comment.
  Widget _buildHistoryCard(
    BuildContext context,
    AppStrings strings,
    TaskInstanceResponse instance,
  ) {
    final dateFormat = DateFormat.yMMMd();
    final timeFormat = DateFormat.jm();
    final completedDate = dateFormat.format(instance.completedDateTime);
    final completedTime = timeFormat.format(instance.completedDateTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: User and date
            Row(
              children: [
                // User avatar
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    instance.userName.isNotEmpty
                        ? instance.userName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Badges for streak contribution
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (instance.contributedToStreak)
                  _buildBadge(
                    context,
                    icon: Icons.local_fire_department,
                    label: strings.contributedToStreak,
                    color: Colors.orange,
                  ),
                if (instance.optionalComment != null && instance.optionalComment!.isNotEmpty)
                  _buildBadge(
                    context,
                    icon: Icons.comment,
                    label: strings.withComment,
                    color: Colors.blue,
                  ),
              ],
            ),
            // Optional comment section
            if (instance.optionalComment != null && instance.optionalComment!.isNotEmpty) ...[
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
            // Optional image
            if (instance.optionalImagePath != null && instance.optionalImagePath!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: ApiConfig.getImageUrl(instance.optionalImagePath!),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: double.infinity,
                    height: 200,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: double.infinity,
                    height: 200,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds a small badge chip with an icon and label.
  /// Used to display metadata like streak contribution or comments.
  Widget _buildBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  /// Builds the empty state when no completions exist yet.
  /// Encourages the user to complete the task for the first time.
  Widget _buildEmptyState(BuildContext context, AppStrings strings) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 60),
        Icon(
          Icons.history,
          size: 100,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 24),
        Text(
          strings.noCompletionsYet,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          strings.noCompletionsYetDescription,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  /// Builds the error state when history fails to load.
  /// Displays error message and provides option to retry.
  Widget _buildErrorState(BuildContext context, WidgetRef ref, AppStrings strings, Object error) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 60),
        Icon(
          Icons.error_outline,
          size: 100,
          color: Colors.red[300],
        ),
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
            onPressed: () {
              ref.invalidate(taskHistoryProvider(taskId));
            },
            icon: const Icon(Icons.refresh),
            label: Text(strings.retry),
          ),
        ),
      ],
    );
  }
}
