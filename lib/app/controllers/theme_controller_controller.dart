// lib/app/controllers/theme_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  final FlutterSecureStorage _storage = Get.find<FlutterSecureStorage>();
  final _isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }


  bool get isDarkMode => _isDarkMode.value;
  
  Future<void> initTheme() async {
    try {
      final storage = Get.find<FlutterSecureStorage>();
      final savedTheme = await storage.read(key: 'theme_mode');
      _isDarkMode.value = savedTheme == 'dark';
    } catch (e) {
      debugPrint('Theme initialization error: $e');
      // Use default light theme
      _isDarkMode.value = false;
    }
  }

  /// Loads the theme preference from secure storage
  Future<void> loadTheme() async {
    final storedTheme = await _storage.read(key: 'isDarkMode') ?? 'false';
    _isDarkMode.value = storedTheme == 'true';
  }

  /// Toggles the theme between light and dark modes
  Future<void> toggleTheme() async {
    _isDarkMode.value = !_isDarkMode.value;
    await _storage.write(key: 'isDarkMode', value: _isDarkMode.value.toString());
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
