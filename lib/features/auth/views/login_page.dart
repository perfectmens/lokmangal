import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/neumorphic_button.dart';
import '../../../core/widgets/neumorphic_card.dart';
import '../../../core/widgets/neumorphic_text_field.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemoCredentials() {
    HapticFeedback.lightImpact();
    setState(() {
      _usernameController.text = 'demo';
      _passwordController.text = 'demo';
    });
  }

  Future<void> _submitLogin() async {
    HapticFeedback.lightImpact();
    final authVm = context.read<AuthViewModel>();
    final success = await authVm.login(
      _usernameController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome, Operator. Connected to Corelife Plant.'),
          backgroundColor: AppColors.teal,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. Plant Logo & Brand Identity
                  Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      boxShadow: AppShadows.circularButton(),
                    ),
                    child: Image.asset(
                      'assets/auraliss_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.factory_rounded,
                        color: AppColors.teal,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Auraliss Corelife',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Plant Telemetry & Controls • 20 TPD',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 2. Neumorphic Authentication Card
                  NeumorphicCard(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.background,
                                boxShadow: AppShadows.circularButton(),
                              ),
                              child: const Icon(
                                Icons.lock_person_rounded,
                                color: AppColors.orange,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Operator Sign In',
                                    style: AppTypography.heading2,
                                  ),
                                  Text(
                                    'Authorized personnel access',
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Username Input
                        NeumorphicTextField(
                          controller: _usernameController,
                          label: 'Username',
                          hint: 'Enter username',
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 16),

                        // Password Input
                        NeumorphicTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Enter password',
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              size: 20,
                              color: AppColors.textMuted,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Error Banner if invalid credentials
                        if (authVm.errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 10.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: AppColors.error,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authVm.errorMessage!,
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Sign In Action Button (Orange for user action)
                        NeumorphicButton(
                          onPressed: authVm.isLoading ? null : _submitLogin,
                          isLoading: authVm.isLoading,
                          text: 'Sign In',
                          icon: Icons.login_rounded,
                          tone: NeumorphicTone.orange,
                          isFullWidth: true,
                        ),
                        const SizedBox(height: 16),

                        // Autofill Helper
                        Center(
                          child: TextButton(
                            onPressed: _fillDemoCredentials,
                            child: const Text(
                              'Auto-fill credentials',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Security Tag
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.teal,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Secure Plant Telemetry Link Active',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
