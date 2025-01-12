import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../../general/custom_drawer.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';

class SettingsView extends GetView<SettingsController> {
  SettingsView({super.key});

  final _advancedDrawerController = AdvancedDrawerController();

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdropColor: Colors.teal,
      controller: _advancedDrawerController,
      childDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      drawer: CustomDrawer(advancedDrawerController: _advancedDrawerController),
      child: Scaffold(
        appBar: AppBar(
          title: Text('settings'.tr),
          backgroundColor: Colors.blue.shade900,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _advancedDrawerController.showDrawer(),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade900,
                Colors.blue.shade600,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Theme Section
                _buildSectionTitle('theme'.tr),
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Obx(() => _buildSwitchTile(
                            'darkMode'.tr,
                            'switchBetweenLightAndDarkTheme'.tr,
                            Icons.dark_mode_outlined,
                            controller.isDarkMode.value,
                            (value) => controller.toggleTheme(),
                          )),
                      Obx(() => _buildSwitchTile(
                            'useSystemTheme'.tr,
                            'followSystemThemeSettings'.tr,
                            Icons.settings_brightness,
                            controller.useSystemTheme.value,
                            (value) => controller.toggleSystemTheme(),
                          )),
                    ],
                  ),
                ),

                // Language Section
                _buildSectionTitle('language'.tr),
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(
                    () => DropdownButton<String>(
                      value: controller.currentLanguage.value,
                      isExpanded: true,
                      dropdownColor: Colors.blue.shade900,
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.white),
                      items: controller.availableLanguages.map((language) {
                        return DropdownMenuItem(
                          value: language['code'],
                          child: Row(
                            children: [
                              Text(
                                language['flag']!,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(language['name']!),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.changeLanguage(value);
                        }
                      },
                    ),
                  ),
                ),

                // App Info Section
                _buildSectionTitle('appInfo'.tr),
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildInfoTile(
                        'version'.tr,
                        '1.0.0',
                        Icons.info_outline,
                      ),
                      _buildInfoTile(
                        'buildNumber'.tr,
                        '100',
                        Icons.build_outlined,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withOpacity(0.7)),
      ),
      secondary: Icon(icon, color: Colors.white),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
      activeTrackColor: Colors.blue.shade300,
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: Text(
        value,
        style: TextStyle(color: Colors.white.withOpacity(0.7)),
      ),
    );
  }
}
