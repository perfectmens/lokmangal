import 'package:flutter_test/flutter_test.dart';
import 'package:lokmangal/features/telemetry/repositories/telemetry_repository.dart';
import 'package:lokmangal/features/telemetry/viewmodels/telemetry_viewmodel.dart';

void main() {
  group('TelemetryViewModel Unit Tests', () {
    late TelemetryRepository repository;
    late TelemetryViewModel viewModel;

    setUp(() {
      repository = TelemetryRepositoryImpl();
      viewModel = TelemetryViewModel(repository: repository);
    });

    test('Initial state is TelemetryStatus.initial', () {
      expect(viewModel.status, TelemetryStatus.initial);
      expect(viewModel.telemetry, isNull);
      expect(viewModel.analytics, isNull);
    });

    test('loadData transitions to success and populates Page 1 and Page 2 data', () async {
      await viewModel.loadData();

      expect(viewModel.status, TelemetryStatus.success);
      expect(viewModel.telemetry, isNotNull);
      expect(viewModel.analytics, isNotNull);

      // Verify Page 1 metrics
      expect(viewModel.telemetry!.boilerPressureBar, greaterThan(0));
      expect(viewModel.telemetry!.caneCrushedTodayTons, greaterThan(0));

      // Verify Page 2 metrics
      expect(viewModel.analytics!.powerGeneratedMw, greaterThan(0));
      expect(viewModel.analytics!.hourlyTrend.isNotEmpty, isTrue);
    });

    test('refresh updates cached telemetry values', () async {
      await viewModel.loadData();
      final initialCrushed = viewModel.telemetry!.caneCrushedTodayTons;

      await viewModel.refresh();

      expect(viewModel.status, TelemetryStatus.success);
      expect(viewModel.telemetry!.caneCrushedTodayTons, greaterThan(initialCrushed));
    });
  });
}
