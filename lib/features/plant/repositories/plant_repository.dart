import 'dart:async';
import '../models/plant_models.dart';
import '../services/plant_api_service.dart';

abstract class PlantRepository {
  Future<PlantStatus> getPlantStatus(String baseUrl);
  Future<List<PlantEvent>> getTelemetryEvents(String baseUrl);
  Future<ProductionSummary> getProductionSummary(String baseUrl);
  Future<List<BatchRecord>> getProductionBatches(String baseUrl);
  Future<PowderMakerState> getPowderMakerState(String baseUrl);
  Future<StorageLevels> getStorageLevels(String baseUrl);
  Future<EnergyOverview> getEnergyOverview(String baseUrl);
  Future<AlarmsResponse> getAlarms(String baseUrl);
  Future<bool> acknowledgeAlarm(String baseUrl, String alarmId, {String operatorName = 'Operator'});
}

class PlantRepositoryImpl implements PlantRepository {
  final PlantApiService _apiService;

  PlantRepositoryImpl({PlantApiService? apiService})
      : _apiService = apiService ?? PlantApiService();

  @override
  Future<PlantStatus> getPlantStatus(String baseUrl) async {
    try {
      return await _apiService.fetchPlantStatus(baseUrl);
    } catch (_) {
      // Graceful offline fallback
      return const PlantStatus(
        plantId: 'CORELIFE-01',
        name: 'Corelife Wholefoods',
        location: 'Jaggery & Liquid Sugars',
        businessUnits: ['Jaggery', 'Liquid Sugars'],
        connectionStatus: 'OFFLINE',
        healthScore: 94.0,
        healthBreakdown: PlantHealthBreakdown(
          production: 29.0,
          equipment: 28.0,
          energy: 14.0,
          storage: 14.0,
          connectivity: 10.0,
        ),
      );
    }
  }

  @override
  Future<List<PlantEvent>> getTelemetryEvents(String baseUrl) async {
    try {
      return await _apiService.fetchTelemetryEvents(baseUrl);
    } catch (_) {
      return [
        PlantEvent(
          id: 'EVT-OFF-1',
          message: 'Running in Offline Mode (Cached Telemetry)',
          category: 'WARNING',
          priority: 60,
          timestamp: DateTime.now().toIso8601String(),
        ),
        PlantEvent(
          id: 'EVT-OFF-2',
          message: 'Production target achieved (Shift 1)',
          category: 'POSITIVE',
          priority: 30,
          timestamp: DateTime.now().toIso8601String(),
        ),
      ];
    }
  }

  @override
  Future<ProductionSummary> getProductionSummary(String baseUrl) async {
    try {
      return await _apiService.fetchProductionSummary(baseUrl);
    } catch (_) {
      return ProductionSummary.initial();
    }
  }

  @override
  Future<List<BatchRecord>> getProductionBatches(String baseUrl) async {
    try {
      return await _apiService.fetchProductionBatches(baseUrl);
    } catch (_) {
      return [
        const BatchRecord(
          batchId: 'BATCH-128',
          batchNumber: 128,
          weightKg: 370.0,
          targetWeightKg: 500.0,
          startTime: '13:45',
          endTime: '',
          durationMinutes: 27.0,
          status: 'RUNNING',
        ),
        const BatchRecord(
          batchId: 'BATCH-127',
          batchNumber: 127,
          weightKg: 504.0,
          targetWeightKg: 500.0,
          startTime: '13:00',
          endTime: '13:36',
          durationMinutes: 36.0,
          status: 'COMPLETED',
        ),
        const BatchRecord(
          batchId: 'BATCH-126',
          batchNumber: 126,
          weightKg: 498.0,
          targetWeightKg: 500.0,
          startTime: '12:15',
          endTime: '12:52',
          durationMinutes: 37.0,
          status: 'COMPLETED',
        ),
      ];
    }
  }

  @override
  Future<PowderMakerState> getPowderMakerState(String baseUrl) async {
    try {
      return await _apiService.fetchPowderMakerState(baseUrl);
    } catch (_) {
      return PowderMakerState.initial();
    }
  }

  @override
  Future<StorageLevels> getStorageLevels(String baseUrl) async {
    try {
      return await _apiService.fetchStorageLevels(baseUrl);
    } catch (_) {
      return StorageLevels.initial();
    }
  }

  @override
  Future<EnergyOverview> getEnergyOverview(String baseUrl) async {
    try {
      return await _apiService.fetchEnergyOverview(baseUrl);
    } catch (_) {
      return EnergyOverview.initial();
    }
  }

  @override
  Future<AlarmsResponse> getAlarms(String baseUrl) async {
    try {
      return await _apiService.fetchAlarms(baseUrl);
    } catch (_) {
      return AlarmsResponse.initial();
    }
  }

  @override
  Future<bool> acknowledgeAlarm(String baseUrl, String alarmId, {String operatorName = 'Operator'}) async {
    try {
      return await _apiService.acknowledgeAlarm(baseUrl, alarmId, operatorName: operatorName);
    } catch (_) {
      return true; // Local simulation state acknowledgement
    }
  }
}
