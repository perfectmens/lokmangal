class GitHubAssetDto {
  final int id;
  final String name;
  final String browserDownloadUrl;
  final int size;
  final String contentType;

  GitHubAssetDto({
    required this.id,
    required this.name,
    required this.browserDownloadUrl,
    required this.size,
    required this.contentType,
  });

  factory GitHubAssetDto.fromJson(Map<String, dynamic> json) {
    return GitHubAssetDto(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      browserDownloadUrl: json['browser_download_url'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      contentType: json['content_type'] as String? ?? '',
    );
  }
}

class GitHubReleaseDto {
  final String tagName;
  final String name;
  final String body;
  final String publishedAt;
  final bool prerelease;
  final List<GitHubAssetDto> assets;

  GitHubReleaseDto({
    required this.tagName,
    required this.name,
    required this.body,
    required this.publishedAt,
    required this.prerelease,
    required this.assets,
  });

  factory GitHubReleaseDto.fromJson(Map<String, dynamic> json) {
    final rawAssets = json['assets'] as List<dynamic>? ?? [];
    return GitHubReleaseDto(
      tagName: json['tag_name'] as String? ?? '',
      name: json['name'] as String? ?? '',
      body: json['body'] as String? ?? '',
      publishedAt: json['published_at'] as String? ?? '',
      prerelease: json['prerelease'] as bool? ?? false,
      assets: rawAssets
          .map((a) => GitHubAssetDto.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}

class VersionManifestDto {
  final int versionCode;
  final String versionName;
  final String apkFileName;
  final String downloadUrl;
  final String sha256;
  final String certificateFingerprint;
  final String releaseNotes;

  VersionManifestDto({
    required this.versionCode,
    required this.versionName,
    required this.apkFileName,
    required this.downloadUrl,
    required this.sha256,
    required this.certificateFingerprint,
    required this.releaseNotes,
  });

  factory VersionManifestDto.fromJson(Map<String, dynamic> json) {
    return VersionManifestDto(
      versionCode: json['versionCode'] as int? ?? 1,
      versionName: json['versionName'] as String? ?? '0.0.1',
      apkFileName: json['apkFileName'] as String? ?? '',
      downloadUrl: json['downloadUrl'] as String? ?? '',
      sha256: json['sha256'] as String? ?? '',
      certificateFingerprint: json['certificateFingerprint'] as String? ?? '',
      releaseNotes: json['releaseNotes'] as String? ?? '',
    );
  }
}
