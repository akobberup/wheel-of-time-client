import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_strings.dart';

/// Skærm til gendannelse af glemt adgangskode
///
/// Giver brugeren mulighed for at anmode om et link til nulstilling af adgangskode
/// via e-mail. Viser bekræftelse når e-mailen er sendt.
class ForgotPasswordScreen extends HookConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final emailController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isLoading = useState(false);
    final emailSent = useState(false);
    final error = useState<String?>(null);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.forgotPasswordTitle),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: emailSent.value
                ? _SuccessMessage(email: emailController.text.trim())
                : _ForgotPasswordForm(
                    formKey: formKey,
                    emailController: emailController,
                    isLoading: isLoading,
                    error: error,
                    onSubmit: () => _handleSubmit(
                      context,
                      ref,
                      formKey,
                      emailController,
                      isLoading,
                      emailSent,
                      error,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// Håndterer indsendelse af formular til nulstilling af adgangskode
  Future<void> _handleSubmit(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    TextEditingController emailController,
    ValueNotifier<bool> isLoading,
    ValueNotifier<bool> emailSent,
    ValueNotifier<String?> error,
  ) async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    error.value = null;

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.forgotPassword(emailController.text.trim());
      emailSent.value = true;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}

/// Formular til indtastning af e-mail for nulstilling af adgangskode
class _ForgotPasswordForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final ValueNotifier<bool> isLoading;
  final ValueNotifier<String?> error;
  final VoidCallback onSubmit;

  const _ForgotPasswordForm({
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    required this.error,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, strings),
          const SizedBox(height: 32),
          _buildEmailField(context, strings),
          const SizedBox(height: 24),
          if (error.value != null) ...[
            _ErrorMessage(message: error.value!),
            const SizedBox(height: 16),
          ],
          _buildSubmitButton(context, strings),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppStrings strings) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Icon(
          Icons.lock_reset,
          size: 80,
          color: theme.primaryColor,
        ),
        const SizedBox(height: 16),
        Text(
          strings.resetPassword,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          strings.resetPasswordInstructions,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context, AppStrings strings) {
    return TextFormField(
      controller: emailController,
      decoration: InputDecoration(
        labelText: strings.email,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.email),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => onSubmit(),
      validator: (value) => _validateEmail(value, strings),
    );
  }

  String? _validateEmail(String? value, AppStrings strings) {
    if (value == null || value.trim().isEmpty) {
      return strings.pleaseEnterEmail;
    }
    if (!value.contains('@')) {
      return strings.pleaseEnterValidEmail;
    }
    return null;
  }

  Widget _buildSubmitButton(BuildContext context, AppStrings strings) {
    return ElevatedButton(
      onPressed: isLoading.value ? null : onSubmit,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: isLoading.value
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              strings.sendResetLink,
              style: const TextStyle(fontSize: 16),
            ),
    );
  }
}

/// Fejlmeddelelse der vises når nulstilling af adgangskode fejler
class _ErrorMessage extends StatelessWidget {
  final String message;

  const _ErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        message,
        style: TextStyle(color: colorScheme.onErrorContainer),
      ),
    );
  }
}

/// Bekræftelsesmeddelelse der vises efter e-mail er sendt
class _SuccessMessage extends StatelessWidget {
  final String email;

  const _SuccessMessage({required this.email});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.email,
          size: 80,
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        Text(
          strings.checkYourEmail,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          strings.emailResetSent(email),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.backToLogin),
        ),
      ],
    );
  }
}
