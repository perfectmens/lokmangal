class AppRelease {
  final String tagName;
  final String versionName;
  final int versionCode;
  final String title;
  final String releaseNotes;
  final DateTime? publishedAt;
  final String apkFileName;
  final String apkDownloadUrl;
  final int apkAssetId;
  final int apkSizeBytes;
  final String? sha256;
  final String? certificateFingerprint;

  const AppRelease({
    required this.tagName,
    required this.versionName,
    required this.versionCode,
    required this.title,
    required this.releaseNotes,
    this.publishedAt,
    required this.apkFileName,
    required this.apkDownloadUrl,
    required this.apkAssetId,
    required this.apkSizeBytes,
    this.sha256,
    this.certificateFingerprint,
  });

  String get formattedSize {
    if (apkSizeBytes <= 0) return 'Unknown size';
    final mb = apkSizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }
}
