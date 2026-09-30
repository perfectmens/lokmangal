import 'package:flutter/foundation.dart';
import '../models/telemetry_data.dart';
import '../repositories/telemetry_repository.dart';

enum TelemetryStatus { initial, loading, success, error, refreshing }

class TelemetryViewModel extends ChangeNotifier {
  final TelemetryRepository repository;
  TelemetryRepository get _repository => repository;

  TelemetryStatus _status = TelemetryStatus.initial;
  TelemetryStatus get status => _status;

  PlantTelemetry? _telemetry;
  PlantTelemetry? get telemetry => _telemetry;

  EnergyAnalytics? _analytics;
  EnergyAnalytics? get analytics => _analytics;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  TelemetryViewModel({required this.repository});

  Future<void> loadData() async {
    _status = TelemetryStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getPlantTelemetry(),
        _repository.getEnergyAnalytics(),
      ]);

      _telemetry = results[0] as PlantTelemetry;
      _analytics = results[1] as EnergyAnalytics;
      _status = TelemetryStatus.success;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load telemetry data: $e';
      _status = TelemetryStatus.error;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _status = TelemetryStatus.refreshing;
    notifyListeners();

    try {
      await _repository.refreshAllData();
      final results = await Future.wait([
        _repository.getPlantTelemetry(),
        _repository.getEnergyAnalytics(),
      ]);

      _telemetry = results[0] as PlantTelemetry;
      _analytics = results[1] as EnergyAnalytics;
      _status = TelemetryStatus.success;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to refresh telemetry: $e';
      _status = TelemetryStatus.error;
      notifyListeners();
    }
  }
}
