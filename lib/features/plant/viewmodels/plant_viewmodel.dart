import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/api/api_endpoints.dart';
import '../models/plant_models.dart';
import '../repositories/plant_repository.dart';

class PlantViewModel extends ChangeNotifier {
  final PlantRepository _repository;

  String _baseUrl = ApiEndpoints.defaultSimulationHost;
  bool _isLoading = false;
  bool _isOnline = false;
  DateTime? _lastUpdated;
  Timer? _pollingTimer;

  PlantStatus _plantStatus = PlantStatus.initial();
  List<PlantEvent> _events = [];
  ProductionSummary _production = ProductionSummary.initial();
  List<BatchRecord> _batches = [];
  PowderMakerState _powderMaker = PowderMakerState.initial();
  StorageLevels _storage = StorageLevels.initial();
  EnergyOverview _energy = EnergyOverview.initial();
  AlarmsResponse _alarms = AlarmsResponse.initial();

  int _selectedTab = 0; // 0: Home, 1: Process, 2: Production, 3: Energy, 4: Alarms

  PlantViewModel({PlantRepository? repository})
      : _repository = repository ?? PlantRepositoryImpl();

  // Getters
  String get baseUrl => _baseUrl;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  DateTime? get lastUpdated => _lastUpdated;
  int get selectedTab => _selectedTab;

  PlantStatus get plantStatus => _plantStatus;
  List<PlantEvent> get events => _events;
  ProductionSummary get production => _production;
  List<BatchRecord> get batches => _batches;
  PowderMakerState get powderMaker => _powderMaker;
  StorageLevels get storage => _storage;
  EnergyOverview get energy => _energy;
  AlarmsResponse get alarms => _alarms;

  void selectTab(int index) {
    if (_selectedTab != index) {
      _selectedTab = index;
      notifyListeners();
    }
  }

  void updateBaseUrl(String newUrl) {
    String formatted = newUrl.trim();
    if (formatted.endsWith('/')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    if (formatted.isNotEmpty && formatted != _baseUrl) {
      _baseUrl = formatted;
      notifyListeners();
      loadAllData();
    }
  }

  Future<void> initialize() async {
    await loadAllData();
    startAutoPolling();
  }

  void startAutoPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _pollTelemetry();
    });
  }

  void stopAutoPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getPlantStatus(_baseUrl),
        _repository.getTelemetryEvents(_baseUrl),
        _repository.getProductionSummary(_baseUrl),
        _repository.getProductionBatches(_baseUrl),
        _repository.getPowderMakerState(_baseUrl),
        _repository.getStorageLevels(_baseUrl),
        _repository.getEnergyOverview(_baseUrl),
        _repository.getAlarms(_baseUrl),
      ]);

      _plantStatus = results[0] as PlantStatus;
      _events = results[1] as List<PlantEvent>;
      _production = results[2] as ProductionSummary;
      _batches = results[3] as List<BatchRecord>;
      _powderMaker = results[4] as PowderMakerState;
      _storage = results[5] as StorageLevels;
      _energy = results[6] as EnergyOverview;
      _alarms = results[7] as AlarmsResponse;

      _isOnline = _plantStatus.connectionStatus.toUpperCase() == 'ONLINE';
      _lastUpdated = DateTime.now();
    } catch (e) {
      debugPrint('Error loading plant data: $e');
      _isOnline = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _pollTelemetry() async {
    try {
      final status = await _repository.getPlantStatus(_baseUrl);
      final events = await _repository.getTelemetryEvents(_baseUrl);
      final process = await _repository.getPowderMakerState(_baseUrl);
      final storage = await _repository.getStorageLevels(_baseUrl);
      final energy = await _repository.getEnergyOverview(_baseUrl);
      final production = await _repository.getProductionSummary(_baseUrl);
      final alarms = await _repository.getAlarms(_baseUrl);

      _plantStatus = status;
      _events = events;
      _powderMaker = process;
      _storage = storage;
      _energy = energy;
      _production = production;
      _alarms = alarms;
      _isOnline = status.isOnline;
      _lastUpdated = DateTime.now();
      notifyListeners();
    } catch (_) {
      if (_isOnline) {
        _isOnline = false;
        notifyListeners();
      }
    }
  }

  Future<bool> acknowledgeAlarm(String alarmId, {String operatorName = 'Operator'}) async {
    final success = await _repository.acknowledgeAlarm(_baseUrl, alarmId, operatorName: operatorName);
    if (success) {
      // Optimistically update local alarm state
      final updatedList = _alarms.alarms.map((a) {
        if (a.id == alarmId) {
          return AlarmItem(
            id: a.id,
            code: a.code,
            title: a.title,
            equipment: a.equipment,
            severity: a.severity,
            status: 'ACKNOWLEDGED',
            triggeredAt: a.triggeredAt,
            acknowledgedAt: DateTime.now().toIso8601String().substring(11, 16),
            acknowledgedBy: operatorName,
            value: a.value,
            limit: a.limit,
          );
        }
        return a;
      }).toList();

      final criticals = updatedList.where((a) => a.isCritical && !a.isAcknowledged).length;
      final warnings = updatedList.where((a) => !a.isCritical && !a.isAcknowledged).length;

      _alarms = AlarmsResponse(
        criticalCount: criticals,
        warningCount: warnings,
        alarms: updatedList,
      );
      notifyListeners();
    }
    return success;
  }

  @override
  void dispose() {
    stopAutoPolling();
    super.dispose();
  }
}
