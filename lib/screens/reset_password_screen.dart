import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_strings.dart';
import 'package:universal_html/html.dart' as html;

/// Skærm til nulstilling af adgangskode via token
class ResetPasswordScreen extends HookConsumerWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final resetSuccessful = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.resetPassword),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: resetSuccessful.value
                ? _SuccessMessage(strings: strings)
                : _ResetPasswordForm(token: token, onSuccess: () => resetSuccessful.value = true),
          ),
        ),
      ),
    );
  }
}

/// Form til indtastning og validering af ny adgangskode
class _ResetPasswordForm extends HookConsumerWidget {
  final String token;
  final VoidCallback onSuccess;

  const _ResetPasswordForm({
    required this.token,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final obscurePassword = useState(true);
    final obscureConfirmPassword = useState(true);
    final isLoading = useState(false);
    final error = useState<String?>(null);

    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, strings),
          const SizedBox(height: 32),
          _PasswordField(
            controller: passwordController,
            labelText: strings.newPassword,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.next,
            validator: (value) => _validatePassword(value, strings),
          ),
          const SizedBox(height: 16),
          _PasswordField(
            controller: confirmPasswordController,
            labelText: strings.confirmPassword,
            obscureText: obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleSubmit(
              formKey,
              passwordController,
              ref,
              isLoading,
              error,
              onSuccess,
            ),
            validator: (value) => _validateConfirmPassword(
              value,
              passwordController.text,
              strings,
            ),
          ),
          const SizedBox(height: 24),
          if (error.value != null) ...[
            _ErrorMessage(message: error.value!),
            const SizedBox(height: 16),
          ],
          _SubmitButton(
            isLoading: isLoading.value,
            strings: strings,
            onPressed: () => _handleSubmit(
              formKey,
              passwordController,
              ref,
              isLoading,
              error,
              onSuccess,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppStrings strings) {
    return Column(
      children: [
        Icon(
          Icons.lock_reset,
          size: 80,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 16),
        Text(
          strings.resetYourPassword,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          strings.enterNewPassword,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  String? _validatePassword(String? value, AppStrings strings) {
    if (value == null || value.isEmpty) {
      return strings.pleaseEnterNewPassword;
    }
    if (value.length < 8) {
      return strings.passwordMinLength;
    }
    return null;
  }

  String? _validateConfirmPassword(
    String? value,
    String password,
    AppStrings strings,
  ) {
    if (value == null || value.isEmpty) {
      return strings.pleaseConfirmPassword;
    }
    if (value != password) {
      return strings.passwordsDoNotMatch;
    }
    return null;
  }

  Future<void> _handleSubmit(
    GlobalKey<FormState> formKey,
    TextEditingController passwordController,
    WidgetRef ref,
    ValueNotifier<bool> isLoading,
    ValueNotifier<String?> error,
    VoidCallback onSuccess,
  ) async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    error.value = null;

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.resetPassword(token, passwordController.text);

      // Fjern token fra URL på web (for at undgå at den vises i browseren)
      // På mobile platforme er URL'en ikke synlig, så dette er kun nødvendigt på web
      if (kIsWeb) {
        html.window.history.replaceState(null, '', '/reset-password');
      }

      onSuccess();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}

/// Adgangskode inputfelt med visibility toggle
class _PasswordField extends HookWidget {
  final TextEditingController controller;
  final String labelText;
  final ValueNotifier<bool> obscureText;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  const _PasswordField({
    required this.controller,
    required this.labelText,
    required this.obscureText,
    required this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText.value ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () => obscureText.value = !obscureText.value,
        ),
      ),
      obscureText: obscureText.value,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}

/// Fejlbesked widget med styling
class _ErrorMessage extends StatelessWidget {
  final String message;

  const _ErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.red[900]),
      ),
    );
  }
}

/// Submit knap med loading indikator
class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final AppStrings strings;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.isLoading,
    required this.strings,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              strings.resetPassword,
              style: const TextStyle(fontSize: 16),
            ),
    );
  }
}

/// Succesbesked der vises efter vellykket nulstilling
class _SuccessMessage extends StatelessWidget {
  final AppStrings strings;

  const _SuccessMessage({required this.strings});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle,
          size: 80,
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        Text(
          strings.passwordResetSuccessful,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          strings.passwordResetSuccessMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => _handleGoToLogin(context),
          child: Text(strings.goToLogin),
        ),
      ],
    );
  }

  void _handleGoToLogin(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
