import 'app_release.dart';

abstract class UpdateState {
  const UpdateState();
}

class UpdateIdle extends UpdateState {
  const UpdateIdle();
}

class UpdateChecking extends UpdateState {
  const UpdateChecking();
}

class UpdateUpToDate extends UpdateState {
  final String installedVersion;
  final int installedCode;

  const UpdateUpToDate({
    required this.installedVersion,
    required this.installedCode,
  });
}

class UpdateAvailable extends UpdateState {
  final AppRelease release;
  final String installedVersion;
  final int installedCode;

  const UpdateAvailable({
    required this.release,
    required this.installedVersion,
    required this.installedCode,
  });
}

class UpdateDownloading extends UpdateState {
  final AppRelease release;
  final double progress; // 0.0 to 1.0
  final int bytesDownloaded;
  final int totalBytes;

  const UpdateDownloading({
    required this.release,
    required this.progress,
    required this.bytesDownloaded,
    required this.totalBytes,
  });
}

class UpdateVerifying extends UpdateState {
  final AppRelease release;
  final String stepDescription;

  const UpdateVerifying({
    required this.release,
    required this.stepDescription,
  });
}

class UpdateReadyToInstall extends UpdateState {
  final AppRelease release;
  final String apkFilePath;
  final String calculatedSha256;
  final bool isSha256Verified;
  final bool isFingerprintVerified;

  const UpdateReadyToInstall({
    required this.release,
    required this.apkFilePath,
    required this.calculatedSha256,
    required this.isSha256Verified,
    required this.isFingerprintVerified,
  });
}

class UpdateInstalling extends UpdateState {
  final String apkFilePath;

  const UpdateInstalling({required this.apkFilePath});
}

class UpdateError extends UpdateState {
  final String message;
  final String? technicalDetails;

  const UpdateError(this.message, {this.technicalDetails});
}
