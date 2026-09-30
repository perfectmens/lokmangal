import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/dto/github_release_dto.dart';

class UpdateApiService {
  final ApiClient _apiClient;

  UpdateApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<GitHubReleaseDto> fetchLatestRelease({
    required String owner,
    required String repo,
    String? token,
  }) async {
    final url = ApiEndpoints.latestRelease(owner, repo);
    final json = await _apiClient.getJson(url, token: token);
    return GitHubReleaseDto.fromJson(json as Map<String, dynamic>);
  }

  Future<VersionManifestDto?> fetchVersionManifest({
    required GitHubReleaseDto releaseDto,
    String? token,
  }) async {
    // Look for version.json in assets
    final versionAsset = releaseDto.assets.firstWhere(
      (a) => a.name.toLowerCase() == 'version.json',
      orElse: () => GitHubAssetDto(
        id: 0,
        name: '',
        browserDownloadUrl: '',
        size: 0,
        contentType: '',
      ),
    );

    if (versionAsset.id == 0 && versionAsset.browserDownloadUrl.isEmpty) {
      return null;
    }

    try {
      final downloadUrl = (token != null && token.isNotEmpty)
          ? 'https://api.github.com/repos/assets/${versionAsset.id}'
          : versionAsset.browserDownloadUrl;
      final json = await _apiClient.getJson(downloadUrl, token: token);
      return VersionManifestDto.fromJson(json as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<File> downloadApkFile({
    required String downloadUrl,
    required int assetId,
    required String destinationFilePath,
    String? token,
    required void Function(int receivedBytes, int totalBytes) onProgress,
  }) async {
    final client = http.Client();
    try {
      // For private repositories, streaming direct from asset API with token is required
      final effectiveUrl = (token != null && token.isNotEmpty && assetId > 0)
          ? 'https://api.github.com/repos/assets/$assetId'
          : downloadUrl;

      final request = http.Request('GET', Uri.parse(effectiveUrl));
      request.headers['User-Agent'] = 'Lokmangal-Android-App/0.0.1';
      request.headers['Accept'] = 'application/octet-stream';
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer ${token.trim()}';
      }

      final response = await client.send(request);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          'Failed to download APK: HTTP ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      final totalBytes = response.contentLength ?? -1;
      int receivedBytes = 0;

      final file = File(destinationFilePath);
      final sink = file.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        onProgress(receivedBytes, totalBytes);
      }

      await sink.flush();
      await sink.close();

      return file;
    } finally {
      client.close();
    }
  }
}
