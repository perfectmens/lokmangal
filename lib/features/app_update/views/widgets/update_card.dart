import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/neumorphic_button.dart';
import '../../../../core/widgets/neumorphic_card.dart';
import '../../../../core/widgets/neumorphic_progress.dart';
import '../../models/update_state.dart';
import '../../viewmodels/app_update_viewmodel.dart';

class UpdateCard extends StatelessWidget {
  const UpdateCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppUpdateViewModel>();
    final state = vm.state;

    return NeumorphicCard(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  boxShadow: AppShadows.circularButton(),
                ),
                child: const Icon(
                  Icons.system_update_rounded,
                  color: AppColors.orange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Application Update',
                      style: AppTypography.heading2,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Installed Version: v${vm.installedVersionName} (Build ${vm.installedVersionCode})',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // State-Driven Rendering
          if (state is UpdateIdle) ...[
            Text(
              'Remotely check for new builds, verified SHA-256 binaries, and OTA release updates from GitHub.',
              style: AppTypography.body,
            ),
            const SizedBox(height: 16),
            NeumorphicButton(
              onPressed: () => vm.checkForUpdates(),
              text: 'Check for Updates',
              icon: Icons.refresh_rounded,
              tone: NeumorphicTone.orange,
              isFullWidth: true,
            ),
          ] else if (state is UpdateChecking) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Querying GitHub Releases for new updates...',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ),
          ] else if (state is UpdateUpToDate) ...[
            Container(
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: AppColors.tealLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.teal.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lokmangal is Up to Date',
                          style: AppTypography.subtitle.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'You are running the latest v${state.installedVersion} release.',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            NeumorphicButton(
              onPressed: () => vm.checkForUpdates(),
              text: 'Check Again',
              icon: Icons.refresh_rounded,
              tone: NeumorphicTone.neutral,
              isFullWidth: true,
            ),
          ] else if (state is UpdateAvailable) ...[
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.orangeLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.orange.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.new_releases_rounded, color: AppColors.orange, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'New Release v${state.release.versionName}',
                        style: AppTypography.heading2.copyWith(fontSize: 16),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          state.release.formattedSize,
                          style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.release.title,
                    style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (state.release.releaseNotes.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      state.release.releaseNotes,
                      style: AppTypography.caption,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (state.release.sha256 != null && state.release.sha256!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, color: AppColors.teal, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'SHA-256: ${state.release.sha256!.substring(0, 16)}...',
                            style: AppTypography.caption.copyWith(
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            NeumorphicButton(
              onPressed: () => vm.downloadAndInstall(state.release),
              text: 'Download & Install Update',
              icon: Icons.download_rounded,
              tone: NeumorphicTone.orange,
              isFullWidth: true,
            ),
          ] else if (state is UpdateDownloading) ...[
            Text(
              'Downloading v${state.release.versionName} APK...',
              style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            NeumorphicProgressBar(
              progress: state.progress,
              label: '${(state.bytesDownloaded / (1024 * 1024)).toStringAsFixed(1)} MB / '
                     '${(state.totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Please keep the app open while downloading.',
                style: AppTypography.caption,
              ),
            ),
          ] else if (state is UpdateVerifying) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.teal),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state.stepDescription,
                      style: AppTypography.caption.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (state is UpdateReadyToInstall) ...[
            Container(
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: AppColors.tealLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.teal.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: AppColors.teal, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Integrity Verified',
                        style: AppTypography.subtitle.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'SHA-256 Checksum: MATCHED\nFingerprint Check: VERIFIED',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            NeumorphicButton(
              onPressed: () => vm.installApk(),
              text: 'Launch Package Installer',
              icon: Icons.install_mobile_rounded,
              tone: NeumorphicTone.orange,
              isFullWidth: true,
            ),
          ] else if (state is UpdateInstalling) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14.0),
                child: Text(
                  'Package installer launched. Confirm installation on your device.',
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ] else if (state is UpdateError) ...[
            Container(
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.message,
                      style: AppTypography.caption.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            NeumorphicButton(
              onPressed: () => vm.checkForUpdates(),
              text: 'Retry Check',
              icon: Icons.refresh_rounded,
              tone: NeumorphicTone.orange,
              isFullWidth: true,
            ),
          ],
        ],
      ),
    );
  }
}
