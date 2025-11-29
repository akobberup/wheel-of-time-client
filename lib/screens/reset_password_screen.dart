// =============================================================================
// Reset Password Screen
// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)
// =============================================================================

import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_strings.dart';
import 'package:universal_html/html.dart' as html;

/// Brand-farve til pre-login skærme (teal/grøn - symboliserer cyklus og natur)
const Color kBrandColor = Color(0xFF00897B);

/// Skærm til nulstilling af adgangskode via token med varm, moderne design.
///
/// Design: v1.0.0 - Organisk æstetik med animerede orber, glass-morfisme,
/// og teal brand-farve. Matcher login-skærmens visuelle udtryk.
class ResetPasswordScreen extends HookConsumerWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resetSuccessful = useState(false);

    return Scaffold(
      body: Stack(
        children: [
          // Varm gradient baggrund med cirkulære orber
          _WarmBackground(isDark: isDark),

          // Hovedindhold
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Tilbage knap
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _BackButton(isDark: isDark),
                      ),
                      const SizedBox(height: 32),

                      // Logo med lås-ikon
                      _SecurityLogo(isDark: isDark),
                      const SizedBox(height: 24),

                      // Indhold (formular eller succes-besked)
                      resetSuccessful.value
                          ? _SuccessContent(isDark: isDark)
                          : _ResetPasswordForm(
                              token: token,
                              isDark: isDark,
                              onSuccess: () => resetSuccessful.value = true,
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Varm baggrund med bløde cirkulære former
class _WarmBackground extends HookWidget {
  final bool isDark;

  const _WarmBackground({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(seconds: 25),
    );

    useEffect(() {
      controller.repeat();
      return null;
    }, []);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _OrbBackgroundPainter(
            progress: controller.value,
            seedColor: kBrandColor,
            isDark: isDark,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Maler baggrunden med gradient og flydende orber
class _OrbBackgroundPainter extends CustomPainter {
  final double progress;
  final Color seedColor;
  final bool isDark;

  _OrbBackgroundPainter({
    required this.progress,
    required this.seedColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Varm basis gradient
    final baseGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? [
              const Color(0xFF121214),
              Color.lerp(const Color(0xFF121214), seedColor, 0.03)!,
              const Color(0xFF0E0E10),
            ]
          : [
              const Color(0xFFFAFAF8),
              Color.lerp(const Color(0xFFF8F7F5), seedColor, 0.04)!,
              const Color(0xFFF5F4F2),
            ],
    );

    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = baseGradient.createShader(Offset.zero & size),
    );

    // Flydende orber med tema-farve
    final orbs = [
      _Orb(0.15, 0.2, 180, 0.0),
      _Orb(0.85, 0.15, 140, 0.3),
      _Orb(0.7, 0.75, 200, 0.5),
      _Orb(0.2, 0.8, 160, 0.7),
    ];

    for (final orb in orbs) {
      final phase = progress * 2 * math.pi + orb.phase * math.pi;
      final wobbleX = math.sin(phase * 0.7) * 30;
      final wobbleY = math.cos(phase * 0.5) * 25;

      final x = size.width * orb.xRatio + wobbleX;
      final y = size.height * orb.yRatio + wobbleY;
      final radius = orb.baseRadius + math.sin(phase) * 20;

      final opacity = isDark ? 0.08 : 0.05;
      final gradient = RadialGradient(
        colors: [
          seedColor.withOpacity(opacity),
          seedColor.withOpacity(0),
        ],
      );

      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..shader = gradient.createShader(
            Rect.fromCircle(center: Offset(x, y), radius: radius),
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbBackgroundPainter old) =>
      progress != old.progress ||
      seedColor != old.seedColor ||
      isDark != old.isDark;
}

class _Orb {
  final double xRatio;
  final double yRatio;
  final double baseRadius;
  final double phase;

  const _Orb(this.xRatio, this.yRatio, this.baseRadius, this.phase);
}

/// Tilbage-knap med moderne styling
class _BackButton extends StatelessWidget {
  final bool isDark;

  const _BackButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(
          Icons.arrow_back_rounded,
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        ),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
        iconSize: 24,
      ),
    );
  }
}

/// Cirkulært logo med lås-ikon
class _SecurityLogo extends StatelessWidget {
  final bool isDark;

  const _SecurityLogo({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kBrandColor.withOpacity(0.15),
            kBrandColor.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: kBrandColor.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.lock_reset_rounded,
        size: 36,
        color: kBrandColor,
      ),
    );
  }
}

/// Form til indtastning og validering af ny adgangskode
class _ResetPasswordForm extends HookConsumerWidget {
  final String token;
  final bool isDark;
  final VoidCallback onSuccess;

  const _ResetPasswordForm({
    required this.token,
    required this.isDark,
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

    return Column(
      children: [
        // Header
        _FormHeader(isDark: isDark),
        const SizedBox(height: 32),

        // Formular card
        _FormCard(
          isDark: isDark,
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ny adgangskode
                _WarmTextField(
                  controller: passwordController,
                  label: strings.newPassword,
                  icon: Icons.lock_outline_rounded,
                  obscureText: obscurePassword.value,
                  isDark: isDark,
                  textInputAction: TextInputAction.next,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: isDark ? Colors.white54 : Colors.black38,
                      size: 22,
                    ),
                    onPressed: () => obscurePassword.value = !obscurePassword.value,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return strings.pleaseEnterNewPassword;
                    }
                    if (value.length < 8) {
                      return strings.passwordMinLength;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Bekræft adgangskode
                _WarmTextField(
                  controller: confirmPasswordController,
                  label: strings.confirmPassword,
                  icon: Icons.lock_outline_rounded,
                  obscureText: obscureConfirmPassword.value,
                  isDark: isDark,
                  textInputAction: TextInputAction.done,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: isDark ? Colors.white54 : Colors.black38,
                      size: 22,
                    ),
                    onPressed: () =>
                        obscureConfirmPassword.value = !obscureConfirmPassword.value,
                  ),
                  onFieldSubmitted: (_) => _handleSubmit(
                    formKey,
                    passwordController,
                    confirmPasswordController,
                    ref,
                    isLoading,
                    error,
                    onSuccess,
                    strings,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return strings.pleaseConfirmPassword;
                    }
                    if (value != passwordController.text) {
                      return strings.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),

                // Fejlmeddelelse
                if (error.value != null) ...[
                  const SizedBox(height: 16),
                  _ErrorMessage(error: error.value!),
                ],

                const SizedBox(height: 24),

                // Submit knap
                _GradientButton(
                  onPressed: isLoading.value
                      ? null
                      : () => _handleSubmit(
                            formKey,
                            passwordController,
                            confirmPasswordController,
                            ref,
                            isLoading,
                            error,
                            onSuccess,
                            strings,
                          ),
                  isLoading: isLoading.value,
                  child: Text(
                    strings.resetPassword,
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

  Future<void> _handleSubmit(
    GlobalKey<FormState> formKey,
    TextEditingController passwordController,
    TextEditingController confirmPasswordController,
    WidgetRef ref,
    ValueNotifier<bool> isLoading,
    ValueNotifier<String?> error,
    VoidCallback onSuccess,
    AppStrings strings,
  ) async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    error.value = null;

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.resetPassword(token, passwordController.text);

      // Fjern token fra URL på web (for at undgå at den vises i browseren)
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

/// Header for formular
class _FormHeader extends StatelessWidget {
  final bool isDark;

  const _FormHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark ? Colors.white60 : const Color(0xFF6B6B6B);

    return Column(
      children: [
        Text(
          strings.resetYourPassword,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          strings.enterNewPassword,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: subtitleColor,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Glass-morfisme formular container
class _FormCard extends StatelessWidget {
  final bool isDark;
  final Widget child;

  const _FormCard({required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Varm input felt med moderne styling
class _WarmTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final bool isDark;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;

  const _WarmTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    required this.isDark,
    this.textInputAction,
    this.suffixIcon,
    this.onFieldSubmitted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.white.withOpacity(0.5);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.08);
    final focusBorderColor = kBrandColor;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final hintColor = isDark ? Colors.white54 : Colors.black45;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(
        fontSize: 15,
        color: textColor,
        fontWeight: FontWeight.w500,
      ),
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: hintColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: kBrandColor.withOpacity(0.7), size: 22),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: bgColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: focusBorderColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

/// Gradient knap med glow-effekt
class _GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget child;

  const _GradientButton({
    required this.onPressed,
    this.isLoading = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: onPressed == null
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF00A895),
                  kBrandColor,
                ],
              ),
        boxShadow: onPressed == null
            ? null
            : [
                BoxShadow(
                  color: kBrandColor.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null
              ? Colors.grey.shade300
              : Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : child,
      ),
    );
  }
}

/// Fejlmeddelelse med varm styling
class _ErrorMessage extends StatelessWidget {
  final String error;

  const _ErrorMessage({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFEF4444).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFEF4444),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: Color(0xFFEF4444),
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

/// Succesbesked med animation og moderne styling
class _SuccessContent extends StatelessWidget {
  final bool isDark;

  const _SuccessContent({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF555555);

    return _FormCard(
      isDark: isDark,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Succes-ikon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF22C55E).withOpacity(0.15),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 48,
              color: Color(0xFF22C55E),
            ),
          ),
          const SizedBox(height: 24),

          // Titel
          Text(
            strings.passwordResetSuccessful,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),

          // Beskrivelse
          Text(
            strings.passwordResetSuccessMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // Knap til login
          _GradientButton(
            onPressed: () => _handleGoToLogin(context),
            child: Text(
              strings.goToLogin,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleGoToLogin(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
