import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/telemetry_data.dart';

class TelemetryService {
  final http.Client _client;
  String _serverBaseUrl;
  Timer? _ticker;
  final StreamController<PlantTelemetry> _telemetryStreamController =
      StreamController<PlantTelemetry>.broadcast();

  PlantTelemetry _currentTelemetry = PlantTelemetry.initialMock();
  bool _isUsingSimulatedFallback = true;
  final Random _rng = Random();

  TelemetryService({
    http.Client? client,
    String? serverBaseUrl,
  })  : _client = client ?? http.Client(),
        _serverBaseUrl = serverBaseUrl ?? _defaultBaseUrl();

  static String _defaultBaseUrl() {
    if (kIsWeb) return 'http://localhost:8000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    } catch (_) {}
    return 'http://localhost:8000';
  }

  Stream<PlantTelemetry> get telemetryStream => _telemetryStreamController.stream;
  PlantTelemetry get currentTelemetry => _currentTelemetry;
  bool get isUsingSimulatedFallback => _isUsingSimulatedFallback;
  String get serverBaseUrl => _serverBaseUrl;

  void setBaseUrl(String url) {
    _serverBaseUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
  }

  void startStreaming({Duration interval = const Duration(seconds: 2)}) {
    _ticker?.cancel();
    _ticker = Timer.periodic(interval, (_) => fetchLatestTelemetry());
    // Initial fetch immediately
    fetchLatestTelemetry();
  }

  void stopStreaming() {
    _ticker?.cancel();
    _ticker = null;
  }

  Future<PlantTelemetry> fetchLatestTelemetry() async {
    final endpoint = Uri.parse('$_serverBaseUrl/api/v1/telemetry/live');
    try {
      final response = await _client
          .get(endpoint, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        _currentTelemetry = PlantTelemetry.fromJson(jsonMap);
        _isUsingSimulatedFallback = false;
        _telemetryStreamController.add(_currentTelemetry);
        return _currentTelemetry;
      }
    } catch (_) {
      // Backend not running or unreachable -> seamlessly switch to simulated real-time ticks
    }

    _advanceLocalSimulation();
    _isUsingSimulatedFallback = true;
    _telemetryStreamController.add(_currentTelemetry);
    return _currentTelemetry;
  }

  void _advanceLocalSimulation() {
    final prev = _currentTelemetry;
    int nextCycleSec = prev.powderMaker.batchCycleSeconds + 2;
    PowderMakerStatus currentStatus = prev.powderMaker.status;
    double currentBatchWeight = prev.powderMaker.batchCurrentKg;
    int completedBatches = prev.powderMaker.completedBatchesToday;

    // Advance 5-state cycle:
    // Ready (10s) -> Mixing (15s) -> Crystallization (20s) -> Powder Making (25s) -> Discharge (10s)
    if (nextCycleSec > 80) {
      nextCycleSec = 0;
      currentStatus = PowderMakerStatus.systemReady;
      currentBatchWeight = 0.0;
      completedBatches += 1;
    } else if (nextCycleSec >= 70) {
      currentStatus = PowderMakerStatus.discharge;
      currentBatchWeight = max(0.0, currentBatchWeight - 25.0);
    } else if (nextCycleSec >= 45) {
      currentStatus = PowderMakerStatus.powderMaking;
      currentBatchWeight = min(500.0, currentBatchWeight + 10.0);
    } else if (nextCycleSec >= 25) {
      currentStatus = PowderMakerStatus.crystallization;
      currentBatchWeight = min(500.0, currentBatchWeight + 15.0);
    } else if (nextCycleSec >= 10) {
      currentStatus = PowderMakerStatus.mixing;
      currentBatchWeight = min(300.0, currentBatchWeight + 20.0);
    } else {
      currentStatus = PowderMakerStatus.systemReady;
      currentBatchWeight = 0.0;
    }

    // Small fluctuations for storage and power
    final double powerFluc = (95.0 + _rng.nextDouble() * 12.0);
    final double hourlyKwh = min(134.0, prev.electricity.hourlyKwh + 0.05);

    _currentTelemetry = PlantTelemetry(
      timestamp: DateTime.now(),
      plant: prev.plant,
      production: ProductionMetrics(
        shiftNumber: prev.production.shiftNumber,
        shiftDurationHours: prev.production.shiftDurationHours,
        shiftElapsedSeconds: prev.production.shiftElapsedSeconds + 2,
        hourlyTargetKg: prev.production.hourlyTargetKg,
        hourlyActualKg: min(833.0, prev.production.hourlyActualKg + 0.2),
        shiftTargetKg: prev.production.shiftTargetKg,
        shiftActualKg: min(6667.0, prev.production.shiftActualKg + 0.5),
        plantCapacityTpd: prev.production.plantCapacityTpd,
        dailyActualKg: prev.production.dailyActualKg + 0.5,
      ),
      powderMaker: PowderMakerData(
        status: currentStatus,
        batchCapacityKg: 500.0,
        batchCurrentKg: double.parse(currentBatchWeight.toStringAsFixed(1)),
        batchCycleSeconds: nextCycleSec,
        completedBatchesToday: completedBatches,
      ),
      storage: StorageMetrics(
        silo1Kg: double.parse((prev.storage.silo1Kg + (_rng.nextDouble() * 0.4 - 0.2)).toStringAsFixed(1)),
        silo2Kg: double.parse((prev.storage.silo2Kg + (_rng.nextDouble() * 0.4 - 0.2)).toStringAsFixed(1)),
        combinedSilosKg: double.parse((prev.storage.combinedSilosKg + 0.2).clamp(0.0, 5000.0).toStringAsFixed(1)),
        combinedMaxCapacityKg: 5000.0,
        syrupTankKg: double.parse((prev.storage.syrupTankKg - 0.1).clamp(0.0, 5000.0).toStringAsFixed(1)),
        syrupTankMaxKg: 5000.0,
        loadCellsHealthy: true,
      ),
      electricity: ElectricityMetrics(
        currentPowerKw: double.parse(powerFluc.toStringAsFixed(1)),
        hourlyKwh: double.parse(hourlyKwh.toStringAsFixed(1)),
        hourlyMaxKwh: 134.0,
        shiftKwh: double.parse((prev.electricity.shiftKwh + 0.05).toStringAsFixed(1)),
        shiftMaxKwh: 1074.0,
        dailyKwh: double.parse((prev.electricity.dailyKwh + 0.05).toStringAsFixed(1)),
        dailyMaxKwh: 3221.0,
        specificEnergyConsumption: 0.179,
      ),
    );
  }

  void dispose() {
    stopStreaming();
    _telemetryStreamController.close();
  }
}
