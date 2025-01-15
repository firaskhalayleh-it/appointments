import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/edit_appointment_controller.dart';
import 'package:intl/intl.dart';

class EditAppointmentView extends GetView<EditAppointmentController> {
  const EditAppointmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'editAppointment'.tr,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
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
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  _buildInputField(
                    controller: controller.customerNameController,
                    label: 'customerName'.tr,
                    icon: Icons.person_outline,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'nameRequired'.tr : null,
                  ),
                  const SizedBox(height: 16),
                  _buildPhoneInputField(
                    controller: controller.phoneNumberController,
                    label: 'phoneNumber'.tr,
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
                  Obx(() => _buildDateTimePicker(
                        icon: Icons.calendar_today,
                        title: controller.selectedDate.value != null
                            ? DateFormat('MMM dd, yyyy')
                                .format(controller.selectedDate.value!)
                            : 'selectDate'.tr,
                        onTap: () => _pickDate(context),
                      )),
                  const SizedBox(height: 16),
                  Obx(() => _buildDateTimePicker(
                        icon: Icons.access_time,
                        title: controller.selectedTime.value != null
                            ? controller.selectedTime.value!.format(context)
                            : 'selectTime'.tr,
                        onTap: () => _pickTime(context),
                      )),
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
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.8)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          errorStyle: const TextStyle(color: Colors.redAccent),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPhoneInputField({
    required TextEditingController controller,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.phone,
        textAlign: TextAlign.left,
        textDirection: ui.TextDirection.ltr,
        style: const TextStyle(color: Colors.white),
        inputFormatters: [
          LengthLimitingTextInputFormatter(13),
          TextInputFormatter.withFunction((oldValue, newValue) {
            final newText = newValue.text;
            if (newText.isEmpty) {
              return newValue;
            }

            // Only allow one plus sign at the start
            if (newText.length == 1) {
              return newValue.copyWith(text: '+');
            }

            // Clean the input to maintain +97X format
            if (newText.length > 1) {
              String cleanText = '+';
              
              // Add the prefix (970 or 972)
              if (newText.length >= 4) {
                final prefix = newText.substring(1, 4);
                if (prefix == '970' || prefix == '972') {
                  cleanText += prefix;
                } else {
                  cleanText += '970';  // Default to 970 if invalid prefix
                }
              } else {
                cleanText += newText.substring(1).replaceAll(RegExp(r'\D'), '');
              }
              
              // Add the remaining digits
              if (newText.length > 4) {
                final remainingDigits = newText.substring(4).replaceAll(RegExp(r'\D'), '');
                cleanText += remainingDigits;
              }
              
              return newValue.copyWith(
                text: cleanText,
                selection: TextSelection.collapsed(offset: cleanText.length),
              );
            }
            
            return newValue;
          }),
        ],
        decoration: InputDecoration(
          labelText: label,
          hintText: '+970xxxxxxxxx',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
          prefixIcon: Icon(Icons.phone_outlined, color: Colors.white.withOpacity(0.8)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          errorStyle: const TextStyle(color: Colors.redAccent),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'phoneRequired'.tr;
          }
          if (!value.startsWith('+970') && !value.startsWith('+972')) {
            return 'Phone must start with +970 or +972'.tr;
          }
          if (value.length != 13) {
            return 'Phone number must be 13 digits including prefix'.tr;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateTimePicker({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white.withOpacity(0.8)),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isLoading.value 
            ? null 
            : () => controller.updateAppointment(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade900,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: controller.isLoading.value
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade900),
                ),
              )
            : Text(
                'saveChanges'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    ));
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.blue.shade900,
              surface: Colors.blue.shade900,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.blue.shade800,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.selectedDate.value = picked;
      controller.dateController.text = DateFormat('MM/dd/yyyy').format(picked);
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: controller.selectedTime.value ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.blue.shade900,
              surface: Colors.blue.shade900,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.blue.shade800,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.selectedTime.value = picked;
      controller.timeController.text = '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }
}