class PlantTelemetry {
  final String plantStatus; // e.g. "OPTIMAL RUNNING"
  final double caneCrushedTodayTons;
  final double millingEfficiencyPercent;
  final double boilerPressureBar;
  final double steamTemperatureCelsius;
  final double distillationRateLpd;
  final String fermentationStatus;

  const PlantTelemetry({
    required this.plantStatus,
    required this.caneCrushedTodayTons,
    required this.millingEfficiencyPercent,
    required this.boilerPressureBar,
    required this.steamTemperatureCelsius,
    required this.distillationRateLpd,
    required this.fermentationStatus,
  });

  factory PlantTelemetry.initial() {
    return const PlantTelemetry(
      plantStatus: 'OPTIMAL RUNNING',
      caneCrushedTodayTons: 4850.5,
      millingEfficiencyPercent: 96.4,
      boilerPressureBar: 64.2,
      steamTemperatureCelsius: 485.0,
      distillationRateLpd: 125000.0,
      fermentationStatus: 'ACTIVE REACTION (BATCH 4)',
    );
  }
}

class HourlyEnergyPoint {
  final String hour;
  final double generationMw;
  final double exportMw;

  const HourlyEnergyPoint({
    required this.hour,
    required this.generationMw,
    required this.exportMw,
  });
}

class EnergyAnalytics {
  final double powerGeneratedMw;
  final double gridExportMw;
  final double internalConsumptionMw;
  final int turbogeneratorRpm;
  final double co2EmissionsOffsetTons;
  final List<HourlyEnergyPoint> hourlyTrend;

  const EnergyAnalytics({
    required this.powerGeneratedMw,
    required this.gridExportMw,
    required this.internalConsumptionMw,
    required this.turbogeneratorRpm,
    required this.co2EmissionsOffsetTons,
    required this.hourlyTrend,
  });

  factory EnergyAnalytics.initial() {
    return const EnergyAnalytics(
      powerGeneratedMw: 32.5,
      gridExportMw: 24.8,
      internalConsumptionMw: 7.7,
      turbogeneratorRpm: 5400,
      co2EmissionsOffsetTons: 142.6,
      hourlyTrend: [
        HourlyEnergyPoint(hour: '06:00', generationMw: 28.0, exportMw: 21.0),
        HourlyEnergyPoint(hour: '08:00', generationMw: 30.5, exportMw: 23.2),
        HourlyEnergyPoint(hour: '10:00', generationMw: 32.5, exportMw: 24.8),
        HourlyEnergyPoint(hour: '12:00', generationMw: 33.0, exportMw: 25.1),
        HourlyEnergyPoint(hour: '14:00', generationMw: 32.2, exportMw: 24.5),
        HourlyEnergyPoint(hour: '16:00', generationMw: 31.8, exportMw: 24.0),
      ],
    );
  }
}
