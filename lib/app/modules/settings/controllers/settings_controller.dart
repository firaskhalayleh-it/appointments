import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SettingsController extends GetxController {
  final FlutterSecureStorage _secureStorage = Get.find<FlutterSecureStorage>();

  final isDarkMode = false.obs;
  final useSystemTheme = true.obs;
  final currentLanguage = 'en'.obs;

  final availableLanguages = [
    {'name': 'languageEnglish'.tr, 'code': 'en', 'flag': '🇺🇸'},
    //palestinem
    {'name': 'languageArabic'.tr, 'code': 'ar', 'flag': '🇵🇸'},
 
  ];

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    isDarkMode.value = (await _secureStorage.read(key: 'isDarkMode')) == 'true';
    useSystemTheme.value =
        (await _secureStorage.read(key: 'useSystemTheme')) == 'true';
    currentLanguage.value =
        await _secureStorage.read(key: 'language') ?? 'en';
  }

  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    await _secureStorage.write(
        key: 'isDarkMode', value: isDarkMode.value.toString());

    if (isDarkMode.value) {
      Get.changeTheme(ThemeData.dark());
    } else {
      Get.changeTheme(ThemeData.light());
    }
  }

  Future<void> toggleSystemTheme() async {
    useSystemTheme.value = !useSystemTheme.value;
    await _secureStorage.write(
        key: 'useSystemTheme', value: useSystemTheme.value.toString());

    if (useSystemTheme.value) {
      Get.changeTheme(ThemeData.light());
      // Add logic to apply system theme
    }
  }

  Future<void> changeLanguage(String langCode) async {
    currentLanguage.value = langCode;
    await _secureStorage.write(key: 'language', value: langCode);

    // Update app locale
    Locale locale = Locale(langCode);
    Get.updateLocale(locale);
  }
}
