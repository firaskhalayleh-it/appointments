// edit_appointment_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/appointment_model.dart';
import '../../../services/appointments_service.dart';

class EditAppointmentController extends GetxController {
  final AppointmentsService _service = Get.find<AppointmentsService>();
  
  final formKey = GlobalKey<FormState>();
  late AppointmentModel appointment;
  late String currentCity;
  
  final customerNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final serviceController = TextEditingController();
  final addressController = TextEditingController();
  final notesController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  
  final isLoading = false.obs;
  final selectedDate = Rx<DateTime?>(null);
  final selectedTime = Rx<TimeOfDay?>(null);

  @override
  void onInit() {
    super.onInit();
    // Get the appointment data passed as arguments
    appointment = Get.arguments['appointment'] as AppointmentModel;
    currentCity = Get.arguments['city'] as String;
    
    // Pre-fill the form fields
    customerNameController.text = appointment.customerName;
    phoneNumberController.text = appointment.phoneNumber;
    serviceController.text = appointment.service;
    addressController.text = appointment.address;
    notesController.text = appointment.notes;
    
    // Parse and set the date and time
    final dateTime = DateTime.parse(appointment.dateTime);
    selectedDate.value = dateTime;
    selectedTime.value = TimeOfDay.fromDateTime(dateTime);
    
    dateController.text = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    timeController.text = '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    customerNameController.dispose();
    phoneNumberController.dispose();
    serviceController.dispose();
    addressController.dispose();
    notesController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.onClose();
  }

  Future<void> updateAppointment() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedDate.value == null || selectedTime.value == null) {
      Get.snackbar(
        'error'.tr,
        'selectDateTime'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      
      // Combine date and time
      final DateTime dateTime = DateTime(
        selectedDate.value!.year,
        selectedDate.value!.month,
        selectedDate.value!.day,
        selectedTime.value!.hour,
        selectedTime.value!.minute,
      );

      // Create updated appointment model
      final updatedAppointment = AppointmentModel(
        id: appointment.id,
        customerName: customerNameController.text,
        phoneNumber: phoneNumberController.text,
        service: serviceController.text,
        address: addressController.text,
        notes: notesController.text,
        dateTime: dateTime.toIso8601String(),
        status: appointment.status,
        city: currentCity,
      );

      await _service.updateAppointment(updatedAppointment);
      
      Get.back(result: true);
      Get.snackbar(
        'success'.tr,
        'appointmentUpdated'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'updateFailed'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      selectedDate.value = picked;
      dateController.text = '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  Future<void> selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: selectedTime.value ?? TimeOfDay.now(),
    );
    
    if (picked != null) {
      selectedTime.value = picked;
      timeController.text = '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }
}