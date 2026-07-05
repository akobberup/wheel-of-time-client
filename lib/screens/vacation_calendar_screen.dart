// =============================================================================
// Vacation Calendar Screen
// Feriekalender: opret/rediger/slet den aktuelle brugers ferieperioder.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_strings.dart';
import '../models/vacation_period.dart';
import '../providers/vacation_period_provider.dart';
import 'vacation_help_screen.dart';

/// Skærm der viser og administrerer brugerens ferieperioder.
class VacationCalendarScreen extends ConsumerWidget {
  const VacationCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    final periodsAsync = ref.watch(vacationPeriodsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.vacationCalendar),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: strings.vacationHelpTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const VacationHelpScreen(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.add),
        label: Text(strings.addVacationPeriod),
      ),
      body: periodsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: strings.failedToLoadVacationPeriods,
          onRetry: () => ref.read(vacationPeriodsProvider.notifier).refresh(),
          retryLabel: strings.retry,
        ),
        data: (periods) {
          if (periods.isEmpty) {
            return _EmptyView(message: strings.noVacationPeriods);
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: periods.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final period = periods[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.15),
                    child: Icon(Icons.beach_access,
                        color: theme.colorScheme.primary),
                  ),
                  title: Text(period.name),
                  subtitle: Text(
                    '${_formatDate(period.startDate)}  -  ${_formatDate(period.endDate)}',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _openEditor(context, ref, existing: period);
                      } else if (value == 'delete') {
                        _confirmDelete(context, ref, period);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(strings.edit),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(strings.delete),
                      ),
                    ],
                  ),
                  onTap: () => _openEditor(context, ref, existing: period),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    VacationPeriodResponse? existing,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _VacationPeriodEditor(existing: existing),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    VacationPeriodResponse period,
  ) async {
    final strings = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.deleteVacationPeriodTitle),
        content: Text(strings.deleteVacationPeriodConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(strings.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(vacationPeriodsProvider.notifier).deletePeriod(period.id);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.failedToDeleteVacationPeriod)),
        );
      }
    }
  }
}

/// Modal dialog til oprettelse/redigering af en ferieperiode.
class _VacationPeriodEditor extends ConsumerStatefulWidget {
  final VacationPeriodResponse? existing;

  const _VacationPeriodEditor({this.existing});

  @override
  ConsumerState<_VacationPeriodEditor> createState() =>
      _VacationPeriodEditorState();
}

class _VacationPeriodEditorState extends ConsumerState<_VacationPeriodEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _startDate = existing?.startDate ?? DateTime.now();
    _endDate = existing?.endDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Sørg for at slutdato ikke er før startdato
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    final strings = AppStrings.of(context);
    if (!_formKey.currentState!.validate()) return;

    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.vacationEndBeforeStartError)),
      );
      return;
    }

    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final notifier = ref.read(vacationPeriodsProvider.notifier);

    try {
      if (widget.existing == null) {
        await notifier.addPeriod(
          CreateVacationPeriodRequest(
            name: name,
            startDate: _startDate,
            endDate: _endDate,
          ),
        );
      } else {
        await notifier.updatePeriod(
          widget.existing!.id,
          UpdateVacationPeriodRequest(
            name: name,
            startDate: _startDate,
            endDate: _endDate,
          ),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existing == null
                ? strings.failedToCreateVacationPeriod
                : strings.failedToUpdateVacationPeriod),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return AlertDialog(
      title: Text(widget.existing == null
          ? strings.addVacationPeriod
          : strings.editVacationPeriod),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: strings.vacationPeriodName,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return strings.vacationPeriodName;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(strings.vacationStartDate),
              subtitle: Text(_formatDate(_startDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(isStart: true),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(strings.vacationEndDate),
              subtitle: Text(_formatDate(_endDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(isStart: false),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(strings.cancel),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(strings.save),
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String message;

  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.beach_access_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: Text(retryLabel)),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
