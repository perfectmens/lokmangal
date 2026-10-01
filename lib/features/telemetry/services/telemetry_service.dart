import 'dart:async';
import 'dart:math';
import '../models/telemetry_data.dart';

/// 100% In-App Standalone Industrial Telemetry Calculation Engine.
/// Operates entirely on-device with zero backend or external server dependencies.
/// Models the 20 TPD plant throughput, dynamic 5-stage powder maker cycle,
/// storage inventory accumulation, electricity load, and 8-hour shift pacing.
class TelemetryService {
  Timer? _ticker;
  final StreamController<PlantTelemetry> _telemetryStreamController =
      StreamController<PlantTelemetry>.broadcast();

  PlantTelemetry _currentTelemetry = PlantTelemetry.initialMock();
  int _tickCount = 0;

  TelemetryService({
    Object? client,
    String? serverBaseUrl,
  });

  Stream<PlantTelemetry> get telemetryStream => _telemetryStreamController.stream;
  PlantTelemetry get currentTelemetry => _currentTelemetry;
  bool get isUsingSimulatedFallback => false;
  bool get isOfflineEngine => true;
  String get serverBaseUrl => 'offline://standalone';

  void setBaseUrl(String url) {
    // Standalone offline engine — no external endpoint required
  }

  void startStreaming({Duration interval = const Duration(seconds: 2)}) {
    _ticker?.cancel();
    _ticker = Timer.periodic(interval, (_) => fetchLatestTelemetry());
    fetchLatestTelemetry();
  }

  void stopStreaming() {
    _ticker?.cancel();
    _ticker = null;
  }

  Future<PlantTelemetry> fetchLatestTelemetry() async {
    _tickCount++;
    _calculateNextTelemetryState();
    _telemetryStreamController.add(_currentTelemetry);
    return _currentTelemetry;
  }

