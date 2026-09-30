class PlantHealthBreakdown {
  final double production;
  final double equipment;
  final double energy;
  final double storage;
  final double connectivity;

  const PlantHealthBreakdown({
    required this.production,
    required this.equipment,
    required this.energy,
    required this.storage,
    required this.connectivity,
  });

  factory PlantHealthBreakdown.fromJson(Map<String, dynamic> json) {
    double parseVal(dynamic v, double fallback) {
      if (v is num) return v.toDouble();
      if (v is Map && v['score'] is num) return (v['score'] as num).toDouble();
      return fallback;
    }

    return PlantHealthBreakdown(
      production: parseVal(json['production'], 30.0),
      equipment: parseVal(json['equipment'], 28.0),
      energy: parseVal(json['energy'], 14.0),
      storage: parseVal(json['storage'], 14.0),
      connectivity: parseVal(json['connectivity'], 10.0),
    );
  }

  factory PlantHealthBreakdown.initial() {
    return const PlantHealthBreakdown(
      production: 29.0,
      equipment: 28.0,
      energy: 14.0,
      storage: 14.0,
      connectivity: 10.0,
    );
  }
}

class PlantStatus {
  final String plantId;
  final String name;
  final String location;
  final List<String> businessUnits;
  final String connectionStatus; // 'ONLINE' or 'OFFLINE'
  final double healthScore;
  final PlantHealthBreakdown healthBreakdown;

  const PlantStatus({
    required this.plantId,
    required this.name,
    required this.location,
    required this.businessUnits,
    required this.connectionStatus,
    required this.healthScore,
    required this.healthBreakdown,
  });

  bool get isOnline => connectionStatus.toUpperCase() == 'ONLINE';

