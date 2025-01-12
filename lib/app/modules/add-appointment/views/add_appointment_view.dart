import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/add_appointment_controller.dart';
import 'package:intl/intl.dart';

class AddAppointmentView extends GetView<AddAppointmentController> {
  const AddAppointmentView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put<AddAppointmentController>(AddAppointmentController());

    return Scaffold(
      appBar: AppBar(
        title: Text('addAppointment'.tr),
        backgroundColor: Colors.blue.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  _buildInputField(
                    controller: controller.nameController,
                    label: 'customerName'.tr,
                    icon: Icons.person_outline,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'nameRequired'.tr : null,
                  ),
                  const SizedBox(height: 16),
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
                        return 'invalidPhone'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: controller.serviceController,
                    label: 'service'.tr,
                    icon: Icons.design_services_outlined,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'serviceRequired'.tr : null,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading:
                          const Icon(Icons.calendar_today, color: Colors.white),
                      title: Obx(() => Text(
                            DateFormat('MMM dd, yyyy')
                                .format(controller.selectedDate.value),
                            style: const TextStyle(color: Colors.white),
                          )),
                      onTap: () => _pickDate(context, controller),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading:
                          const Icon(Icons.access_time, color: Colors.white),
                      title: Obx(() => Text(
                            controller.selectedTime.value.format(context),
                            style: const TextStyle(color: Colors.white),
                          )),
                      onTap: () => _pickTime(context, controller),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: controller.addressController,
                    label: 'address'.tr,
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'addressRequired'.tr : null,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: controller.notesController,
                    label: 'notesOptional'.tr,
                    icon: Icons.notes_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => controller.submitAppointment(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade900,
                      padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 16),
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

  Future<void> _pickDate(
      BuildContext context, AddAppointmentController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.blue,
              surface: Colors.blue,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.selectedDate.value = picked;
    }
  }

  Future<void> _pickTime(
      BuildContext context, AddAppointmentController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: controller.selectedTime.value,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.blue,
              surface: Colors.blue,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.selectedTime.value = picked;
    }
  }
}
