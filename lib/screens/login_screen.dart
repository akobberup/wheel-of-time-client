import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_strings.dart';
import '../config/version_config.dart';
import 'home_screen.dart';

/// Skærm til bruger-login og registrering
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoginMode = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LoginHeader(isLoginMode: _isLoginMode),
                  const SizedBox(height: 48),
                  _LoginForm(
                    isLoginMode: _isLoginMode,
                    nameController: _nameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    onSubmit: _handleSubmit,
                  ),
                  if (authState.error != null) ...[
                    const SizedBox(height: 16),
                    _ErrorDisplay(error: authState.error!),
                  ],
                  const SizedBox(height: 16),
                  _SubmitButton(
                    isLoginMode: _isLoginMode,
                    isLoading: authState.isLoading,
                    onPressed: _handleSubmit,
                  ),
                  const SizedBox(height: 16),
                  _ModeToggleButton(
                    isLoginMode: _isLoginMode,
                    isLoading: authState.isLoading,
                    onToggle: _handleModeToggle,
                  ),
                  const SizedBox(height: 24),
                  const _VersionDisplay(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Håndterer formular-indsendelse (login eller registrering)
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authProvider.notifier);

    if (_isLoginMode) {
      await authNotifier.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      await authNotifier.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    _navigateToHomeIfAuthenticated();
  }

  /// Navigerer til home-skærm hvis autentifikation var succesfuld
  void _navigateToHomeIfAuthenticated() {
    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  /// Skifter mellem login og registrerings-tilstand
  void _handleModeToggle() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _formKey.currentState?.reset();
    });
  }
}

/// Header med logo og titel til login-skærmen
class _LoginHeader extends StatelessWidget {
  final bool isLoginMode;

  const _LoginHeader({required this.isLoginMode});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Column(
      children: [
        Icon(
          Icons.auto_stories,
          size: 80,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 16),
        Text(
          strings.appTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          isLoginMode ? strings.welcomeBack : strings.createAccount,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}

/// Formular med inputfelter til login/registrering
class _LoginForm extends StatefulWidget {
  final bool isLoginMode;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;

  const _LoginForm({
    required this.isLoginMode,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
  });

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.isLoginMode) ...[
          _NameField(controller: widget.nameController),
          const SizedBox(height: 16),
        ],
        _EmailField(controller: widget.emailController),
        const SizedBox(height: 16),
        _PasswordField(
          controller: widget.passwordController,
          obscurePassword: _obscurePassword,
          onToggleVisibility: _togglePasswordVisibility,
          onSubmit: widget.onSubmit,
        ),
        const SizedBox(height: 8),
        if (widget.isLoginMode) _ForgotPasswordLink(),
      ],
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }
}

/// Inputfelt til brugernavn (kun ved registrering)
class _NameField extends StatelessWidget {
  final TextEditingController controller;

  const _NameField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: strings.name,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.person),
      ),
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return strings.pleaseEnterName;
        }
        return null;
      },
    );
  }
}

/// Inputfelt til email
class _EmailField extends StatelessWidget {
  final TextEditingController controller;

  const _EmailField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: strings.email,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.email),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return strings.pleaseEnterEmail;
        }
        if (!value.contains('@')) {
          return strings.pleaseEnterValidEmail;
        }
        return null;
      },
    );
  }
}

/// Inputfelt til adgangskode med synligheds-toggle
class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscurePassword;
  final VoidCallback onToggleVisibility;
  final VoidCallback onSubmit;

  const _PasswordField({
    required this.controller,
    required this.obscurePassword,
    required this.onToggleVisibility,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: strings.password,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
      obscureText: obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => onSubmit(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return strings.pleaseEnterPassword;
        }
        if (value.length < 8) {
          return strings.passwordMinLength;
        }
        return null;
      },
    );
  }
}

/// Link til glemt adgangskode
class _ForgotPasswordLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Navigator.of(context).pushNamed('/forgot-password'),
        child: Text(strings.forgotPassword),
      ),
    );
  }
}

/// Visning af fejlmeddelelser
class _ErrorDisplay extends StatelessWidget {
  final String error;

  const _ErrorDisplay({required this.error});

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
        error,
        style: TextStyle(color: Colors.red[900]),
      ),
    );
  }
}

/// Hovedknap til login/registrering
class _SubmitButton extends StatelessWidget {
  final bool isLoginMode;
  final bool isLoading;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.isLoginMode,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

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
              isLoginMode ? strings.signIn : strings.signUp,
              style: const TextStyle(fontSize: 16),
            ),
    );
  }
}

/// Knap til at skifte mellem login og registrerings-tilstand
class _ModeToggleButton extends StatelessWidget {
  final bool isLoginMode;
  final bool isLoading;
  final VoidCallback onToggle;

  const _ModeToggleButton({
    required this.isLoginMode,
    required this.isLoading,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return TextButton(
      onPressed: isLoading ? null : onToggle,
      child: Text(
        isLoginMode ? strings.dontHaveAccount : strings.alreadyHaveAccount,
      ),
    );
  }
}

/// Viser app-version og build tidspunkt i bunden af login-skærmen
class _VersionDisplay extends StatelessWidget {
  const _VersionDisplay();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        VersionConfig.fullVersionInfo,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
      ),
    );
  }
}
