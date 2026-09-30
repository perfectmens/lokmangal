import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/app_release.dart';
import '../models/update_state.dart';
import '../repositories/app_update_repository.dart';

class AppUpdateViewModel extends ChangeNotifier {
  final AppUpdateRepository repository;
  AppUpdateRepository get _repository => repository;

  UpdateState _state = const UpdateIdle();
  UpdateState get state => _state;

  String _installedVersionName = '0.0.1';
  int _installedVersionCode = 1;
  String get installedVersionName => _installedVersionName;
  int get installedVersionCode => _installedVersionCode;

  bool _autoScanEnabled = true;
  bool get autoScanEnabled => _autoScanEnabled;

  bool _verifySha256 = true;
  bool get verifySha256 => _verifySha256;

  bool _verifyFingerprint = true;
  bool get verifyFingerprint => _verifyFingerprint;

  String _githubOwner = 'perfectmens';
  String _githubRepo = 'lokmangal';
  String? _githubToken;

  String get githubOwner => _githubOwner;
  String get githubRepo => _githubRepo;
  String? get githubToken => _githubToken;

  AppRelease? _availableRelease;
  AppRelease? get availableRelease => _availableRelease;

  File? _downloadedApkFile;
  File? get downloadedApkFile => _downloadedApkFile;

  AppUpdateViewModel({required this.repository});

  Future<void> initialize() async {
    // 1. Read real installed app info from platform to avoid infinite update loop
    final appInfo = await _repository.getInstalledAppInfo();
    _installedVersionName = appInfo['versionName'] as String? ?? '0.0.1';
    _installedVersionCode = appInfo['versionCode'] as int? ?? 1;

    // 2. Load stored preferences
    _autoScanEnabled = await _repository.getAutoScanEnabled();
    _githubToken = await _repository.getSavedGithubToken();
    _verifySha256 = await _repository.getVerifySha256Enabled();
    _verifyFingerprint = await _repository.getVerifyFingerprintEnabled();

    notifyListeners();

    // 3. Auto-scan for update if enabled
    if (_autoScanEnabled) {
      await checkForUpdates(isSilent: true);
    }
  }

  Future<void> setAutoScan(bool value) async {
    _autoScanEnabled = value;
    await _repository.setAutoScanEnabled(value);
    notifyListeners();
  }

  Future<void> setVerifySha256(bool value) async {
    _verifySha256 = value;
    await _repository.setVerifySha256Enabled(value);
    notifyListeners();
  }

  Future<void> setVerifyFingerprint(bool value) async {
    _verifyFingerprint = value;
    await _repository.setVerifyFingerprintEnabled(value);
    notifyListeners();
  }

  Future<void> setGithubToken(String? token) async {
    _githubToken = token?.trim().isEmpty == true ? null : token?.trim();
    await _repository.setSavedGithubToken(_githubToken);
    notifyListeners();
  }

  Future<void> setRepositoryDetails({required String owner, required String repo}) async {
    _githubOwner = owner.trim();
    _githubRepo = repo.trim();
    notifyListeners();
  }

  Future<void> checkForUpdates({bool isSilent = false}) async {
    if (!isSilent) {
      _state = const UpdateChecking();
      notifyListeners();
    }

    try {
      final release = await _repository.checkForUpdate(
        owner: _githubOwner,
        repo: _githubRepo,
        token: _githubToken,
      );

      if (release == null) {
        _state = UpdateUpToDate(
          installedVersion: _installedVersionName,
          installedCode: _installedVersionCode,
        );
        notifyListeners();
        return;
      }

      // Version comparison: check if server release is newer
      final bool isNewer = _isServerReleaseNewer(release);

      if (isNewer) {
        _availableRelease = release;
        _state = UpdateAvailable(
          release: release,
          installedVersion: _installedVersionName,
          installedCode: _installedVersionCode,
        );
      } else {
        _availableRelease = null;
        _state = UpdateUpToDate(
          installedVersion: _installedVersionName,
          installedCode: _installedVersionCode,
        );
      }
      notifyListeners();
    } catch (e) {
      if (!isSilent) {
        _state = UpdateError(
          'Failed to check for updates: $e',
          technicalDetails: e.toString(),
        );
        notifyListeners();
      }
    }
  }

  bool _isServerReleaseNewer(AppRelease release) {
    if (release.versionCode > _installedVersionCode) {
      return true;
    }
    // SemVer comparison if version codes match
    return _compareSemver(release.versionName, _installedVersionName) > 0;
  }

  int _compareSemver(String v1, String v2) {
    final parts1 = v1.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final parts2 = v2.split('.').map((p) => int.tryParse(p) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      final num1 = i < parts1.length ? parts1[i] : 0;
      final num2 = i < parts2.length ? parts2[i] : 0;
      if (num1 > num2) return 1;
      if (num1 < num2) return -1;
    }
    return 0;
  }

  Future<void> downloadAndInstall(AppRelease release) async {
    _state = UpdateDownloading(
      release: release,
      progress: 0.0,
      bytesDownloaded: 0,
      totalBytes: release.apkSizeBytes,
    );
    notifyListeners();

    try {
      // 1. Download file
      final downloadedFile = await _repository.downloadReleaseApk(
        release: release,
        token: _githubToken,
        onProgress: (received, total) {
          final progress = total > 0 ? (received / total).clamp(0.0, 1.0) : 0.0;
          _state = UpdateDownloading(
            release: release,
            progress: progress,
            bytesDownloaded: received,
            totalBytes: total,
          );
          notifyListeners();
        },
      );

      _downloadedApkFile = downloadedFile;

      // 2. Integrity Verification
      _state = UpdateVerifying(
        release: release,
        stepDescription: 'Calculating SHA-256 cryptographic checksum...',
      );
      notifyListeners();

      final calculatedSha256 = await _repository.calculateSha256(downloadedFile);

      bool sha256Valid = true;
      if (_verifySha256 && release.sha256 != null && release.sha256!.isNotEmpty) {
        sha256Valid = _repository.verifyChecksum(calculatedSha256, release.sha256);
        if (!sha256Valid) {
          _state = UpdateError(
            'Package integrity verification failed: SHA-256 mismatch!\n'
            'Expected: ${release.sha256}\n'
            'Calculated: $calculatedSha256',
          );
          notifyListeners();
          return;
        }
      }

      // 3. Ready to install state
      _state = UpdateReadyToInstall(
        release: release,
        apkFilePath: downloadedFile.path,
        calculatedSha256: calculatedSha256,
        isSha256Verified: sha256Valid,
        isFingerprintVerified: _verifyFingerprint,
      );
      notifyListeners();

      // Automatically trigger installation
      await installApk();
    } catch (e) {
      _state = UpdateError(
        'Download failed: $e',
        technicalDetails: e.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> installApk() async {
    if (_downloadedApkFile == null || !await _downloadedApkFile!.exists()) {
      _state = const UpdateError('Downloaded APK file not found');
      notifyListeners();
      return;
    }

    _state = UpdateInstalling(apkFilePath: _downloadedApkFile!.path);
    notifyListeners();

    final launched = await _repository.triggerInstallation(_downloadedApkFile!);
    if (!launched) {
      _state = const UpdateError(
        'Failed to start installer. Please allow installation of unknown apps for Lokmangal in Android Settings.',
      );
      notifyListeners();
    }
  }

  void resetState() {
    _state = const UpdateIdle();
    notifyListeners();
  }
}
