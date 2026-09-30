import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/neumorphic_button.dart';
import '../../../core/widgets/neumorphic_card.dart';
import '../../../core/widgets/neumorphic_switch.dart';
import '../../../core/widgets/neumorphic_text_field.dart';
import '../repositories/app_update_repository_impl.dart';
import '../viewmodels/app_update_viewmodel.dart';
import '../../plant/viewmodels/plant_viewmodel.dart';
import 'widgets/update_card.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback onBack;

  const SettingsPage({super.key, required this.onBack});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _tokenController;
  late final TextEditingController _ownerController;
  late final TextEditingController _repoController;
  late final TextEditingController _serverUrlController;
  bool _obscureToken = true;

  @override
  void initState() {
    super.initState();
    final vm = context.read<AppUpdateViewModel>();
    final plantVm = context.read<PlantViewModel>();
    _tokenController = TextEditingController(text: vm.githubToken ?? '');
    _ownerController = TextEditingController(text: vm.githubOwner);
    _repoController = TextEditingController(text: vm.githubRepo);
    _serverUrlController = TextEditingController(text: plantVm.baseUrl);
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _ownerController.dispose();
    _repoController.dispose();
    _serverUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppUpdateViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header with Back Button
              Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surface,
                        boxShadow: AppShadows.circularButton(),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text('Settings', style: AppTypography.heading1),
                ],
              ),
              const SizedBox(height: 20),

              // 1. Remote App Update Card
              const UpdateCard(),
              const SizedBox(height: 18),

              // 2. Automated Scanning & Integrity Preferences
              NeumorphicCard(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface,
                            boxShadow: AppShadows.circularButton(),
                          ),
                          child: const Icon(
                            Icons.security_rounded,
                            color: AppColors.teal,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('Integrity & Auto-Scan', style: AppTypography.heading2),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Auto-scan Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Auto-Scan for Updates',
                                style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Check for new releases automatically when opening the app.',
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        NeumorphicSwitch(
                          value: vm.autoScanEnabled,
                          onChanged: (val) => vm.setAutoScan(val),
                        ),
                      ],
                    ),
                    const Divider(height: 28),

                    // SHA-256 Checksum Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verify SHA-256 Checksum',
                                style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Strictly verify binary hash before initiating package installation.',
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        NeumorphicSwitch(
                          value: vm.verifySha256,
                          onChanged: (val) => vm.setVerifySha256(val),
                        ),
                      ],
                    ),
                    const Divider(height: 28),

                    // Signing Fingerprint Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Enforce Signing Fingerprint',
                                style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Match APK signing certificate against release keystore fingerprint.',
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        NeumorphicSwitch(
                          value: vm.verifyFingerprint,
                          onChanged: (val) => vm.setVerifyFingerprint(val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EXPECTED CERTIFICATE SHA-256 FINGERPRINT:',
                            style: AppTypography.caption.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            AppUpdateRepositoryImpl.expectedCertFingerprint,
                            style: AppTypography.caption.copyWith(
                              fontSize: 10,
                              fontFamily: 'monospace',
                              color: AppColors.teal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 3. GitHub Private Repository Access
              NeumorphicCard(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface,
                            boxShadow: AppShadows.circularButton(),
                          ),
                          child: const Icon(
                            Icons.hub_rounded,
                            color: AppColors.orange,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('GitHub Distribution Server', style: AppTypography.heading2),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: NeumorphicTextField(
                            controller: _ownerController,
                            label: 'Owner / Org',
                            hint: 'perfectmens',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: NeumorphicTextField(
                            controller: _repoController,
                            label: 'Repository',
                            hint: 'lokmangal',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    NeumorphicTextField(
                      controller: _tokenController,
                      label: 'GitHub Personal Access Token (for Private Repos)',
                      hint: 'ghp_xxxx or gho_xxxx',
                      obscureText: _obscureToken,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureToken ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          size: 20,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () => setState(() => _obscureToken = !_obscureToken),
                      ),
                    ),
                    const SizedBox(height: 16),
                    NeumorphicButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await vm.setRepositoryDetails(
                          owner: _ownerController.text,
                          repo: _repoController.text,
                        );
                        await vm.setGithubToken(_tokenController.text);
                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('GitHub settings saved successfully.'),
                            backgroundColor: AppColors.teal,
                          ),
                        );
                      },
                      text: 'Save Server Configuration',
                      icon: Icons.save_rounded,
                      tone: NeumorphicTone.orange,
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 4. Industrial Telemetry Simulation Host
              NeumorphicCard(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface,
                            boxShadow: AppShadows.circularButton(),
                          ),
                          child: const Icon(
                            Icons.sensors_rounded,
                            color: AppColors.teal,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('Telemetry Backend & Simulation Host', style: AppTypography.heading2),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Address of local PC simulation server or internet cloud telemetry API.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 14),
                    NeumorphicTextField(
                      controller: _serverUrlController,
                      label: 'Simulation Host URL',
                      hint: 'http://192.168.68.64:8000',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: NeumorphicButton(
                            onPressed: () {
                              final plantVm = context.read<PlantViewModel>();
                              plantVm.updateBaseUrl(_serverUrlController.text);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Connecting to ${plantVm.baseUrl}...'),
                                  backgroundColor: AppColors.teal,
                                ),
                              );
                            },
                            text: 'Connect & Test',
                            icon: Icons.sync_rounded,
                            tone: NeumorphicTone.teal,
                            isFullWidth: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
