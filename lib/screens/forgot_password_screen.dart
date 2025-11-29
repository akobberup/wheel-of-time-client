import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_strings.dart';

/// Brand-farve til login-skærme (teal/grøn - symboliserer cyklus og natur)
const Color _kBrandColor = Color(0xFF00897B);

/// Skærm til gendannelse af glemt adgangskode med varm, indbydende æstetik
class ForgotPasswordScreen extends HookConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final emailController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isLoading = useState(false);
    final emailSent = useState(false);
    final error = useState<String?>(null);

    // Animationer
    final orbController = useAnimationController(
      duration: const Duration(seconds: 25),
    )..repeat();

    final formController = useAnimationController(
      duration: const Duration(milliseconds: 600),
    );

    final formSlide = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(parent: formController, curve: Curves.easeOutCubic),
    );

    final formFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: formController, curve: Curves.easeOut),
    );

    useEffect(() {
      formController.forward();
      return null;
    }, const []);

    return Scaffold(
      body: Stack(
        children: [
          // Varm baggrund med orber
          _WarmBackground(
            controller: orbController,
            isDark: isDark,
          ),

          // Hovedindhold
          SafeArea(
            child: Column(
              children: [
                // App bar
                _CustomAppBar(
                  title: strings.forgotPasswordTitle,
                  isDark: isDark,
                ),

                // Indhold
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: AnimatedBuilder(
                        animation: formController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, formSlide.value),
                            child: Opacity(
                              opacity: formFade.value,
                              child: child,
                            ),
                          );
                        },
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: emailSent.value
                                ? _SuccessView(
                                    key: const ValueKey('success'),
                                    email: emailController.text.trim(),
                                    isDark: isDark,
                                  )
                                : _ForgotPasswordForm(
                                    key: const ValueKey('form'),
                                    formKey: formKey,
                                    emailController: emailController,
                                    isLoading: isLoading.value,
                                    error: error.value,
                                    isDark: isDark,
                                    onSubmit: () => _handleSubmit(
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(
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

/// Custom app bar med tilbageknap
class _CustomAppBar extends StatelessWidget {
  final String title;
  final bool isDark;

  const _CustomAppBar({
    required this.title,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_rounded,
              color: textColor.withOpacity(0.8),
            ),
            style: IconButton.styleFrom(
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Varm baggrund med cirkulære orber
class _WarmBackground extends StatelessWidget {
  final AnimationController controller;
  final bool isDark;

  const _WarmBackground({
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _OrbPainter(
            progress: controller.value,
            isDark: isDark,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _OrbPainter({
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Basis gradient
    final baseGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? [
              const Color(0xFF121214),
              Color.lerp(const Color(0xFF121214), _kBrandColor, 0.03)!,
              const Color(0xFF0E0E10),
            ]
          : [
              const Color(0xFFFAFAF8),
              Color.lerp(const Color(0xFFF8F7F5), _kBrandColor, 0.04)!,
              const Color(0xFFF5F4F2),
            ],
    );

    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = baseGradient.createShader(Offset.zero & size),
    );

    // Orber
    final orbs = [
      (0.2, 0.25, 150.0, 0.0),
      (0.8, 0.2, 120.0, 0.4),
      (0.75, 0.7, 180.0, 0.6),
    ];

    for (final (xR, yR, baseR, phase) in orbs) {
      final p = progress * 2 * math.pi + phase * math.pi;
      final x = size.width * xR + math.sin(p * 0.7) * 25;
      final y = size.height * yR + math.cos(p * 0.5) * 20;
      final r = baseR + math.sin(p) * 15;

      final gradient = RadialGradient(
        colors: [
          _kBrandColor.withOpacity(isDark ? 0.07 : 0.045),
          _kBrandColor.withOpacity(0),
        ],
      );

      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..shader = gradient.createShader(
          Rect.fromCircle(center: Offset(x, y), radius: r),
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter old) =>
      progress != old.progress || isDark != old.isDark;
}

/// Formular til nulstilling af adgangskode
class _ForgotPasswordForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isLoading;
  final String? error;
  final bool isDark;
  final VoidCallback onSubmit;

  const _ForgotPasswordForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    required this.error,
    required this.isDark,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark ? Colors.white60 : const Color(0xFF6B6B6B);

    return Column(
      children: [
        // Ikon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _kBrandColor.withOpacity(0.15),
                _kBrandColor.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: _kBrandColor.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            size: 36,
            color: _kBrandColor,
          ),
        ),
        const SizedBox(height: 20),

        // Titel
        Text(
          strings.resetPassword,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          strings.resetPasswordInstructions,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: subtitleColor,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 32),

        // Formular card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.06),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: _kBrandColor.withOpacity(0.06),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Email felt
                _WarmTextField(
                  controller: emailController,
                  label: strings.email,
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  isDark: isDark,
                  onFieldSubmitted: (_) => onSubmit(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return strings.pleaseEnterEmail;
                    }
                    if (!value.contains('@')) {
                      return strings.pleaseEnterValidEmail;
                    }
                    return null;
                  },
                ),

                // Fejl
                if (error != null) ...[
                  const SizedBox(height: 16),
                  _ErrorBanner(error: error!),
                ],

                const SizedBox(height: 20),

                // Submit knap
                _GradientButton(
                  onPressed: isLoading ? null : onSubmit,
                  isLoading: isLoading,
                  child: Text(
                    strings.sendResetLink,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Succes visning efter email er sendt
class _SuccessView extends StatelessWidget {
  final String email;
  final bool isDark;

  const _SuccessView({
    super.key,
    required this.email,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark ? Colors.white60 : const Color(0xFF6B6B6B);
    const successColor = Color(0xFF22C55E);

    return Column(
      children: [
        // Succes ikon
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                successColor.withOpacity(0.2),
                successColor.withOpacity(0.08),
              ],
            ),
            border: Border.all(
              color: successColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 40,
            color: successColor,
          ),
        ),
        const SizedBox(height: 24),

        // Titel
        Text(
          strings.checkYourEmail,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),

        // Beskrivelse
        Text(
          strings.emailResetSent(email),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: subtitleColor,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 36),

        // Tilbage knap
        _OutlineButton(
          onPressed: () => Navigator.of(context).pop(),
          isDark: isDark,
          child: const Text(
            'Tilbage til login',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _kBrandColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// Tekstfelt med varm styling
class _WarmTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final bool isDark;

  const _WarmTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.onFieldSubmitted,
    required this.isDark,
  });

  @override
  State<_WarmTextField> createState() => _WarmTextFieldState();
}

class _WarmTextFieldState extends State<_WarmTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final fillColor = widget.isDark
        ? Colors.white.withOpacity(_isFocused ? 0.08 : 0.04)
        : Colors.black.withOpacity(_isFocused ? 0.04 : 0.02);

    final borderColor = _isFocused
        ? _kBrandColor.withOpacity(0.6)
        : widget.isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.08);

    final iconColor = _isFocused
        ? _kBrandColor
        : widget.isDark
            ? Colors.white54
            : Colors.black45;

    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        onFieldSubmitted: widget.onFieldSubmitted,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: widget.isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(
            color: widget.isDark ? Colors.white54 : Colors.black54,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          prefixIcon: Icon(widget.icon, color: iconColor, size: 22),
          filled: true,
          fillColor: fillColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: borderColor, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: borderColor, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _kBrandColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
        ),
      ),
    );
  }
}

/// Gradient knap
class _GradientButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget child;

  const _GradientButton({
    required this.onPressed,
    required this.isLoading,
    required this.child,
  });

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 54,
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isEnabled
                ? [
                    _kBrandColor,
                    Color.lerp(_kBrandColor, Colors.black, 0.12)!,
                  ]
                : [
                    _kBrandColor.withOpacity(0.5),
                    _kBrandColor.withOpacity(0.4),
                  ],
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: _kBrandColor.withOpacity(_isPressed ? 0.25 : 0.35),
                    blurRadius: _isPressed ? 12 : 20,
                    offset: Offset(0, _isPressed ? 4 : 8),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: widget.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : DefaultTextStyle(
                  style: TextStyle(
                    color: Colors.white.withOpacity(isEnabled ? 1 : 0.8),
                  ),
                  child: widget.child,
                ),
        ),
      ),
    );
  }
}

/// Outline knap
class _OutlineButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isDark;
  final Widget child;

  const _OutlineButton({
    required this.onPressed,
    required this.isDark,
    required this.child,
  });

  @override
  State<_OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<_OutlineButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 50,
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: _isPressed
              ? _kBrandColor.withOpacity(0.08)
              : Colors.transparent,
          border: Border.all(
            color: _kBrandColor.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}

/// Fejl banner
class _ErrorBanner extends StatelessWidget {
  final String error;

  const _ErrorBanner({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.red.withOpacity(0.08),
        border: Border.all(color: Colors.red.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
