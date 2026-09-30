class ApiEndpoints {
  static const String defaultGithubOwner = 'perfectmens';
  static const String defaultGithubRepo = 'lokmangal';

  // Local PC Simulation Server Host (LAN IP or Localhost)
  // Can be overridden in Settings by the operator
  static String defaultSimulationHost = 'http://192.168.68.64:8000';

  // API Mapping references (CI/CD Track)
  static String latestRelease(String owner, String repo) =>
      'https://api.github.com/repos/$owner/$repo/releases/latest';

  static String releaseAsset(String owner, String repo, int assetId) =>
      'https://api.github.com/repos/$owner/$repo/releases/assets/$assetId';

  static String versionManifest(String owner, String repo, String tag) =>
      'https://github.com/$owner/$repo/releases/download/$tag/version.json';

  // Industrial Telemetry Endpoints (API Governance Track)
  static String plantStatus(String baseUrl) => '$baseUrl/api/v1/plant/status';
  static String telemetryEvents(String baseUrl) => '$baseUrl/api/v1/telemetry/events';
  static String productionSummary(String baseUrl) => '$baseUrl/api/v1/production/summary';
  static String productionBatches(String baseUrl) => '$baseUrl/api/v1/production/batches';
  static String powderMakerState(String baseUrl) => '$baseUrl/api/v1/process/powder-maker';
  static String storageLevels(String baseUrl) => '$baseUrl/api/v1/storage/levels';
  static String energyOverview(String baseUrl) => '$baseUrl/api/v1/energy/overview';
  static String alarmsList(String baseUrl) => '$baseUrl/api/v1/alarms';
  static String acknowledgeAlarm(String baseUrl, String alarmId) =>
      '$baseUrl/api/v1/alarms/$alarmId/acknowledge';
}
