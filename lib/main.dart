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

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with error handling
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize other services
    final secureStorage = const FlutterSecureStorage();
    Get.put<FlutterSecureStorage>(secureStorage);
    Get.put<ThemeController>(ThemeController());
    Get.put<AppointmentsService>(AppointmentsService());

    runApp(const MyApp());
  } catch (e, stackTrace) {
    print('Error during initialization: $e');
    print('Stack trace: $stackTrace');

    // Run a minimal app that shows the error
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Application initialization error. Please try again.\nError: $e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      try {
        final themeController = Get.find<ThemeController>();
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Appointments',
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          locale: const Locale('ar'), // Set Arabic as default locale
          fallbackLocale: const Locale('en'), // Fallback to English
          translations: AppTranslations(), // Load translations
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeController.isDarkMode.value
              ? ThemeMode.dark
              : ThemeMode.light,
        );
      } catch (e, stacktrace) {
        print('Error during theme setup: $e');
        print(stacktrace);
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text(
                'Something went wrong. Please restart the app.'
                    .tr, // Translation applied
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        );
      }
    });
  }
}
