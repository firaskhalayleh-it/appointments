import 'package:appointments/app/services/notification_service.dart';
import 'package:appointments/app/services/appointments_service.dart';
import 'package:appointments/app/controllers/theme_controller_controller.dart';
import 'package:appointments/app/translations/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:appointments/firebase_options.dart'; 
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1) Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 2) Initialize Flutter Secure Storage
    final secureStorage = const FlutterSecureStorage();
    Get.put<FlutterSecureStorage>(secureStorage);

    // 3) Initialize Theme Controller
    Get.put<ThemeController>(ThemeController());

    // 4) Initialize Notification Service
    final notificationService = NotificationService();
    await notificationService.init();
    Get.put(notificationService);

    // 5) Initialize Appointments Service
    Get.put<AppointmentsService>(AppointmentsService());

    // 6) Run the app
    runApp(const MyApp());
  } catch (e, stacktrace) {
    print('Error during app initialization: $e');
    print(stacktrace);
    // Optionally show an error screen or a fallback
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      try {
        final themeController = Get.isRegistered<ThemeController>()
            ? Get.find<ThemeController>()
            : ThemeController();
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Appointments',
          initialRoute: AppPages.INITIAL, // or your chosen initial route
          getPages: AppPages.routes,
          locale: const Locale('ar'), // default locale (Arabic)
          fallbackLocale: const Locale('en'), // fallback locale (English)
          translations: AppTranslations(), // your translations
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
                'Something went wrong. Please restart the app.'.tr,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        );
      }
    });
  }
}