  void _calculateNextTelemetryState() {
    final prev = _currentTelemetry;
    int nextCycleSec = prev.powderMaker.batchCycleSeconds + 2;
    PowderMakerStatus currentStatus = prev.powderMaker.status;
    double currentBatchWeight = prev.powderMaker.batchCurrentKg;

    // 5-Stage Powder Maker State Progression:
    // 1. System Ready (0 - 10s): 0 kg
    // 2. Mixing (10 - 25s): ramps up to 220 kg
    // 3. Crystallization (25 - 50s): thermal phase, ramps up to 410 kg
    // 4. Powder Making (50 - 80s): final milling, reaches 500 kg full batch
    // 5. Discharge (80 - 90s): discharges powder into Silo 1
    double dischargedKgThisTick = 0.0;

    if (nextCycleSec > 90) {
      nextCycleSec = 0;
      currentStatus = PowderMakerStatus.systemReady;
      currentBatchWeight = 0.0;
    } else if (nextCycleSec >= 80) {
      currentStatus = PowderMakerStatus.discharge;
      dischargedKgThisTick = 12.5;
      currentBatchWeight = max(0.0, currentBatchWeight - dischargedKgThisTick);
    } else if (nextCycleSec >= 50) {
      currentStatus = PowderMakerStatus.powderMaking;
      currentBatchWeight = min(500.0, currentBatchWeight + 6.0);
    } else if (nextCycleSec >= 25) {
      currentStatus = PowderMakerStatus.crystallization;
      currentBatchWeight = min(410.0, currentBatchWeight + 7.5);
    } else if (nextCycleSec >= 10) {
      currentStatus = PowderMakerStatus.mixing;
      currentBatchWeight = min(220.0, currentBatchWeight + 15.0);
    } else {
      currentStatus = PowderMakerStatus.systemReady;
      currentBatchWeight = 0.0;
    }

    // Dynamic hourly rate with realistic sinusoidal fluctuation around 795 kg/h
    final double hourlyRate = double.parse(
      (795.0 + sin(_tickCount * 0.15) * 12.0).clamp(760.0, 833.0).toStringAsFixed(1),
    );

    // Production accumulation
    final double shiftActualKg = double.parse(
      min(6667.0, prev.production.shiftActualKg + (dischargedKgThisTick > 0 ? 0.8 : 0.2)).toStringAsFixed(1),
    );
    final double dailyActualKg = double.parse(
      (prev.production.dailyActualKg + (dischargedKgThisTick > 0 ? 0.8 : 0.2)).toStringAsFixed(1),
    );

    // Storage calculation
    double silo1 = prev.storage.silo1Kg;
    double silo2 = prev.storage.silo2Kg;
    int activeSilo = prev.storage.activeSilo;

    if (dischargedKgThisTick > 0) {
      if (silo1 < 5000.0) {
        silo1 = min(5000.0, silo1 + 0.8);
        activeSilo = 1;
      } else {
        silo2 = min(5000.0, silo2 + 0.8);
        activeSilo = 2;
      }
    }

    final double syrup = (currentStatus == PowderMakerStatus.mixing)
        ? max(0.0, prev.storage.syrupTankKg - 0.2)
        : prev.storage.syrupTankKg;

    // Electricity calculation based on machine state
    double liveKw = 96.0;
    switch (currentStatus) {
      case PowderMakerStatus.systemReady:
        liveKw = 94.5;
        break;
      case PowderMakerStatus.mixing:
        liveKw = 108.2;
        break;
      case PowderMakerStatus.crystallization:
        liveKw = 117.8;
        break;
      case PowderMakerStatus.powderMaking:
        liveKw = 119.4;
        break;
      case PowderMakerStatus.discharge:
        liveKw = 103.6;
        break;
    }
    liveKw = double.parse((liveKw + sin(_tickCount * 0.2) * 2.5).toStringAsFixed(1));

    final double hourlyKwh = double.parse(
      min(134.0, prev.electricity.hourlyKwh + 0.04).toStringAsFixed(1),
    );
    final double shiftKwh = double.parse(
      (prev.electricity.shiftKwh + 0.04).toStringAsFixed(1),
    );
    final double dailyKwh = double.parse(
      (prev.electricity.dailyKwh + 0.04).toStringAsFixed(1),
    );

    // 8-Hour Shift Timeline Production History (Elapsed half-trend updating in real-time)
    final List<ProductionDataPoint> updatedHourlyHistory = prev.hourlyProductionHistory.isNotEmpty
        ? [
            ...prev.hourlyProductionHistory.sublist(0, prev.hourlyProductionHistory.length - 1),
            ProductionDataPoint(
              hour: prev.hourlyProductionHistory.last.hour,
              actualKg: hourlyRate,
              targetKg: prev.hourlyProductionHistory.last.targetKg,
            ),
          ]
        : PlantTelemetry.initialMock().hourlyProductionHistory;

    // Shift History (Current Live Shift updated with shiftActualKg)
    final List<ShiftHistoryEntry> updatedShiftHistory = prev.shiftHistory.isNotEmpty
        ? [
            ...prev.shiftHistory.where((s) => !s.isCurrent),
            ShiftHistoryEntry(
              shiftLabel: prev.shiftHistory.firstWhere((s) => s.isCurrent, orElse: () => prev.shiftHistory.last).shiftLabel,
              actualKg: shiftActualKg,
              targetKg: 6667.0,
              isCurrent: true,
            ),
          ]
        : PlantTelemetry.initialMock().shiftHistory;

    _currentTelemetry = PlantTelemetry(
      timestamp: DateTime.now(),
      plant: prev.plant,
      production: ProductionMetrics(
        product: prev.production.product,
        plantCapacityTpd: 20.0,
        shiftsPerDay: 3,
        shiftTargetKg: 6667.0,
        shiftDurationHours: 8,
        hourlyTargetKg: 833.0,
        currentShift: prev.production.currentShift,
        hourlyActualKg: hourlyRate,
        shiftActualKg: shiftActualKg,
        dailyActualKg: dailyActualKg,
      ),
      powderMaker: PowderMakerData(
        batchCapacityKg: 500.0,
        status: currentStatus,
        batchCurrentKg: double.parse(currentBatchWeight.toStringAsFixed(1)),
        batchCycleSeconds: nextCycleSec,
      ),
      storage: StorageMetrics(
        numberOfSilos: 2,
        siloMaxKg: 5000.0,
        silo1Kg: double.parse(silo1.toStringAsFixed(1)),
        silo2Kg: double.parse(silo2.toStringAsFixed(1)),
        activeSilo: activeSilo,
        syrupTankMaxKg: 5000.0,
        syrupTankKg: double.parse(syrup.toStringAsFixed(1)),
      ),
      electricity: ElectricityMetrics(
        hourlyMaxKwh: 134.0,
        hourlyKwh: hourlyKwh,
        shiftMaxKwh: 1074.0,
        shiftKwh: shiftKwh,
        dailyMaxKwh: 3221.0,
        dailyKwh: dailyKwh,
        hourlyKwhHistory: prev.electricity.hourlyKwhHistory.isNotEmpty
            ? [
                ...prev.electricity.hourlyKwhHistory.sublist(0, prev.electricity.hourlyKwhHistory.length - 1),
                KwhDataPoint(
                  hour: prev.electricity.hourlyKwhHistory.last.hour,
                  kwh: hourlyKwh,
                ),
              ]
            : PlantTelemetry.initialMock().electricity.hourlyKwhHistory,
      ),
      hourlyProductionHistory: updatedHourlyHistory,
      shiftHistory: updatedShiftHistory,
    );
  }

  void dispose() {
    stopStreaming();
    _telemetryStreamController.close();
  }
}
