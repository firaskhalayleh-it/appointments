import 'package:appointments/app/data/appointment_model.dart';
import 'package:appointments/app/services/appointments_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddAppointmentController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final AppointmentsService _service = Get.find<AppointmentsService>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController serviceController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final selectedDate = DateTime.now().obs;
  final selectedTime = TimeOfDay.now().obs;

  late String city;

  @override
  void onInit() {
    super.onInit();
    city = Get.arguments ?? 'defaultCity'.tr;
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    serviceController.dispose();
    addressController.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<void> submitAppointment() async {
    if (formKey.currentState?.validate() ?? false) {
      final DateTime combinedDateTime = DateTime(
        selectedDate.value.year,
        selectedDate.value.month,
        selectedDate.value.day,
        selectedTime.value.hour,
        selectedTime.value.minute,
      );

      final appointment = AppointmentModel(
        id: '',
        customerName: nameController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        service: serviceController.text.trim(),
        dateTime: DateFormat('yyyy-MM-ddTHH:mm:ss').format(combinedDateTime),
        address: addressController.text.trim(),
        notes: notesController.text.trim(),
        status: AppointmentStatus.pending.toString().split('.').last,
        city: city,
      );

      try {
        await _service.addAppointment(appointment);
        Get.back();

        Get.snackbar(
          'success'.tr,
          'appointmentAddedSuccessfully'.tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'error'.tr,
          '${'failedAddAppointment'.tr}: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}
