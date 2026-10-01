import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/app_update/repositories/app_update_repository_impl.dart';
import 'features/app_update/services/update_api_service.dart';
import 'features/app_update/viewmodels/app_update_viewmodel.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/auth/views/login_page.dart';
import 'features/home/views/home_screen.dart';
import 'features/telemetry/viewmodels/telemetry_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style matching dual-tone neumorphic theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Core Services and Repositories
  final updateApiService = UpdateApiService();
  final updateRepository = AppUpdateRepositoryImpl(apiService: updateApiService);

  // Initialize ViewModels
  final updateViewModel = AppUpdateViewModel(repository: updateRepository);
  final telemetryViewModel = TelemetryViewModel();
  final authViewModel = AuthViewModel();

  // Background initialization
  await authViewModel.initialize();
  await updateViewModel.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authViewModel),
        ChangeNotifierProvider.value(value: updateViewModel),
        ChangeNotifierProvider.value(value: telemetryViewModel),
      ],
      child: const AuralissApp(),
    ),
  );
}

class AuralissApp extends StatelessWidget {
  const AuralissApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    return MaterialApp(
      title: 'Auraliss',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: authVm.isAuthenticated ? const HomeScreen() : const LoginPage(),
    );
  }
}
