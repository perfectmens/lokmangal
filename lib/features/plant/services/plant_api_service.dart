import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/plant_models.dart';

class PlantApiService {
  final ApiClient _client;

  PlantApiService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<PlantStatus> fetchPlantStatus(String baseUrl) async {
    final url = ApiEndpoints.plantStatus(baseUrl);
    final data = await _client.getJson(url);
    return PlantStatus.fromJson(data as Map<String, dynamic>);
  }

  Future<List<PlantEvent>> fetchTelemetryEvents(String baseUrl) async {
    final url = ApiEndpoints.telemetryEvents(baseUrl);
    final data = await _client.getJson(url);
    final list = data as List<dynamic>;
    return list.map((e) => PlantEvent.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ProductionSummary> fetchProductionSummary(String baseUrl) async {
    final url = ApiEndpoints.productionSummary(baseUrl);
    final data = await _client.getJson(url);
    return ProductionSummary.fromJson(data as Map<String, dynamic>);
  }

  Future<List<BatchRecord>> fetchProductionBatches(String baseUrl) async {
    final url = ApiEndpoints.productionBatches(baseUrl);
    final data = await _client.getJson(url);
    final list = data as List<dynamic>;
    return list.map((e) => BatchRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PowderMakerState> fetchPowderMakerState(String baseUrl) async {
    final url = ApiEndpoints.powderMakerState(baseUrl);
    final data = await _client.getJson(url);
    return PowderMakerState.fromJson(data as Map<String, dynamic>);
  }

  Future<StorageLevels> fetchStorageLevels(String baseUrl) async {
    final url = ApiEndpoints.storageLevels(baseUrl);
    final data = await _client.getJson(url);
    return StorageLevels.fromJson(data as Map<String, dynamic>);
  }

  Future<EnergyOverview> fetchEnergyOverview(String baseUrl) async {
    final url = ApiEndpoints.energyOverview(baseUrl);
    final data = await _client.getJson(url);
    return EnergyOverview.fromJson(data as Map<String, dynamic>);
  }

  Future<AlarmsResponse> fetchAlarms(String baseUrl) async {
    final url = ApiEndpoints.alarmsList(baseUrl);
    final data = await _client.getJson(url);
    return AlarmsResponse.fromJson(data as Map<String, dynamic>);
  }

  Future<bool> acknowledgeAlarm(String baseUrl, String alarmId, {String operatorName = 'Operator'}) async {
    final url = ApiEndpoints.acknowledgeAlarm(baseUrl, alarmId);
    final res = await _client.postJson(url, body: {
      'operator': operatorName,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });
    return (res as Map<String, dynamic>)['success'] == true;
  }
}
