import 'dart:async';
import 'package:appointments/app/controllers/theme_controller_controller.dart';
import 'package:appointments/app/modules/profile/controllers/profile_controller.dart';
import 'package:appointments/app/translations/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'firebase_options.dart';

import 'app/services/appointments_service.dart';
import 'app/routes/app_pages.dart';

// Global error handler
void _handleError(Object error, StackTrace stack) {
  debugPrint('Global Error: $error');
  debugPrint('Stack trace: $stack');
}

Future<void> initializeServices() async {
  try {
    // Initialize Firebase first
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');

    // Initialize secure storage with error catching
    try {
      final secureStorage = const FlutterSecureStorage();
      await secureStorage.read(key: 'test_key'); // Test if storage is accessible
      Get.put<FlutterSecureStorage>(secureStorage);
      debugPrint('Secure storage initialized successfully');
    } catch (e) {
      debugPrint('Secure storage initialization error: $e');
      // Continue without secure storage, implement fallback if needed
    }

    // Initialize other controllers with error catching
    try {
      final themeController = ThemeController();
       themeController.onInit(); // Add this method to ThemeController
      Get.put<ThemeController>(themeController);
      debugPrint('Theme controller initialized successfully');
    } catch (e) {
      debugPrint('Theme controller initialization error: $e');
      // Use default theme as fallback
      Get.put<ThemeController>(ThemeController());
    }

    // Initialize appointments service
    try {
      final appointmentsService = AppointmentsService();
       appointmentsService.onInit(); // Add this method to AppointmentsService
      Get.put<AppointmentsService>(appointmentsService);
      debugPrint('Appointments service initialized successfully');
    } catch (e) {
      debugPrint('Appointments service initialization error: $e');
      // Handle appointments service failure
      rethrow; // Rethrow if this is critical
    }

  } catch (e) {
    debugPrint('Critical initialization error: $e');
    rethrow;
  }
}

void main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Set up Flutter error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('Flutter Error: ${details.toString()}');
      FlutterError.presentError(details);
    };

    try {
      await initializeServices();
      runApp(const MyApp());
    } catch (e, stack) {
      debugPrint('Fatal error during initialization: $e');
      debugPrint('Stack trace: $stack');
      runApp(ErrorApp(error: e.toString()));
    }
  }, _handleError);
}

// Separate error app for better error display
class ErrorApp extends StatelessWidget {
  final String error;
  
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Application Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Error details: $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Attempt to restart the app
                    main();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        try {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Appointments',
            initialRoute: AppPages.INITIAL,
            getPages: AppPages.routes,
            locale: const Locale('ar'),
            fallbackLocale: const Locale('en'),
            translations: AppTranslations(),
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeController.isDarkMode.value
                ? ThemeMode.dark
                : ThemeMode.light,
            builder: (context, widget) {
              // Add error boundary for widget tree
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                return Material(
                  child: SafeArea(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                              size: 36,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Error: ${errorDetails.exception}',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              };
              return widget ?? const SizedBox.shrink();
            },
          );
        } catch (e, stack) {
          debugPrint('Error in MyApp build: $e');
          debugPrint('Stack trace: $stack');
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(
                  'Error: $e',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}