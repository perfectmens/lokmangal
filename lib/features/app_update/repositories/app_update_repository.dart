import 'dart:io';
import '../models/app_release.dart';

abstract class AppUpdateRepository {
  Future<Map<String, dynamic>> getInstalledAppInfo();
  Future<AppRelease?> checkForUpdate({
    required String owner,
    required String repo,
    String? token,
  });
  Future<File> downloadReleaseApk({
    required AppRelease release,
    String? token,
    required void Function(int received, int total) onProgress,
  });
  Future<String> calculateSha256(File file);
  bool verifyChecksum(String calculatedSha256, String? expectedSha256);
  Future<bool> triggerInstallation(File file);

  // Settings persistence
  Future<bool> getAutoScanEnabled();
  Future<void> setAutoScanEnabled(bool enabled);
  Future<String?> getSavedGithubToken();
  Future<void> setSavedGithubToken(String? token);
  Future<bool> getVerifySha256Enabled();
  Future<void> setVerifySha256Enabled(bool enabled);
  Future<bool> getVerifyFingerprintEnabled();
  Future<void> setVerifyFingerprintEnabled(bool enabled);
}
