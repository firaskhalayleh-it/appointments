import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import '../controllers/home_controller.dart';
import '../../../modules/appointments/views/appointment_card.dart';
import '../../general/custom_drawer.dart';
import '../../../modules/appointments/controllers/appointments_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});

  final _advancedDrawerController = AdvancedDrawerController();
  final _appointmentsController = Get.put(AppointmentsController());
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
          title: Text('cities'.tr),
          backgroundColor: Colors.blue.shade900,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _advancedDrawerController.showDrawer(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () => controller.addCity(),
              tooltip: 'addCity'.tr,
            ),
          ],
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
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'searchCityCustomerPhone'.tr,
                        hintStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.search, color: Colors.white),
                        suffixIcon: Obx(() => controller.isLoading.value
                            ? Container(
                                margin: const EdgeInsets.all(14),
                                width: 20,
                                height: 20,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const SizedBox.shrink()),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                ),

                // Results List
                Expanded(
                  child: Obx(() {
                    // Show loading indicator
                    if (controller.isLoading.value) {
                      return const Center(
                          child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ));
                    }

                    // Show appointments if found
                    if (controller.searchedAppointments.isNotEmpty) {
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: controller.searchedAppointments.length,
                        itemBuilder: (context, index) {
                          final appointment =
                              controller.searchedAppointments[index];
                          return AppointmentCard(
                            appointment: appointment,
                            controller: _appointmentsController,
                          );
                        },
                      );
                    }

                    // Show cities list
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: controller.filteredCitiesWithAppointments.length,
                      itemBuilder: (context, index) {
                        final city =
                            controller.filteredCitiesWithAppointments[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            onTap: () => controller.onCitySelected(city['name']),
                            onLongPress: () {
                              _showDeleteConfirmationDialog(
                                  context, city['name']);
                            },
                            title: Text(
                              city['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              '${city['count']} ${'appointments'.tr}${city['count'] != 1 ? ' ' : ''}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String cityName) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade900,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'deleteCity'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${'confirmDeleteCity'.tr} "$cityName" ${'andAppointments'.tr}',
                style: const TextStyle(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'cancel'.tr,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      await controller.deleteCity(cityName);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('delete'.tr),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}