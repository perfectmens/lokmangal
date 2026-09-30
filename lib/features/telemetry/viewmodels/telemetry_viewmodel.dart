import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/telemetry_data.dart';
import '../services/telemetry_service.dart';

class TelemetryViewModel extends ChangeNotifier {
  final TelemetryService _service;
  StreamSubscription<PlantTelemetry>? _sub;

  PlantTelemetry _telemetry = PlantTelemetry.initialMock();
  bool _isLoading = false;

  TelemetryViewModel({
    TelemetryService? service,
    bool autoStart = true,
  }) : _service = service ?? TelemetryService() {
    _init(autoStart: autoStart);
  }

  PlantTelemetry get telemetry => _telemetry;
  bool get isLoading => _isLoading;
  bool get isSimulated => _service.isUsingSimulatedFallback;
  String get serverBaseUrl => _service.serverBaseUrl;

  PowderMakerData get powderMaker => _telemetry.powderMaker;
  StorageMetrics get storage => _telemetry.storage;
  ProductionMetrics get production => _telemetry.production;
  ElectricityMetrics get electricity => _telemetry.electricity;

  String get formattedShiftInfo =>
      'Shift ${production.currentShift} of ${production.shiftsPerDay} (${production.shiftDurationHours}h Duration)';

  void _init({bool autoStart = true}) {
    _telemetry = _service.currentTelemetry;
    _sub = _service.telemetryStream.listen((data) {
      _telemetry = data;
      notifyListeners();
    });
    if (autoStart) {
      _service.startStreaming();
    }
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    _telemetry = await _service.fetchLatestTelemetry();
    _isLoading = false;
    notifyListeners();
  }

  void setServerBaseUrl(String url) {
    _service.setBaseUrl(url);
    refresh();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _service.dispose();
    super.dispose();
  }
}
