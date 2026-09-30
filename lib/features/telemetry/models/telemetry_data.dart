enum PowderMakerStatus {
  systemReady('System Ready', 'System_Ready'),
  mixing('Mixing', 'Mixing'),
  crystallization('Crystallization', 'Crystallization'),
  powderMaking('Powder Making', 'Powder_making'),
  discharge('Discharge', 'Discharge');

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
  final String product;
  final double plantCapacityTpd;
  final int shiftsPerDay;
  final double shiftTargetKg;
  final int shiftDurationHours;
  final double hourlyTargetKg;
  final int currentShift;
  final double hourlyActualKg;
  final double shiftActualKg;
  final double dailyActualKg;

  const ProductionMetrics({
    required this.product,
    required this.plantCapacityTpd,
    required this.shiftsPerDay,
    required this.shiftTargetKg,
    required this.shiftDurationHours,
    required this.hourlyTargetKg,
    required this.currentShift,
    required this.hourlyActualKg,
    required this.shiftActualKg,
    required this.dailyActualKg,
  });

  factory ProductionMetrics.fromJson(Map<String, dynamic> json) {
    return ProductionMetrics(
      product: json['product'] as String? ?? 'Jaggery Powder',
      plantCapacityTpd: (json['plant_capacity_tpd'] as num?)?.toDouble() ?? 20.0,
      shiftsPerDay: json['shifts_per_day'] as int? ?? 3,
      shiftTargetKg: (json['shift_target_kg'] as num?)?.toDouble() ?? 6667.0,
      shiftDurationHours: json['shift_duration_hours'] as int? ?? 8,
      hourlyTargetKg: (json['hourly_target_kg'] as num?)?.toDouble() ?? 833.0,
      currentShift: json['current_shift'] as int? ?? 1,
      hourlyActualKg: (json['hourly_actual_kg'] as num?)?.toDouble() ?? 795.0,
      shiftActualKg: (json['shift_actual_kg'] as num?)?.toDouble() ?? 3410.0,
      dailyActualKg: (json['daily_actual_kg'] as num?)?.toDouble() ?? 8920.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'product': product,
        'plant_capacity_tpd': plantCapacityTpd,
        'shifts_per_day': shiftsPerDay,
        'shift_target_kg': shiftTargetKg,
        'shift_duration_hours': shiftDurationHours,
        'hourly_target_kg': hourlyTargetKg,
        'current_shift': currentShift,
        'hourly_actual_kg': hourlyActualKg,
        'shift_actual_kg': shiftActualKg,
        'daily_actual_kg': dailyActualKg,
      };
}

class PowderMakerData {
  final double batchCapacityKg;
  final PowderMakerStatus status;
  final double batchCurrentKg;
  final int batchCycleSeconds;

  const PowderMakerData({
    required this.batchCapacityKg,
    required this.status,
    required this.batchCurrentKg,
    required this.batchCycleSeconds,
  });

  factory PowderMakerData.fromJson(Map<String, dynamic> json) {
    return PowderMakerData(
      batchCapacityKg: (json['batch_capacity_kg'] as num?)?.toDouble() ?? 500.0,
      status: PowderMakerStatus.fromString(json['status'] as String? ?? 'Crystallization'),
      batchCurrentKg: (json['batch_current_kg'] as num?)?.toDouble() ?? 482.5,
      batchCycleSeconds: json['batch_cycle_seconds'] as int? ?? 185,
    );
  }

  Map<String, dynamic> toJson() => {
        'batch_capacity_kg': batchCapacityKg,
        'status': status.code,
        'batch_current_kg': batchCurrentKg,
        'batch_cycle_seconds': batchCycleSeconds,
      };
}

class StorageMetrics {
  // Each silo holds max 5,000 kg. They alternate: Silo 1 fills first, then Silo 2.
  final int numberOfSilos;
  final double siloMaxKg;          // per-silo capacity: 5,000 kg
  final double silo1Kg;            // current weight in Silo 1
  final double silo2Kg;            // current weight in Silo 2
  final double syrupTankMaxKg;
  final double syrupTankKg;

  const StorageMetrics({
    required this.numberOfSilos,
    required this.siloMaxKg,
    required this.silo1Kg,
    required this.silo2Kg,
    required this.syrupTankMaxKg,
    required this.syrupTankKg,
  });

  /// Combined weight across both silos
  double get combinedSilosKg => silo1Kg + silo2Kg;

  /// Total combined max (5,000 × 2 = 10,000 kg)
  double get combinedMaxCapacityKg => siloMaxKg * numberOfSilos;

  /// Which silo is currently active (filling)?
  /// Silo 1 is active until full, then Silo 2 takes over.
  int get activeSiloIndex => silo1Kg < siloMaxKg ? 1 : 2;

  factory StorageMetrics.fromJson(Map<String, dynamic> json) {
    final siloMax = (json['silo_max_kg'] as num?)?.toDouble() ?? 5000.0;
    // Support both new per-silo keys and legacy combined_silos_kg
    final silo1 = (json['silo1_kg'] as num?)?.toDouble()
        ?? (json['combined_silos_kg'] as num?)?.toDouble() ?? 3970.0;
    final silo2 = (json['silo2_kg'] as num?)?.toDouble() ?? 0.0;
    return StorageMetrics(
      numberOfSilos: json['number_of_silos'] as int? ?? 2,
      siloMaxKg: siloMax,
      silo1Kg: silo1,
      silo2Kg: silo2,
      syrupTankMaxKg: (json['syrup_tank_max_kg'] as num?)?.toDouble() ?? 5000.0,
      syrupTankKg: (json['syrup_tank_kg'] as num?)?.toDouble() ?? 3280.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'number_of_silos': numberOfSilos,
        'silo_max_kg': siloMaxKg,
        'silo1_kg': silo1Kg,
        'silo2_kg': silo2Kg,
        'syrup_tank_max_kg': syrupTankMaxKg,
        'syrup_tank_kg': syrupTankKg,
      };
}

class ElectricityMetrics {
  final double hourlyMaxKwh;
  final double hourlyKwh;
  final double shiftMaxKwh;
  final double shiftKwh;
  final double dailyMaxKwh;
  final double dailyKwh;

  const ElectricityMetrics({
    required this.hourlyMaxKwh,
    required this.hourlyKwh,
    required this.shiftMaxKwh,
    required this.shiftKwh,
    required this.dailyMaxKwh,
    required this.dailyKwh,
  });

  factory ElectricityMetrics.fromJson(Map<String, dynamic> json) {
    return ElectricityMetrics(
      hourlyMaxKwh: (json['hourly_max_kwh'] as num?)?.toDouble() ?? 134.0,
      hourlyKwh: (json['hourly_kwh'] as num?)?.toDouble() ?? 112.3,
      shiftMaxKwh: (json['shift_max_kwh'] as num?)?.toDouble() ?? 1074.0,
      shiftKwh: (json['shift_kwh'] as num?)?.toDouble() ?? 612.0,
      dailyMaxKwh: (json['daily_max_kwh'] as num?)?.toDouble() ?? 3221.0,
      dailyKwh: (json['daily_kwh'] as num?)?.toDouble() ?? 1840.5,
    );
  }

  Map<String, dynamic> toJson() => {
        'hourly_max_kwh': hourlyMaxKwh,
        'hourly_kwh': hourlyKwh,
        'shift_max_kwh': shiftMaxKwh,
        'shift_kwh': shiftKwh,
        'daily_max_kwh': dailyMaxKwh,
        'daily_kwh': dailyKwh,
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
        product: 'Jaggery Powder',
        plantCapacityTpd: 20.0,
        shiftsPerDay: 3,
        shiftTargetKg: 6667.0,
        shiftDurationHours: 8,
        hourlyTargetKg: 833.0,
        currentShift: 1,
        hourlyActualKg: 795.0,
        shiftActualKg: 3410.0,
        dailyActualKg: 8920.0,
      ),
      powderMaker: const PowderMakerData(
        batchCapacityKg: 500.0,
        status: PowderMakerStatus.crystallization,
        batchCurrentKg: 482.5,
        batchCycleSeconds: 185,
      ),
      storage: const StorageMetrics(
        numberOfSilos: 2,
        siloMaxKg: 5000.0,
        silo1Kg: 3970.0,   // Silo 1 is active and filling
        silo2Kg: 0.0,      // Silo 2 is empty and on standby
        syrupTankMaxKg: 5000.0,
        syrupTankKg: 3280.0,
      ),
      electricity: const ElectricityMetrics(
        hourlyMaxKwh: 134.0,
        hourlyKwh: 112.3,
        shiftMaxKwh: 1074.0,
        shiftKwh: 612.0,
        dailyMaxKwh: 3221.0,
        dailyKwh: 1840.5,
      ),
    );
  }
}
