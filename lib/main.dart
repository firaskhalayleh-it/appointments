import 'dart:async';

import 'package:appointments/app/controllers/theme_controller_controller.dart';
import 'package:appointments/app/modules/profile/controllers/profile_controller.dart';
import 'package:appointments/app/translations/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'firebase_options.dart'; // Add this import

import 'app/services/appointments_service.dart';
import 'app/routes/app_pages.dart';


void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    try {
      // Initialize Firebase first if you're using it
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully');
      
      // Initialize GetX services one by one
      await initServices();
      
      runApp(const MyApp());
    } catch (error, stackTrace) {
      debugPrint('Error during initialization: $error');
      debugPrint('Stack trace: $stackTrace');
      
      // Run a minimal app that shows the error
      runApp(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Initialization Error: $error'),
          ),
        ),
      ));
    }
  }, (error, stack) {
    debugPrint('Uncaught error: $error');
    debugPrint('Stack trace: $stack');
  });
}

Future<void> initServices() async {
  try {
    // Initialize secure storage first
    final secureStorage = const FlutterSecureStorage();
    Get.put<FlutterSecureStorage>(secureStorage);
    
    // Initialize theme controller
    final themeController = ThemeController();
     themeController.onInit();
    Get.put<ThemeController>(themeController);
    
    // Initialize appointments service last
    final appointmentsService = AppointmentsService();
    await appointmentsService.init();
    Get.put<AppointmentsService>(appointmentsService);
    
  } catch (e) {
    debugPrint('Service initialization error: $e');
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetMaterialApp(
          title: 'Appointments',
          debugShowCheckedModeBanner: false,
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          locale: const Locale('ar'),
          fallbackLocale: const Locale('en'),
          translations: AppTranslations(),
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) {
            // Add error boundary
            ErrorWidget.builder = (FlutterErrorDetails details) {
              return Material(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(height: 8),
                      Text(
                        'Error: ${details.exception}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              );
            };
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}