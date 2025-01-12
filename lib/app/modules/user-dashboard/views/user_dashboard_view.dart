import 'package:appointments/app/modules/general/custom_drawer.dart';
import 'package:appointments/app/modules/user-dashboard/controllers/user_dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UserDashboardView extends GetView<UserDashboardController> {
  const UserDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      // Use the controller from UserDashboardController
      backdropColor: Colors.teal,
      controller: controller.advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: false,
      childDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      drawer: CustomDrawer(
        advancedDrawerController: controller.advancedDrawerController,
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('userDashboard'.tr),
            backgroundColor: Colors.blue.shade900,
            leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => controller.advancedDrawerController.showDrawer(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.location_city),
                onPressed: () => controller.addCity(),
                tooltip: 'addCity'.tr,
              ),
            ],
            bottom: TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(icon: const Icon(Icons.list), text: 'listCities'.tr),
                Tab(icon: const Icon(Icons.add), text: 'addAppointment'.tr),
              ],
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
            child: TabBarView(
              children: [
                // --------------------
                //  Cities List Tab
                // --------------------
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextField(
                            controller: controller.searchCitiesController,
                            onChanged: controller.filterCities,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'searchCities'.tr,
                              hintStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(Icons.search,
                                  color: Colors.white70),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Obx(() {
                          final cityList = controller.filteredCities;
                          if (cityList.isEmpty) {
                            return Center(
                              child: Text(
                                'noCitiesFound'.tr,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: cityList.length,
                            itemBuilder: (context, index) {
                              final city = cityList[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  title: Text(
                                    city['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${city['count']} ${city['count'] != 1 ? 'appointments'.tr : 'appointment'.tr}',
                                    style:
                                        const TextStyle(color: Colors.white70),
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

                // --------------------
                //  Add Appointment Tab
                // --------------------
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        children: [
                          // Dropdown for city
                          Obx(() {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: DropdownButtonFormField<String>(
                                dropdownColor: Colors.blueGrey,
                                isExpanded: true,
                                iconEnabledColor: Colors.white70,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'selectCity'.tr,
                                  labelStyle:
                                      const TextStyle(color: Colors.white70),
                                ),
                                value: controller.selectedCity.value.isNotEmpty
                                    ? controller.selectedCity.value
                                    : null,
                                items: controller.cities
                                    .map(
                                      (city) => DropdownMenuItem<String>(
                                        value: city['name'] as String,
                                        child: Text(
                                          city['name'] as String,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    controller.selectedCity.value = value;
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'pleaseSelectCity'.tr;
                                  }
                                  return null;
                                },
                              ),
                            );
                          }),
                          const SizedBox(height: 16),

                          // Name
                          _buildInputField(
                            controller: controller.nameController,
                            label: 'customerName'.tr,
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'nameRequired'.tr;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Phone
                          _buildInputField(
                            controller: controller.phoneController,
                            label: 'phoneNumber'.tr,
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'phoneRequired'.tr;
                              }
                              final regex = RegExp(r'^\+?[0-9]{7,15}$');
                              if (!regex.hasMatch(value.trim())) {
                                return 'validPhone'.tr;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Service
                          _buildInputField(
                            controller: controller.serviceController,
                            label: 'service'.tr,
                            icon: Icons.design_services_outlined,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'serviceRequired'.tr;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Date
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.calendar_today,
                                  color: Colors.white),
                              title: Obx(() => Text(
                                    DateFormat('MMM dd, yyyy').format(
                                      controller.selectedDate.value,
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                  )),
                              onTap: () => controller.pickDate(context),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Time
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.access_time,
                                  color: Colors.white),
                              title: Obx(
                                () => Text(
                                  controller.selectedTime.value.format(context),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              onTap: () => controller.pickTime(context),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Address
                          _buildInputField(
                            controller: controller.addressController,
                            label: 'address'.tr,
                            icon: Icons.location_on_outlined,
                            maxLines: 2,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'addressRequired'.tr;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Notes
                          _buildInputField(
                            controller: controller.notesController,
                            label: 'notesOptional'.tr,
                            icon: Icons.notes_outlined,
                            maxLines: 3,
                            validator: (_) => null,
                          ),
                          const SizedBox(height: 24),

                          // Submit button
                          ElevatedButton(
                            onPressed: () => controller.submitAppointment(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue.shade900,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'addAppointment'.tr,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: validator,
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    String cityName,
    UserDashboardController controller,
  ) {
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
                '${'deleteCityConfirmation'.tr} "$cityName"?',
                style: const TextStyle(color: Colors.white70),
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
