import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_release.dart';
import '../models/dto/github_release_dto.dart';
import '../services/update_api_service.dart';
import 'app_update_repository.dart';

class AppUpdateRepositoryImpl implements AppUpdateRepository {
  final UpdateApiService _apiService;
  static const String _keyAutoScan = 'app_update_auto_scan';
  static const String _keyGithubToken = 'app_update_github_token';
  static const String _keyVerifySha256 = 'app_update_verify_sha256';
  static const String _keyVerifyFingerprint = 'app_update_verify_fingerprint';

  // Expected production release signing certificate fingerprint (from android-ci-cd)
  static const String expectedCertFingerprint =
      'A6:4B:6D:FB:3C:5B:7F:A5:A0:A3:36:3F:AC:69:21:1D:4D:C0:C5:26:93:17:7E:64:29:0A:AB:E4:A0:F7:CB:59';

  AppUpdateRepositoryImpl({UpdateApiService? apiService})
      : _apiService = apiService ?? UpdateApiService();

  @override
  Future<Map<String, dynamic>> getInstalledAppInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return {
        'versionName': info.version,
        'versionCode': int.tryParse(info.buildNumber) ?? 1,
        'appName': info.appName,
        'packageName': info.packageName,
      };
    } catch (_) {
      // Fallback for non-platform environment or test runner
      return {
        'versionName': '0.0.1',
        'versionCode': 1,
        'appName': 'lokmangal',
        'packageName': 'com.lokmangal.lokmangal',
      };
    }
  }

  @override
  Future<AppRelease?> checkForUpdate({
    required String owner,
    required String repo,
    String? token,
  }) async {
    final releaseDto = await _apiService.fetchLatestRelease(
      owner: owner,
      repo: repo,
      token: token,
    );

    // Fetch version.json manifest if present
    final manifestDto = await _apiService.fetchVersionManifest(
      releaseDto: releaseDto,
      token: token,
    );

    // Locate release APK in assets
    final apkAsset = releaseDto.assets.firstWhere(
      (a) => a.name.endsWith('.apk'),
      orElse: () => GitHubAssetDto(
        id: 0,
        name: '',
        browserDownloadUrl: '',
        size: 0,
        contentType: '',
      ),
    );

    if (apkAsset.id == 0 && apkAsset.browserDownloadUrl.isEmpty) {
      return null;
    }

    final rawTag = releaseDto.tagName.startsWith('v')
        ? releaseDto.tagName.substring(1)
        : releaseDto.tagName;

    // Use manifest values if available, else derive from tag and release
    final resolvedVersionName = manifestDto?.versionName ?? rawTag;
    final resolvedVersionCode = manifestDto?.versionCode ??
        _extractVersionCodeFromTagOrBody(releaseDto.body, rawTag);

    // Extract SHA-256 from manifest or body
    final resolvedSha256 = manifestDto?.sha256.isNotEmpty == true
        ? manifestDto!.sha256
        : _extractSha256FromBody(releaseDto.body);

    DateTime? publishedDate;
    try {
      if (releaseDto.publishedAt.isNotEmpty) {
        publishedDate = DateTime.parse(releaseDto.publishedAt);
      }
    } catch (_) {}

    return AppRelease(
      tagName: releaseDto.tagName,
      versionName: resolvedVersionName,
      versionCode: resolvedVersionCode,
      title: releaseDto.name.isNotEmpty ? releaseDto.name : releaseDto.tagName,
      releaseNotes: releaseDto.body,
      publishedAt: publishedDate,
      apkFileName: apkAsset.name.isNotEmpty ? apkAsset.name : 'lokmangal-release.apk',
      apkDownloadUrl: apkAsset.browserDownloadUrl,
      apkAssetId: apkAsset.id,
      apkSizeBytes: apkAsset.size,
      sha256: resolvedSha256,
      certificateFingerprint: manifestDto?.certificateFingerprint ?? expectedCertFingerprint,
    );
  }

  int _extractVersionCodeFromTagOrBody(String body, String tag) {
    final regex = RegExp(r'(?:Build|Code|versionCode)[:\s]*([0-9]+)', caseSensitive: false);
    final match = regex.firstMatch(body);
    if (match != null && match.group(1) != null) {
      return int.tryParse(match.group(1)!) ?? 1;
    }
    return 1;
  }

  String? _extractSha256FromBody(String body) {
    final regex = RegExp(r'SHA-?256[:\s]*`?([a-fA-F0-9]{64})`?', caseSensitive: false);
    final match = regex.firstMatch(body);
    if (match != null && match.group(1) != null) {
      return match.group(1)!.toLowerCase();
    }
    return null;
  }

  @override
  Future<File> downloadReleaseApk({
    required AppRelease release,
    String? token,
    required void Function(int received, int total) onProgress,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final downloadPath = '${tempDir.path}/${release.apkFileName}';

    // Delete existing file if exists
    final targetFile = File(downloadPath);
    if (await targetFile.exists()) {
      await targetFile.delete();
    }

    return _apiService.downloadApkFile(
      downloadUrl: release.apkDownloadUrl,
      assetId: release.apkAssetId,
      destinationFilePath: downloadPath,
      token: token,
      onProgress: onProgress,
    );
  }

  @override
  Future<String> calculateSha256(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  @override
  bool verifyChecksum(String calculatedSha256, String? expectedSha256) {
    if (expectedSha256 == null || expectedSha256.trim().isEmpty) {
      return true; // No hash provided to check against
    }
    return calculatedSha256.trim().toLowerCase() == expectedSha256.trim().toLowerCase();
  }

  @override
  Future<bool> triggerInstallation(File file) async {
    if (!await file.exists()) {
      return false;
    }

    final result = await OpenFilex.open(
      file.path,
      type: 'application/vnd.android.package-archive',
    );

    return result.type == ResultType.done;
  }

  @override
  Future<bool> getAutoScanEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoScan) ?? true;
  }

  @override
  Future<void> setAutoScanEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoScan, enabled);
  }

  @override
  Future<String?> getSavedGithubToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyGithubToken);
  }

  @override
  Future<void> setSavedGithubToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null || token.trim().isEmpty) {
      await prefs.remove(_keyGithubToken);
    } else {
      await prefs.setString(_keyGithubToken, token.trim());
    }
  }

  @override
  Future<bool> getVerifySha256Enabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyVerifySha256) ?? true;
  }

  @override
  Future<void> setVerifySha256Enabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVerifySha256, enabled);
  }

  @override
  Future<bool> getVerifyFingerprintEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyVerifyFingerprint) ?? true;
  }

  @override
  Future<void> setVerifyFingerprintEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVerifyFingerprint, enabled);
  }
}
