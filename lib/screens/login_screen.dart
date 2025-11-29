// =============================================================================
// Login Screen
// Design Version: 1.0.0 (se docs/DESIGN_GUIDELINES.md)
// =============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_strings.dart';
import '../config/version_config.dart';
import 'home_screen.dart';

/// Brand-farve til login-skærme (teal/grøn - symboliserer cyklus og natur)
const Color kBrandColor = Color(0xFF00897B);

/// Login-skærm med varm, indbydende æstetik og subtile cyklus-motiver.
///
/// Design: v1.0.0 - Organisk æstetik med animerede orber, bløde former,
/// og teal brand-farve. Inkluderer klikbare feature highlights og
/// interaktiv registrerings-intro.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoginMode = true;
  bool _obscurePassword = true;

  AnimationController? _orbController;
  AnimationController? _formController;
  Animation<double>? _formSlideAnimation;
  Animation<double>? _formFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Langsom baggrunds-animation for cirkulære elementer
    _orbController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    // Formular indtræden
    _formController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _formSlideAnimation = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(parent: _formController!, curve: Curves.easeOutCubic),
    );

    _formFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _formController!, curve: Curves.easeOut),
    );

    _formController!.forward();
  }

  @override
  void dispose() {
    _orbController?.dispose();
    _formController?.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const seedColor = kBrandColor;

    return Scaffold(
      body: Stack(
        children: [
          // Varm gradient baggrund med cirkulære orber
          if (_orbController != null)
            _WarmBackground(
              controller: _orbController!,
              seedColor: seedColor,
              isDark: isDark,
            ),

          // Hovedindhold
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: AnimatedBuilder(
                  animation: _formController ?? const AlwaysStoppedAnimation(1.0),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _formSlideAnimation?.value ?? 0),
                      child: Opacity(
                        opacity: _formFadeAnimation?.value ?? 1,
                        child: child,
                      ),
                    );
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo med cyklus-ikon
                        _CycleLogo(seedColor: seedColor, isDark: isDark),
                        const SizedBox(height: 16),

                        // Velkomst header
                        _WelcomeHeader(
                          isLoginMode: _isLoginMode,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 24),

                        // Feature highlights (login) eller intro (registrering)
                        if (_isLoginMode) ...[
                          _FeatureHighlights(isDark: isDark),
                          const SizedBox(height: 32),
                        ] else ...[
                          const SizedBox(height: 16),
                          _RegistrationIntro(isDark: isDark),
                          const SizedBox(height: 28),
                        ],

                        // Formular card
                        _FormCard(
                          isDark: isDark,
                          seedColor: seedColor,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Navn felt ved registrering
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  child: _isLoginMode
                                      ? const SizedBox.shrink()
                                      : Padding(
                                          padding: const EdgeInsets.only(bottom: 16),
                                          child: _WarmTextField(
                                            controller: _nameController,
                                            label: AppStrings.of(context).name,
                                            icon: Icons.person_outline_rounded,
                                            seedColor: seedColor,
                                            isDark: isDark,
                                            validator: (value) {
                                              if (!_isLoginMode &&
                                                  (value == null || value.trim().isEmpty)) {
                                                return AppStrings.of(context).pleaseEnterName;
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                ),

                                // Email felt
                                _WarmTextField(
                                  controller: _emailController,
                                  label: AppStrings.of(context).email,
                                  icon: Icons.mail_outline_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  seedColor: seedColor,
                                  isDark: isDark,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return AppStrings.of(context).pleaseEnterEmail;
                                    }
                                    if (!value.contains('@')) {
                                      return AppStrings.of(context).pleaseEnterValidEmail;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Adgangskode felt
                                _WarmTextField(
                                  controller: _passwordController,
                                  label: AppStrings.of(context).password,
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: _obscurePassword,
                                  seedColor: seedColor,
                                  isDark: isDark,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black38,
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      setState(() => _obscurePassword = !_obscurePassword);
                                    },
                                  ),
                                  onFieldSubmitted: (_) => _handleSubmit(),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppStrings.of(context).pleaseEnterPassword;
                                    }
                                    if (value.length < 8) {
                                      return AppStrings.of(context).passwordMinLength;
                                    }
                                    return null;
                                  },
                                ),

                                // Glemt adgangskode
                                if (_isLoginMode) ...[
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => Navigator.of(context)
                                          .pushNamed('/forgot-password'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: seedColor,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      child: Text(AppStrings.of(context).forgotPassword),
                                    ),
                                  ),
                                ],

                                // Fejlmeddelelse
                                if (authState.error != null) ...[
                                  const SizedBox(height: 16),
                                  _ErrorMessage(error: authState.error!),
                                ],

                                const SizedBox(height: 20),

                                // Submit knap
                                _GradientButton(
                                  onPressed: authState.isLoading ? null : _handleSubmit,
                                  isLoading: authState.isLoading,
                                  seedColor: seedColor,
                                  child: Text(
                                    _isLoginMode
                                        ? AppStrings.of(context).signIn
                                        : AppStrings.of(context).signUp,
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

                        const SizedBox(height: 20),

                        // Toggle login/register
                        _ModeToggle(
                          isLoginMode: _isLoginMode,
                          isLoading: authState.isLoading,
                          seedColor: seedColor,
                          isDark: isDark,
                          onToggle: _handleModeToggle,
                        ),

                        const SizedBox(height: 28),

                        // Version
                        _VersionInfo(isDark: isDark),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  void _navigateToHomeIfAuthenticated() {
    if (!mounted) return;
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _handleModeToggle() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _formKey.currentState?.reset();
    });
  }
}

/// Varm baggrund med bløde cirkulære former
class _WarmBackground extends StatelessWidget {
  final AnimationController controller;
  final Color seedColor;
  final bool isDark;

  const _WarmBackground({
    required this.controller,
    required this.seedColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _OrbBackgroundPainter(
            progress: controller.value,
            seedColor: seedColor,
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
        Paint()..shader = gradient.createShader(
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

/// Cirkulært logo der symboliserer gentagelse/cyklus
class _CycleLogo extends StatelessWidget {
  final Color seedColor;
  final bool isDark;

  const _CycleLogo({required this.seedColor, required this.isDark});

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
            seedColor.withOpacity(0.15),
            seedColor.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: seedColor.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.event_repeat_rounded,
        size: 36,
        color: seedColor,
      ),
    );
  }
}

/// Velkomst header med titel og undertekst
class _WelcomeHeader extends StatelessWidget {
  final bool isLoginMode;
  final bool isDark;

  const _WelcomeHeader({required this.isLoginMode, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark ? Colors.white60 : const Color(0xFF6B6B6B);

    return Column(
      children: [
        Text(
          strings.appTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        // Tagline eller login/register tekst
        Text(
          isLoginMode
              ? 'Hold styr på tilbagevendende opgaver – sammen'
              : strings.createAccount,
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

/// Feature highlights der viser appens kernefunktioner
class _FeatureHighlights extends StatelessWidget {
  final bool isDark;

  const _FeatureHighlights({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white70 : const Color(0xFF555555);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _FeatureChip(
          icon: Icons.event_repeat_rounded,
          label: 'Gentagende',
          isDark: isDark,
          textColor: textColor,
          onTap: () => _showFeatureInfo(
            context,
            isDark,
            Icons.event_repeat_rounded,
            'Gentagende opgaver',
            'Opret opgaver der gentager sig automatisk – dagligt, ugentligt eller efter dit eget mønster. Aldrig glem at vande planterne eller tage medicin igen.',
          ),
        ),
        _FeatureDot(isDark: isDark),
        _FeatureChip(
          icon: Icons.group_outlined,
          label: 'Delt',
          isDark: isDark,
          textColor: textColor,
          onTap: () => _showFeatureInfo(
            context,
            isDark,
            Icons.group_outlined,
            'Del med andre',
            'Inviter familie, venner eller roommates til dine lister. Se hvem der har udført hvilke opgaver, og koordiner nemt hverdagens gøremål.',
          ),
        ),
        _FeatureDot(isDark: isDark),
        _FeatureChip(
          icon: Icons.local_fire_department_rounded,
          label: 'Streaks',
          isDark: isDark,
          textColor: textColor,
          onTap: () => _showFeatureInfo(
            context,
            isDark,
            Icons.local_fire_department_rounded,
            'Hold din streak',
            'Bliv motiveret af at se hvor mange gange i træk du har udført en opgave. Byg gode vaner og fejr dine fremskridt!',
          ),
        ),
      ],
    );
  }

  void _showFeatureInfo(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title,
    String description,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _FeatureInfoSheet(
        icon: icon,
        title: title,
        description: description,
        isDark: isDark,
      ),
    );
  }
}

/// Bottom sheet med feature information
class _FeatureInfoSheet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isDark;

  const _FeatureInfoSheet({
    required this.icon,
    required this.title,
    required this.description,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF1E1E22) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF555555);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Ikon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kBrandColor.withOpacity(0.12),
            ),
            child: Icon(
              icon,
              size: 28,
              color: kBrandColor,
            ),
          ),
          const SizedBox(height: 16),
          // Titel
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          // Beskrivelse
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Enkelt feature chip med ikon og label
class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color textColor;
  final VoidCallback onTap;

  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: kBrandColor.withOpacity(0.8),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Separator prik mellem feature chips
class _FeatureDot extends StatelessWidget {
  final bool isDark;

  const _FeatureDot({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? Colors.white24 : Colors.black12,
      ),
    );
  }
}

/// Introduktion til nye brugere på registrerings-skærmen
class _RegistrationIntro extends StatefulWidget {
  final bool isDark;

  const _RegistrationIntro({required this.isDark});

  @override
  State<_RegistrationIntro> createState() => _RegistrationIntroState();
}

class _RegistrationIntroState extends State<_RegistrationIntro> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.isDark
        ? Colors.white.withOpacity(0.04)
        : kBrandColor.withOpacity(0.04);
    final borderColor = widget.isDark
        ? Colors.white.withOpacity(0.08)
        : kBrandColor.withOpacity(0.12);
    final textColor = widget.isDark ? Colors.white70 : const Color(0xFF444444);
    final titleColor = widget.isDark ? Colors.white : const Color(0xFF1A1A1A);

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hvad er Wheel of Time?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: _ShortDescription(textColor: textColor),
              secondChild: _LongDescription(
                textColor: textColor,
                isDark: widget.isDark,
              ),
            ),
            const SizedBox(height: 12),
            // Hint tekst
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isExpanded ? 0 : 0.6,
              child: Text(
                'Tryk for at læse mere',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kort beskrivelse (default)
class _ShortDescription extends StatelessWidget {
  final Color textColor;

  const _ShortDescription({required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'En app til at holde styr på tilbagevendende opgaver. '
          'Perfekt til daglige rutiner, huslige pligter, eller alt andet der skal gøres regelmæssigt.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: textColor,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MiniFeature(
              icon: Icons.event_repeat_rounded,
              label: 'Automatisk',
              textColor: textColor,
            ),
            const SizedBox(width: 16),
            _MiniFeature(
              icon: Icons.group_outlined,
              label: 'Sammen',
              textColor: textColor,
            ),
            const SizedBox(width: 16),
            _MiniFeature(
              icon: Icons.emoji_events_outlined,
              label: 'Motiverende',
              textColor: textColor,
            ),
          ],
        ),
      ],
    );
  }
}

/// Lang beskrivelse (efter klik)
class _LongDescription extends StatelessWidget {
  final Color textColor;
  final bool isDark;

  const _LongDescription({
    required this.textColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FeatureDetail(
          icon: Icons.event_repeat_rounded,
          title: 'Automatisk gentagelse',
          description:
              'Opret opgaver der gentager sig dagligt, ugentligt, eller efter dit eget mønster. '
              'Appen holder styr på hvornår opgaven skal udføres næste gang.',
          textColor: textColor,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _FeatureDetail(
          icon: Icons.group_outlined,
          title: 'Del med andre',
          description:
              'Inviter familie, venner eller roommates til dine opgavelister. '
              'Se hvem der har gjort hvad, og fordel ansvar nemt.',
          textColor: textColor,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _FeatureDetail(
          icon: Icons.local_fire_department_rounded,
          title: 'Streak-tracking',
          description:
              'Hold øje med hvor mange gange i træk du udfører en opgave. '
              'Byg gode vaner og bliv motiveret af dine fremskridt!',
          textColor: textColor,
          isDark: isDark,
        ),
      ],
    );
  }
}

/// Detalje for en enkelt feature i den lange beskrivelse
class _FeatureDetail extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color textColor;
  final bool isDark;

  const _FeatureDetail({
    required this.icon,
    required this.title,
    required this.description,
    required this.textColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kBrandColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: kBrandColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Mini feature til registrerings-intro
class _MiniFeature extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color textColor;

  const _MiniFeature({
    required this.icon,
    required this.label,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: kBrandColor,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

/// Formular card med blød styling
class _FormCard extends StatelessWidget {
  final bool isDark;
  final Color seedColor;
  final Widget child;

  const _FormCard({
    required this.isDark,
    required this.seedColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: seedColor.withOpacity(0.06),
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
      child: child,
    );
  }
}

/// Tekstfelt med varm, afrundet styling
class _WarmTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final Color seedColor;
  final bool isDark;

  const _WarmTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
    this.onFieldSubmitted,
    required this.seedColor,
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
        ? widget.seedColor.withOpacity(0.6)
        : widget.isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.08);

    final iconColor = _isFocused
        ? widget.seedColor
        : widget.isDark
            ? Colors.white54
            : Colors.black45;

    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.obscureText,
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
          suffixIcon: widget.suffixIcon,
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
            borderSide: BorderSide(color: widget.seedColor, width: 2),
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

/// Gradient knap med tema-farve
class _GradientButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color seedColor;
  final Widget child;

  const _GradientButton({
    required this.onPressed,
    required this.isLoading,
    required this.seedColor,
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
                    widget.seedColor,
                    Color.lerp(widget.seedColor, Colors.black, 0.12)!,
                  ]
                : [
                    widget.seedColor.withOpacity(0.5),
                    widget.seedColor.withOpacity(0.4),
                  ],
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: widget.seedColor.withOpacity(_isPressed ? 0.25 : 0.35),
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

/// Fejlmeddelelse med varm styling
class _ErrorMessage extends StatelessWidget {
  final String error;

  const _ErrorMessage({required this.error});

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

/// Toggle mellem login og registrering
class _ModeToggle extends StatelessWidget {
  final bool isLoginMode;
  final bool isLoading;
  final Color seedColor;
  final bool isDark;
  final VoidCallback onToggle;

  const _ModeToggle({
    required this.isLoginMode,
    required this.isLoading,
    required this.seedColor,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final textColor = isDark ? Colors.white60 : const Color(0xFF6B6B6B);

    return TextButton(
      onPressed: isLoading ? null : onToggle,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text.rich(
        TextSpan(
          style: TextStyle(fontSize: 14, color: textColor),
          children: [
            TextSpan(
              text: isLoginMode ? 'Ingen konto? ' : 'Har du en konto? ',
            ),
            TextSpan(
              text: isLoginMode ? strings.signUp : strings.signIn,
              style: TextStyle(
                color: seedColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Viser version info
class _VersionInfo extends StatelessWidget {
  final bool isDark;

  const _VersionInfo({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      VersionConfig.fullVersionInfo,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: isDark ? Colors.white30 : Colors.black38,
      ),
    );
  }
}
