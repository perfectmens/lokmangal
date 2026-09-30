import '../models/telemetry_data.dart';

abstract class TelemetryRepository {
  Future<PlantTelemetry> getPlantTelemetry();
  Future<EnergyAnalytics> getEnergyAnalytics();
  Future<void> refreshAllData();
}

class TelemetryRepositoryImpl implements TelemetryRepository {
  PlantTelemetry _cachedTelemetry = PlantTelemetry.initial();
  EnergyAnalytics _cachedAnalytics = EnergyAnalytics.initial();

  @override
  Future<PlantTelemetry> getPlantTelemetry() async {
    // In production, queries /api/v1/telemetry/overview defined in api-mapping.yaml
    await Future.delayed(const Duration(milliseconds: 300));
    return _cachedTelemetry;
  }

  @override
  Future<EnergyAnalytics> getEnergyAnalytics() async {
    // In production, queries /api/v1/analytics/energy-production defined in api-mapping.yaml
    await Future.delayed(const Duration(milliseconds: 300));
    return _cachedAnalytics;
  }

  @override
  Future<void> refreshAllData() async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Simulate real-time sensor fluctuation
    _cachedTelemetry = PlantTelemetry(
      plantStatus: 'OPTIMAL RUNNING',
      caneCrushedTodayTons: _cachedTelemetry.caneCrushedTodayTons + 12.4,
      millingEfficiencyPercent: 96.5,
      boilerPressureBar: 64.4,
      steamTemperatureCelsius: 486.2,
      distillationRateLpd: 125400.0,
      fermentationStatus: 'ACTIVE REACTION (BATCH 4)',
    );

    _cachedAnalytics = EnergyAnalytics(
      powerGeneratedMw: 32.8,
      gridExportMw: 25.1,
      internalConsumptionMw: 7.7,
      turbogeneratorRpm: 5410,
      co2EmissionsOffsetTons: 144.2,
      hourlyTrend: _cachedAnalytics.hourlyTrend,
    );
  }
}
