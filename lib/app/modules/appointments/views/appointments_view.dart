import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/appointments_controller.dart';
import 'appointment_card.dart';

class AppointmentsView extends GetView<AppointmentsController> {
  const AppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put<AppointmentsController>(AppointmentsController());

    return Scaffold(
      appBar: AppBar(
        title: Text('${'appointmentsIn'.tr} ${controller.currentCity}'),
        backgroundColor: Colors.blue.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
          tooltip: 'back'.tr,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => controller.showFilterOptions(),
            tooltip: 'filterAppointments'.tr,
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
                      hintText: 'searchCustomerName'.tr,
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
              ),
              // Appointments List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (controller.filteredAppointments.isEmpty) {
                    return Center(
                      child: Text(
                        'noAppointmentsFound'.tr,
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.filteredAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment =
                            controller.filteredAppointments[index];
                        return AppointmentCard(
                          appointment: appointment,
                          controller: controller,
                        );
                      },
                    );
                  }
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.addNewAppointment(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue.shade900,
        tooltip: 'addAppointment'.tr,
      ),
    );
  }
}
