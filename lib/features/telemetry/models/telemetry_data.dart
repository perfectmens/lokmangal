enum PowderMakerStatus {
  systemReady('System Ready', 'SYSTEM_READY'),
  mixing('Mixing', 'MIXING'),
  crystallization('Crystallization', 'CRYSTALLIZATION'),
  powderMaking('Powder Making', 'POWDER_MAKING'),
  discharge('Discharge', 'DISCHARGE');

  final String displayName;
  final String code;

  const PowderMakerStatus(this.displayName, this.code);

  static PowderMakerStatus fromString(String val) {
    final lower = val.toLowerCase().replaceAll('_', '').replaceAll(' ', '');
    for (final s in values) {
      final sLower = s.name.toLowerCase().replaceAll('_', '');
      if (lower.contains(sLower) || sLower.contains(lower)) {
        return s;
      }
    }
    return PowderMakerStatus.systemReady;
  }
}

class PlantInfo {
  final String name;
  final List<String> products;
  final String activeProduct;

  const PlantInfo({
    required this.name,
    required this.products,
    required this.activeProduct,
  });

  factory PlantInfo.fromJson(Map<String, dynamic> json) {
    return PlantInfo(
      name: json['name'] as String? ?? 'Corelife Wholefoods',
      products: (json['products'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['Jaggery', 'Liquid Sugars'],
      activeProduct: json['active_product'] as String? ?? 'Jaggery Powder',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'products': products,
        'active_product': activeProduct,
      };
}

class ProductionMetrics {
  final int shiftNumber;
  final int shiftDurationHours;
  final int shiftElapsedSeconds;
  final double hourlyTargetKg;
  final double hourlyActualKg;
  final double shiftTargetKg;
  final double shiftActualKg;
  final double plantCapacityTpd;
  final double dailyActualKg;

  const ProductionMetrics({
    required this.shiftNumber,
    required this.shiftDurationHours,
    required this.shiftElapsedSeconds,
    required this.hourlyTargetKg,
    required this.hourlyActualKg,
    required this.shiftTargetKg,
    required this.shiftActualKg,
    required this.plantCapacityTpd,
    required this.dailyActualKg,
  });

  factory ProductionMetrics.fromJson(Map<String, dynamic> json) {
    return ProductionMetrics(
      shiftNumber: json['shift_number'] as int? ?? 1,
      shiftDurationHours: json['shift_duration_hours'] as int? ?? 8,
      shiftElapsedSeconds: json['shift_elapsed_seconds'] as int? ?? 14400,
      hourlyTargetKg: (json['hourly_target_kg'] as num?)?.toDouble() ?? 833.0,
      hourlyActualKg: (json['hourly_actual_kg'] as num?)?.toDouble() ?? 795.0,
      shiftTargetKg: (json['shift_target_kg'] as num?)?.toDouble() ?? 6667.0,
      shiftActualKg: (json['shift_actual_kg'] as num?)?.toDouble() ?? 3410.0,
      plantCapacityTpd: (json['plant_capacity_tpd'] as num?)?.toDouble() ?? 20.0,
      dailyActualKg: (json['daily_actual_kg'] as num?)?.toDouble() ?? 8920.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'shift_number': shiftNumber,
        'shift_duration_hours': shiftDurationHours,
        'shift_elapsed_seconds': shiftElapsedSeconds,
        'hourly_target_kg': hourlyTargetKg,
        'hourly_actual_kg': hourlyActualKg,
        'shift_target_kg': shiftTargetKg,
        'shift_actual_kg': shiftActualKg,
        'plant_capacity_tpd': plantCapacityTpd,
        'daily_actual_kg': dailyActualKg,
      };
}

class PowderMakerData {
  final PowderMakerStatus status;
  final double batchCapacityKg;
  final double batchCurrentKg;
  final int batchCycleSeconds;
  final int completedBatchesToday;

  const PowderMakerData({
    required this.status,
    required this.batchCapacityKg,
    required this.batchCurrentKg,
    required this.batchCycleSeconds,
    required this.completedBatchesToday,
  });

  factory PowderMakerData.fromJson(Map<String, dynamic> json) {
    return PowderMakerData(
      status: PowderMakerStatus.fromString(json['status'] as String? ?? 'Crystallization'),
      batchCapacityKg: (json['batch_capacity_kg'] as num?)?.toDouble() ?? 500.0,
      batchCurrentKg: (json['batch_current_kg'] as num?)?.toDouble() ?? 482.5,
      batchCycleSeconds: json['batch_cycle_seconds'] as int? ?? 185,
      completedBatchesToday: json['completed_batches_today'] as int? ?? 18,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status.code,
        'batch_capacity_kg': batchCapacityKg,
        'batch_current_kg': batchCurrentKg,
        'batch_cycle_seconds': batchCycleSeconds,
        'completed_batches_today': completedBatchesToday,
      };
}

class StorageMetrics {
  final double silo1Kg;
  final double silo2Kg;
  final double combinedSilosKg;
  final double combinedMaxCapacityKg;
  final double syrupTankKg;
  final double syrupTankMaxKg;
  final bool loadCellsHealthy;

  const StorageMetrics({
    required this.silo1Kg,
    required this.silo2Kg,
    required this.combinedSilosKg,
    required this.combinedMaxCapacityKg,
    required this.syrupTankKg,
    required this.syrupTankMaxKg,
    required this.loadCellsHealthy,
  });

  factory StorageMetrics.fromJson(Map<String, dynamic> json) {
    final s1 = (json['silo_1_kg'] as num?)?.toDouble() ?? 1820.0;
    final s2 = (json['silo_2_kg'] as num?)?.toDouble() ?? 2150.0;
    final combined = (json['combined_silos_kg'] as num?)?.toDouble() ?? (s1 + s2);

    return StorageMetrics(
      silo1Kg: s1,
      silo2Kg: s2,
      combinedSilosKg: combined,
      combinedMaxCapacityKg: (json['combined_max_capacity_kg'] as num?)?.toDouble() ?? 5000.0,
      syrupTankKg: (json['syrup_tank_kg'] as num?)?.toDouble() ?? 3280.0,
      syrupTankMaxKg: (json['syrup_tank_max_kg'] as num?)?.toDouble() ?? 5000.0,
      loadCellsHealthy: json['load_cells_healthy'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'silo_1_kg': silo1Kg,
        'silo_2_kg': silo2Kg,
        'combined_silos_kg': combinedSilosKg,
        'combined_max_capacity_kg': combinedMaxCapacityKg,
        'syrup_tank_kg': syrupTankKg,
        'syrup_tank_max_kg': syrupTankMaxKg,
        'load_cells_healthy': loadCellsHealthy,
      };
}

class ElectricityMetrics {
  final double currentPowerKw;
  final double hourlyKwh;
  final double hourlyMaxKwh;
  final double shiftKwh;
  final double shiftMaxKwh;
  final double dailyKwh;
  final double dailyMaxKwh;
  final double specificEnergyConsumption;

  const ElectricityMetrics({
    required this.currentPowerKw,
    required this.hourlyKwh,
    required this.hourlyMaxKwh,
    required this.shiftKwh,
    required this.shiftMaxKwh,
    required this.dailyKwh,
    required this.dailyMaxKwh,
    required this.specificEnergyConsumption,
  });

  factory ElectricityMetrics.fromJson(Map<String, dynamic> json) {
    return ElectricityMetrics(
      currentPowerKw: (json['current_power_kw'] as num?)?.toDouble() ?? 98.4,
      hourlyKwh: (json['hourly_kwh'] as num?)?.toDouble() ?? 112.3,
      hourlyMaxKwh: (json['hourly_max_kwh'] as num?)?.toDouble() ?? 134.0,
      shiftKwh: (json['shift_kwh'] as num?)?.toDouble() ?? 612.0,
      shiftMaxKwh: (json['shift_max_kwh'] as num?)?.toDouble() ?? 1074.0,
      dailyKwh: (json['daily_kwh'] as num?)?.toDouble() ?? 1840.5,
      dailyMaxKwh: (json['daily_max_kwh'] as num?)?.toDouble() ?? 3221.0,
      specificEnergyConsumption: (json['sec_kwh_per_kg'] as num?)?.toDouble() ?? 0.179,
    );
  }

  Map<String, dynamic> toJson() => {
        'current_power_kw': currentPowerKw,
        'hourly_kwh': hourlyKwh,
        'hourly_max_kwh': hourlyMaxKwh,
        'shift_kwh': shiftKwh,
        'shift_max_kwh': shiftMaxKwh,
        'daily_kwh': dailyKwh,
        'daily_max_kwh': dailyMaxKwh,
        'sec_kwh_per_kg': specificEnergyConsumption,
      };
}

class PlantTelemetry {
  final DateTime timestamp;
  final PlantInfo plant;
  final ProductionMetrics production;
  final PowderMakerData powderMaker;
  final StorageMetrics storage;
  final ElectricityMetrics electricity;

  const PlantTelemetry({
    required this.timestamp,
    required this.plant,
    required this.production,
    required this.powderMaker,
    required this.storage,
    required this.electricity,
  });

  factory PlantTelemetry.fromJson(Map<String, dynamic> json) {
    return PlantTelemetry(
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      plant: PlantInfo.fromJson(json['plant'] as Map<String, dynamic>? ?? {}),
      production: ProductionMetrics.fromJson(json['production'] as Map<String, dynamic>? ?? {}),
      powderMaker: PowderMakerData.fromJson(json['powder_maker'] as Map<String, dynamic>? ?? {}),
      storage: StorageMetrics.fromJson(json['storage'] as Map<String, dynamic>? ?? {}),
      electricity: ElectricityMetrics.fromJson(json['electricity'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'plant': plant.toJson(),
        'production': production.toJson(),
        'powder_maker': powderMaker.toJson(),
        'storage': storage.toJson(),
        'electricity': electricity.toJson(),
      };

  factory PlantTelemetry.initialMock() {
    return PlantTelemetry(
      timestamp: DateTime.now(),
      plant: const PlantInfo(
        name: 'Corelife Wholefoods',
        products: ['Jaggery', 'Liquid Sugars'],
        activeProduct: 'Jaggery Powder',
      ),
      production: const ProductionMetrics(
        shiftNumber: 1,
        shiftDurationHours: 8,
        shiftElapsedSeconds: 15420,
        hourlyTargetKg: 833.0,
        hourlyActualKg: 795.0,
        shiftTargetKg: 6667.0,
        shiftActualKg: 3410.0,
        plantCapacityTpd: 20.0,
        dailyActualKg: 8920.0,
      ),
      powderMaker: const PowderMakerData(
        status: PowderMakerStatus.crystallization,
        batchCapacityKg: 500.0,
        batchCurrentKg: 482.5,
        batchCycleSeconds: 185,
        completedBatchesToday: 18,
      ),
      storage: const StorageMetrics(
        silo1Kg: 1820.0,
        silo2Kg: 2150.0,
        combinedSilosKg: 3970.0,
        combinedMaxCapacityKg: 5000.0,
        syrupTankKg: 3280.0,
        syrupTankMaxKg: 5000.0,
        loadCellsHealthy: true,
      ),
      electricity: const ElectricityMetrics(
        currentPowerKw: 98.4,
        hourlyKwh: 112.3,
        hourlyMaxKwh: 134.0,
        shiftKwh: 612.0,
        shiftMaxKwh: 1074.0,
        dailyKwh: 1840.5,
        dailyMaxKwh: 3221.0,
        specificEnergyConsumption: 0.179,
      ),
    );
  }
}
