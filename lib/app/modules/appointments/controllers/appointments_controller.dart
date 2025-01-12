import 'dart:async';
import 'package:appointments/app/data/appointment_model.dart';
import 'package:appointments/app/modules/add-appointment/views/add_appointment_view.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:appointments/app/services/appointments_service.dart';

class AppointmentsController extends GetxController {
  final AppointmentsService _service = Get.find<AppointmentsService>();

  late String currentCity;

  final appointments = <AppointmentModel>[].obs;
  final filteredAppointments = <AppointmentModel>[].obs;

  final TextEditingController searchController = TextEditingController();

  final isLoading = true.obs;

  StreamSubscription<List<AppointmentModel>>? _appointmentsSubscription;

  @override
  void onInit() {
    super.onInit();
    print('AppointmentsController -> raw arguments: ${Get.arguments}');
    currentCity = (Get.arguments ?? '') as String;
    print('AppointmentsController -> currentCity: $currentCity');

    setupAppointmentsListener();
    searchController.addListener(() {
      filterAppointments(searchController.text);
    });
  }

  @override
  void onClose() {
    _appointmentsSubscription?.cancel();
    searchController.dispose();
    super.onClose();
  }

  void setupAppointmentsListener() {
    _appointmentsSubscription =
        _service.fetchAppointments(currentCity).listen((data) {
      appointments.value = data;
      filterAppointments(searchController.text);
      isLoading.value = false;
    }, onError: (error) {
      Get.snackbar(
        'error'.tr,
        '${'failedFetchAppointments'.tr}: $error',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isLoading.value = false;
    });
  }

  void filterAppointments(String query) {
    if (query.isEmpty) {
      filteredAppointments.value = List.from(appointments);
    } else {
      filteredAppointments.value = appointments
          .where((apt) =>
              apt.customerName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  Future<void> updateAppointmentStatus(String id, String newStatus) async {
    try {
      await _service.updateAppointmentStatus(id, newStatus);

      Get.snackbar(
        'statusUpdated'.tr,
        '${'appointmentUpdated'.tr}: $newStatus',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _service.fetchAppointments(currentCity);
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        '${'failedUpdateStatus'.tr}: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteAppointment(String id) async {
    try {
      await _service.deleteAppointment(id, currentCity);
      Get.snackbar(
        'deleted'.tr,
        'appointmentDeleted'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        '${'failedDeleteAppointment'.tr}: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> openWhatsApp(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final whatsappUrl = Uri.parse('whatsapp://send?phone=$cleanNumber');
    final waMeUrl = Uri.parse('https://wa.me/$cleanNumber');

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(waMeUrl)) {
        await launchUrl(waMeUrl, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'error'.tr,
          'whatsappUnavailable'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        '${'failedOpenWhatsApp'.tr}: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> sendSMS(String phoneNumber) async {
    final url = Uri.parse('sms:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'error'.tr,
        'smsUnavailable'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> callCustomer(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Get.snackbar(
        'error'.tr,
        'cannotCallNumber'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void addNewAppointment() {
    Get.to(() => const AddAppointmentView(), arguments: currentCity);
  }

  void showFilterOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.pending_actions, color: Colors.blue),
              title: Text('pending'.tr),
              onTap: () => _filterAppointmentsByStatus('pending'),
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline, color: Colors.green),
              title: Text('achieved'.tr),
              onTap: () => _filterAppointmentsByStatus('achieved'),
            ),
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.orange),
              title: Text('postponed'.tr),
              onTap: () => _filterAppointmentsByStatus('postponed'),
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined, color: Colors.red),
              title: Text('rejected'.tr),
              onTap: () => _filterAppointmentsByStatus('rejected'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.clear, color: Colors.grey),
              title: Text('clearFilters'.tr),
              onTap: () {
                filterAppointments(searchController.text);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _filterAppointmentsByStatus(String status) {
    filteredAppointments.value = appointments
        .where((apt) => apt.status.toLowerCase() == status.toLowerCase())
        .toList();
    Get.back();
  }
}