  factory PlantStatus.fromJson(Map<String, dynamic> json) {
    return PlantStatus(
      plantId: json['plantId'] ?? 'CORELIFE-01',
      name: json['name'] ?? 'Corelife Wholefoods',
      location: json['location'] ?? 'Jaggery & Liquid Sugars',
      businessUnits: (json['businessUnits'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['Jaggery', 'Liquid Sugars'],
      connectionStatus: json['connectionStatus'] ?? 'ONLINE',
      healthScore: (json['healthScore'] as num?)?.toDouble() ?? 94.0,
      healthBreakdown: json['healthBreakdown'] != null
          ? PlantHealthBreakdown.fromJson(json['healthBreakdown'])
          : PlantHealthBreakdown.initial(),
    );
  }

  factory PlantStatus.initial() {
    return PlantStatus(
      plantId: 'CORELIFE-01',
      name: 'Corelife Wholefoods',
      location: 'Jaggery & Liquid Sugars',
      businessUnits: const ['Jaggery', 'Liquid Sugars'],
      connectionStatus: 'ONLINE',
      healthScore: 94.0,
      healthBreakdown: PlantHealthBreakdown.initial(),
    );
  }
}

class PlantEvent {
  final String id;
  final String message;
  final String category; // 'CRITICAL', 'WARNING', 'POSITIVE', 'INFO'
  final int priority;
  final String timestamp;

  const PlantEvent({
    required this.id,
    required this.message,
    required this.category,
    required this.priority,
    required this.timestamp,
  });

  factory PlantEvent.fromJson(Map<String, dynamic> json) {
    return PlantEvent(
      id: json['id'] ?? '',
      message: json['message'] ?? '',
      category: json['category'] ?? 'INFO',
      priority: (json['priority'] as num?)?.toInt() ?? 10,
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class ProductionSummary {
  final double todayKg;
  final double dailyTargetKg;
  final double dailyTargetPercent;
  final double hourlyRateKgH;
  final double hourlyTargetKgH;
  final double shiftKg;
  final double shiftTargetKg;
  final double energyKwh;
  final double energyBudgetKwh;
  final int currentShift;

  const ProductionSummary({
    required this.todayKg,
    required this.dailyTargetKg,
    required this.dailyTargetPercent,
    required this.hourlyRateKgH,
    required this.hourlyTargetKgH,
    required this.shiftKg,
    required this.shiftTargetKg,
    required this.energyKwh,
    required this.energyBudgetKwh,
    required this.currentShift,
  });

  factory ProductionSummary.fromJson(Map<String, dynamic> json) {
    return ProductionSummary(
      todayKg: (json['todayKg'] as num?)?.toDouble() ?? 15420.0,
      dailyTargetKg: (json['dailyTargetKg'] as num?)?.toDouble() ?? 20000.0,
      dailyTargetPercent: (json['dailyTargetPercent'] as num?)?.toDouble() ?? 77.1,
      hourlyRateKgH: (json['hourlyRateKgH'] as num?)?.toDouble() ?? 812.0,
      hourlyTargetKgH: (json['hourlyTargetKgH'] as num?)?.toDouble() ?? 833.0,
      shiftKg: (json['shiftKg'] as num?)?.toDouble() ?? 4060.0,
      shiftTargetKg: (json['shiftTargetKg'] as num?)?.toDouble() ?? 6667.0,
      energyKwh: (json['energyKwh'] as num?)?.toDouble() ?? 2486.0,
      energyBudgetKwh: (json['energyBudgetKwh'] as num?)?.toDouble() ?? 3221.0,
      currentShift: (json['currentShift'] as num?)?.toInt() ?? 2,
    );
  }

  factory ProductionSummary.initial() {
    return const ProductionSummary(
      todayKg: 15420.0,
      dailyTargetKg: 20000.0,
      dailyTargetPercent: 77.1,
      hourlyRateKgH: 812.0,
      hourlyTargetKgH: 833.0,
      shiftKg: 4060.0,
      shiftTargetKg: 6667.0,
      energyKwh: 2486.0,
      energyBudgetKwh: 3221.0,
      currentShift: 2,
    );
  }
}

class BatchRecord {
  final String batchId;
  final int batchNumber;
  final double weightKg;
  final double targetWeightKg;
  final String startTime;
  final String endTime;
  final double durationMinutes;
  final String status;

  const BatchRecord({
    required this.batchId,
    required this.batchNumber,
    required this.weightKg,
    required this.targetWeightKg,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.status,
  });

  factory BatchRecord.fromJson(Map<String, dynamic> json) {
    return BatchRecord(
      batchId: json['batchId'] ?? '',
      batchNumber: (json['batchNumber'] as num?)?.toInt() ?? 0,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
      targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble() ?? 500.0,
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      durationMinutes: (json['durationMinutes'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'COMPLETED',
    );
  }
}

class PowderMakerState {
  final String currentState;
  final String stateDisplayName;
  final int batchNumber;
  final double currentWeightKg;
  final double targetWeightKg;
  final double progressPercent;
  final double elapsedMinutes;
  final double targetCycleMinutes;
  final double currentRateKgH;
  final String equipmentStatus;

  const PowderMakerState({
    required this.currentState,
    required this.stateDisplayName,
    required this.batchNumber,
    required this.currentWeightKg,
    required this.targetWeightKg,
    required this.progressPercent,
    required this.elapsedMinutes,
    required this.targetCycleMinutes,
    required this.currentRateKgH,
    required this.equipmentStatus,
  });

  factory PowderMakerState.fromJson(Map<String, dynamic> json) {
    return PowderMakerState(
      currentState: json['currentState'] ?? 'POWDER_MAKING',
      stateDisplayName: json['stateDisplayName'] ?? 'Powder Making',
      batchNumber: (json['batchNumber'] as num?)?.toInt() ?? 128,
      currentWeightKg: (json['currentWeightKg'] as num?)?.toDouble() ?? 370.0,
      targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble() ?? 500.0,
      progressPercent: (json['progressPercent'] as num?)?.toDouble() ?? 74.0,
      elapsedMinutes: (json['elapsedMinutes'] as num?)?.toDouble() ?? 27.0,
      targetCycleMinutes: (json['targetCycleMinutes'] as num?)?.toDouble() ?? 36.0,
      currentRateKgH: (json['currentRateKgH'] as num?)?.toDouble() ?? 824.0,
      equipmentStatus: json['equipmentStatus'] ?? 'RUNNING',
    );
  }

  factory PowderMakerState.initial() {
    return const PowderMakerState(
      currentState: 'POWDER_MAKING',
      stateDisplayName: 'Powder Making',
      batchNumber: 128,
      currentWeightKg: 370.0,
      targetWeightKg: 500.0,
      progressPercent: 74.0,
      elapsedMinutes: 27.0,
      targetCycleMinutes: 36.0,
      currentRateKgH: 824.0,
      equipmentStatus: 'RUNNING',
    );
  }
}

class SiloData {
  final double? silo1Kg;
  final double? silo2Kg;
  final double totalKg;
  final double capacityKg;
  final double percent;
  final String status;

  const SiloData({
    this.silo1Kg,
    this.silo2Kg,
    required this.totalKg,
    required this.capacityKg,
    required this.percent,
    required this.status,
  });

  factory SiloData.fromJson(Map<String, dynamic> json) {
    return SiloData(
      silo1Kg: (json['silo1Kg'] as num?)?.toDouble(),
      silo2Kg: (json['silo2Kg'] as num?)?.toDouble(),
      totalKg: (json['totalKg'] as num?)?.toDouble() ?? 0.0,
      capacityKg: (json['capacityKg'] as num?)?.toDouble() ?? 5000.0,
      percent: (json['percent'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'NORMAL',
    );
  }
}

class StorageLevels {
  final SiloData combinedSilo;
  final SiloData syrupTank;
  final String validationStatus;

  const StorageLevels({
    required this.combinedSilo,
    required this.syrupTank,
    required this.validationStatus,
  });

  factory StorageLevels.fromJson(Map<String, dynamic> json) {
    return StorageLevels(
      combinedSilo: json['combinedSilo'] != null
          ? SiloData.fromJson(json['combinedSilo'])
          : const SiloData(
              silo1Kg: 1910.0,
              silo2Kg: 1910.0,
              totalKg: 3820.0,
              capacityKg: 5000.0,
              percent: 76.4,
              status: 'NORMAL',
            ),
      syrupTank: json['syrupTank'] != null
          ? SiloData.fromJson(json['syrupTank'])
          : const SiloData(
              totalKg: 2940.0,
              capacityKg: 5000.0,
              percent: 58.8,
              status: 'NORMAL',
            ),
      validationStatus: json['validationStatus'] ?? 'VALID',
    );
  }

  factory StorageLevels.initial() {
    return const StorageLevels(
      combinedSilo: SiloData(
        silo1Kg: 1910.0,
        silo2Kg: 1910.0,
        totalKg: 3820.0,
        capacityKg: 5000.0,
        percent: 76.4,
        status: 'NORMAL',
      ),
      syrupTank: SiloData(
        totalKg: 2940.0,
        capacityKg: 5000.0,
        percent: 58.8,
        status: 'NORMAL',
      ),
      validationStatus: 'VALID',
    );
  }
}

class HourlyTrendPoint {
  final String hour;
  final double kwh;

  const HourlyTrendPoint({required this.hour, required this.kwh});

  factory HourlyTrendPoint.fromJson(Map<String, dynamic> json) {
    return HourlyTrendPoint(
      hour: json['hour'] ?? '',
      kwh: (json['kwh'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class EnergyOverview {
  final double livePowerKw;
  final double hourlyKwh;
  final double hourlyLimitKwh;
  final double shiftKwh;
  final double shiftLimitKwh;
  final double dailyKwh;
  final double dailyLimitKwh;
  final double efficiencyKwhPerKg;
  final List<HourlyTrendPoint> hourlyTrend;

  const EnergyOverview({
    required this.livePowerKw,
    required this.hourlyKwh,
    required this.hourlyLimitKwh,
    required this.shiftKwh,
    required this.shiftLimitKwh,
    required this.dailyKwh,
    required this.dailyLimitKwh,
    required this.efficiencyKwhPerKg,
    required this.hourlyTrend,
  });

  factory EnergyOverview.fromJson(Map<String, dynamic> json) {
    return EnergyOverview(
      livePowerKw: (json['livePowerKw'] as num?)?.toDouble() ?? 103.0,
      hourlyKwh: (json['hourlyKwh'] as num?)?.toDouble() ?? 103.0,
      hourlyLimitKwh: (json['hourlyLimitKwh'] as num?)?.toDouble() ?? 134.0,
      shiftKwh: (json['shiftKwh'] as num?)?.toDouble() ?? 742.0,
      shiftLimitKwh: (json['shiftLimitKwh'] as num?)?.toDouble() ?? 1074.0,
      dailyKwh: (json['dailyKwh'] as num?)?.toDouble() ?? 2486.0,
      dailyLimitKwh: (json['dailyLimitKwh'] as num?)?.toDouble() ?? 3221.0,
      efficiencyKwhPerKg: (json['efficiencyKwhPerKg'] as num?)?.toDouble() ?? 0.16,
      hourlyTrend: (json['hourlyTrend'] as List<dynamic>?)
              ?.map((e) => HourlyTrendPoint.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory EnergyOverview.initial() {
    return const EnergyOverview(
      livePowerKw: 103.0,
      hourlyKwh: 103.0,
      hourlyLimitKwh: 134.0,
      shiftKwh: 742.0,
      shiftLimitKwh: 1074.0,
      dailyKwh: 2486.0,
      dailyLimitKwh: 3221.0,
      efficiencyKwhPerKg: 0.16,
      hourlyTrend: [
        HourlyTrendPoint(hour: '06:00', kwh: 98.0),
        HourlyTrendPoint(hour: '08:00', kwh: 102.0),
        HourlyTrendPoint(hour: '10:00', kwh: 104.0),
        HourlyTrendPoint(hour: '12:00', kwh: 103.0),
        HourlyTrendPoint(hour: '14:00', kwh: 105.0),
      ],
    );
  }
}

class AlarmItem {
  final String id;
  final String code;
  final String title;
  final String equipment;
  final String severity; // 'CRITICAL', 'WARNING', 'INFO'
  final String status; // 'TRIGGERED', 'ACTIVE', 'ACKNOWLEDGED', 'CLEARED'
  final String triggeredAt;
  final String? acknowledgedAt;
  final String? acknowledgedBy;
  final String? value;
  final String? limit;

  const AlarmItem({
    required this.id,
    required this.code,
    required this.title,
    required this.equipment,
    required this.severity,
    required this.status,
    required this.triggeredAt,
    this.acknowledgedAt,
    this.acknowledgedBy,
    this.value,
    this.limit,
  });

  bool get isCritical => severity.toUpperCase() == 'CRITICAL';
  bool get isAcknowledged => status.toUpperCase() == 'ACKNOWLEDGED';

  factory AlarmItem.fromJson(Map<String, dynamic> json) {
    return AlarmItem(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      equipment: json['equipment'] ?? '',
      severity: json['severity'] ?? 'WARNING',
      status: json['status'] ?? 'ACTIVE',
      triggeredAt: json['triggered_at'] ?? json['triggeredAt'] ?? '',
      acknowledgedAt: json['acknowledged_at'] ?? json['acknowledgedAt'],
      acknowledgedBy: json['acknowledged_by'] ?? json['acknowledgedBy'],
      value: json['value'],
      limit: json['limit'],
    );
  }
}

class AlarmsResponse {
  final int criticalCount;
  final int warningCount;
  final List<AlarmItem> alarms;

  const AlarmsResponse({
    required this.criticalCount,
    required this.warningCount,
    required this.alarms,
  });

  factory AlarmsResponse.fromJson(Map<String, dynamic> json) {
    return AlarmsResponse(
      criticalCount: (json['criticalCount'] as num?)?.toInt() ?? 0,
      warningCount: (json['warningCount'] as num?)?.toInt() ?? 0,
      alarms: (json['alarms'] as List<dynamic>?)
              ?.map((e) => AlarmItem.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory AlarmsResponse.initial() {
    return const AlarmsResponse(
      criticalCount: 1,
      warningCount: 2,
      alarms: [
        AlarmItem(
          id: 'ALM-001',
          code: 'PM_FAULT',
          title: 'Powder Maker Motor Over-Torque Warning',
          equipment: 'Powder Maker #1',
          severity: 'CRITICAL',
          status: 'ACTIVE',
          triggeredAt: '14:08',
          value: 'Torque: 94%',
          limit: 'Max: 90%',
        ),
        AlarmItem(
          id: 'ALM-002',
          code: 'RATE_LOW',
          title: 'Production Below Hourly Target',
          equipment: 'Main Line',
          severity: 'WARNING',
          status: 'ACTIVE',
          triggeredAt: '13:45',
          value: '812 kg/h',
          limit: 'Target: 833 kg/h',
        ),
        AlarmItem(
          id: 'ALM-003',
          code: 'SILO_HIGH',
          title: 'Combined Silo Storage Approaching 80%',
          equipment: 'Combined Silo',
          severity: 'WARNING',
          status: 'ACTIVE',
          triggeredAt: '12:30',
          value: '3,820 kg',
          limit: 'Max: 5,000 kg',
        ),
      ],
    );
  }
}
