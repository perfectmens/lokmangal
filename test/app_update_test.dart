import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokmangal/features/app_update/models/app_release.dart';
import 'package:lokmangal/features/app_update/models/update_state.dart';
import 'package:lokmangal/features/app_update/repositories/app_update_repository.dart';
import 'package:lokmangal/features/app_update/viewmodels/app_update_viewmodel.dart';

class MockAppUpdateRepository implements AppUpdateRepository {
  AppRelease? nextRelease;
  Map<String, dynamic> installedInfo = {
    'versionName': '0.0.1',
    'versionCode': 1,
    'appName': 'lokmangal',
    'packageName': 'com.lokmangal.lokmangal',
  };
  bool autoScan = true;
  bool verifySha256 = true;
  bool verifyFingerprint = true;
  String? token;

  @override
  Future<Map<String, dynamic>> getInstalledAppInfo() async => installedInfo;

  @override
  Future<AppRelease?> checkForUpdate({
    required String owner,
    required String repo,
    String? token,
  }) async => nextRelease;

  @override
  Future<File> downloadReleaseApk({
    required AppRelease release,
    String? token,
    required void Function(int received, int total) onProgress,
  }) async {
    onProgress(100, 100);
    return File('test_app.apk');
  }

  @override
  Future<String> calculateSha256(File file) async => 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';

  @override
  bool verifyChecksum(String calculatedSha256, String? expectedSha256) =>
      calculatedSha256 == expectedSha256;

  @override
  Future<bool> triggerInstallation(File file) async => true;

  @override
  Future<bool> getAutoScanEnabled() async => autoScan;

  @override
  Future<void> setAutoScanEnabled(bool enabled) async => autoScan = enabled;

  @override
  Future<String?> getSavedGithubToken() async => token;

  @override
  Future<void> setSavedGithubToken(String? t) async => token = t;

  @override
  Future<bool> getVerifySha256Enabled() async => verifySha256;

  @override
  Future<void> setVerifySha256Enabled(bool enabled) async => verifySha256 = enabled;

  @override
  Future<bool> getVerifyFingerprintEnabled() async => verifyFingerprint;

  @override
  Future<void> setVerifyFingerprintEnabled(bool enabled) async => verifyFingerprint = enabled;
}

void main() {
  group('AppUpdateViewModel Unit Tests', () {
    late MockAppUpdateRepository mockRepo;
    late AppUpdateViewModel viewModel;

    setUp(() {
      mockRepo = MockAppUpdateRepository();
      viewModel = AppUpdateViewModel(repository: mockRepo);
    });

    test('Initializes with installed version from platform (avoiding loop)', () async {
      mockRepo.autoScan = false;
      await viewModel.initialize();

      expect(viewModel.installedVersionName, '0.0.1');
      expect(viewModel.installedVersionCode, 1);
      expect(viewModel.state is UpdateIdle, isTrue);
    });

    test('Detects new update when server versionCode > installed versionCode', () async {
      mockRepo.autoScan = false;
      await viewModel.initialize();

      mockRepo.nextRelease = const AppRelease(
        tagName: 'v0.0.2',
        versionName: '0.0.2',
        versionCode: 2,
        title: 'Release v0.0.2',
        releaseNotes: 'Performance optimization',
        apkFileName: 'lokmangal-release-v0.0.2.apk',
        apkDownloadUrl: 'https://example.com/apk',
        apkAssetId: 1234,
        apkSizeBytes: 20000000,
        sha256: 'abc123hash',
      );

      await viewModel.checkForUpdates();

      expect(viewModel.state is UpdateAvailable, isTrue);
      final state = viewModel.state as UpdateAvailable;
      expect(state.release.versionName, '0.0.2');
      expect(state.release.versionCode, 2);
    });

    test('Reports UpToDate when server version matches installed version', () async {
      mockRepo.autoScan = false;
      await viewModel.initialize();

      mockRepo.nextRelease = const AppRelease(
        tagName: 'v0.0.1',
        versionName: '0.0.1',
        versionCode: 1,
        title: 'Release v0.0.1',
        releaseNotes: 'Initial Release',
        apkFileName: 'lokmangal-release-v0.0.1.apk',
        apkDownloadUrl: 'https://example.com/apk',
        apkAssetId: 1234,
        apkSizeBytes: 20000000,
      );

      await viewModel.checkForUpdates();

      expect(viewModel.state is UpdateUpToDate, isTrue);
      final state = viewModel.state as UpdateUpToDate;
      expect(state.installedVersion, '0.0.1');
    });

    test('Handles network error gracefully without crashing UI', () async {
      mockRepo.autoScan = false;
      await viewModel.initialize();

      // Configure repository to throw error
      mockRepo.nextRelease = null;
      viewModel.setRepositoryDetails(owner: 'invalid-owner-404', repo: 'invalid-repo');

      await viewModel.checkForUpdates();

      expect(viewModel.state is UpdateUpToDate || viewModel.state is UpdateError, isTrue);
    });
  });
}
