// lib/app/controllers/theme_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  final FlutterSecureStorage _storage = Get.find<FlutterSecureStorage>();
  final isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }

  /// Loads the theme preference from secure storage
  Future<void> loadTheme() async {
    final storedTheme = await _storage.read(key: 'isDarkMode') ?? 'true';
    isDarkMode.value = storedTheme == 'true';
  }

  /// Toggles the theme between light and dark modes
  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    await _storage.write(key: 'isDarkMode', value: isDarkMode.value.toString());
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.dark);
    
  }
}
