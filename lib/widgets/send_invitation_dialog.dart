import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/invitation_provider.dart';
import '../models/invitation.dart';
import '../l10n/app_strings.dart';

/// Dialog for sending an invitation to share a task list.
/// Allows the user to enter an email address to invite another user.
class SendInvitationDialog extends ConsumerStatefulWidget {
  final int taskListId;
  final String taskListName;

  const SendInvitationDialog({
    super.key,
    required this.taskListId,
    required this.taskListName,
  });

  @override
  ConsumerState<SendInvitationDialog> createState() => _SendInvitationDialogState();
}

class _SendInvitationDialogState extends ConsumerState<SendInvitationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Validates the email format.
  String? _validateEmail(String? value, AppStrings strings) {
    if (value == null || value.trim().isEmpty) {
      return strings.pleaseEnterEmailAddress;
    }

    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return strings.pleaseEnterValidEmail;
    }

    return null;
  }

  /// Submits the invitation request.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final request = CreateInvitationRequest(
      taskListId: widget.taskListId,
      emailAddress: _emailController.text.trim(),
    );

    final result = await ref.read(invitationProvider.notifier).createInvitation(request);

    if (mounted) {
      setState(() => _isLoading = false);
      final strings = AppStrings.of(context);
      if (result != null) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.invitationSentTo(_emailController.text.trim())),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.failedToSendInvitation),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return AlertDialog(
      title: Text(strings.sendInvitation),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.inviteSomeoneTo(widget.taskListName),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: strings.emailAddress,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email),
                helperText: strings.enterEmailToInvite,
              ),
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              validator: (value) => _validateEmail(value, strings),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: Text(strings.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(strings.sendInvite),
        ),
      ],
    );
  }
}
