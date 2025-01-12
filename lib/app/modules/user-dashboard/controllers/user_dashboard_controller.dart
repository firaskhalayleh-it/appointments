import 'dart:async';
import 'package:appointments/app/data/appointment_model.dart';
import 'package:appointments/app/modules/profile/controllers/profile_controller.dart';
import 'package:appointments/app/services/appointments_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Appointment Status Enum (if needed)
enum AppointmentStatus { pending, completed }

class UserDashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppointmentsService _appointmentsService =
      Get.find<AppointmentsService>();
  final advancedDrawerController = AdvancedDrawerController();
  final RxString username = 'user'.tr.obs;
  final RxList<String> appointments = <String>[].obs;
  final RxList<Map<String, dynamic>> _cities = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> get cities => _cities;

  final RxList<Map<String, dynamic>> _filteredCities =
      <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> get filteredCities => _filteredCities;

  final TextEditingController searchCitiesController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController serviceController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final selectedDate = DateTime.now().obs;
  final selectedTime = TimeOfDay.now().obs;
  final RxString selectedCity = RxString('');

  @override
  void onInit() {
    super.onInit();
    _fetchInitialDemoAppointments();
    fetchCities();
    Get.put(ProfileController());
    searchCitiesController.addListener(() {
      filterCities(searchCitiesController.text);
    });
  }

  @override
  void onClose() {
    searchCitiesController.dispose();
    nameController.dispose();
    phoneController.dispose();
    serviceController.dispose();
    addressController.dispose();
    notesController.dispose();
    super.onClose();
  }

  void _fetchInitialDemoAppointments() {
    appointments.assignAll([
      '${'serviceHaircut'.tr} - 2025-01-10 10:00AM',
      '${'serviceMassage'.tr} - 2025-01-11 02:00PM',
    ]);
  }

  Future<void> fetchCities() async {
    try {
      final snapshot = await _firestore.collection('cities').get();

      final List<Map<String, dynamic>> cityData = snapshot.docs.map((doc) {
        return {
          'name': doc.id,
          'count': doc.data()['appointmentCount'] ?? 0,
        };
      }).toList();

      _cities.value = cityData;
      _filteredCities.value = cityData;

      if (cityData.isNotEmpty) {
        selectedCity.value = cityData.first['name'];
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        '${'fetchCitiesFailed'.tr}: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void filterCities(String query) {
    if (query.isEmpty) {
      _filteredCities.value = List.from(_cities);
    } else {
      _filteredCities.value = _cities
          .where((city) =>
              city['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void addCity() {
    final TextEditingController cityController = TextEditingController();

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
                'addCity'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: cityController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'enterCityName'.tr,
                    hintStyle: const TextStyle(color: Colors.white60),
                    prefixIcon:
                        const Icon(Icons.location_city, color: Colors.white70),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      cityController.clear();
                      Get.back();
                    },
                    child: Text(
                      'cancel'.tr,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final newCity = cityController.text.trim();
                      if (newCity.isNotEmpty) {
                        try {
                          await _firestore
                              .collection('cities')
                              .doc(newCity)
                              .set({'appointmentCount': 0});
                          fetchCities();
                          Get.back();
                          Get.snackbar(
                            'success'.tr,
                            '${'cityAdded'.tr}: "$newCity"',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        } catch (e) {
                          Get.snackbar(
                            'error'.tr,
                            '${'failedAddCity'.tr}: $e',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      } else {
                        Get.snackbar(
                          'error'.tr,
                          'cityNameRequired'.tr,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade900,
                    ),
                    child: Text('add'.tr),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> deleteCity(String city) async {
    try {
      await _firestore.collection('cities').doc(city).delete();
      final appointmentsSnapshot = await _firestore
          .collection('appointments')
          .where('city', isEqualTo: city)
          .get();

      for (var doc in appointmentsSnapshot.docs) {
        await _appointmentsService.deleteAppointment(doc.id, city);
      }

      fetchCities();
      Get.snackbar(
        'success'.tr,
        '${'cityDeleted'.tr}: "$city"',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        '${'failedDeleteCity'.tr}: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
        city: selectedCity.value.isNotEmpty ? selectedCity.value : 'N/A',
      );

      try {
        await _appointmentsService.addAppointment(appointment);
        fetchCities();
        nameController.clear();
        phoneController.clear();
        serviceController.clear();
        addressController.clear();
        notesController.clear();
        selectedDate.value = DateTime.now();
        selectedTime.value = TimeOfDay.now();
        Get.snackbar(
          'success'.tr,
          'appointmentAdded'.tr,
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
    Future<void> deleteSingleAppointment(
      String appointmentId, String city) async {
    try {
      await _appointmentsService.deleteAppointment(appointmentId, city);

      // Optionally re-fetch cities or appointments
      await fetchCities();

      Get.snackbar(
        'success'.tr,
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

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
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
      selectedDate.value = picked;
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value,
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
      selectedTime.value = picked;
    }
  }

  Future<void> updateCityAppointmentsCount(String city, int increment) async {
    try {
      final cityRef = _firestore.collection('cities').doc(city);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(cityRef);
        if (!snapshot.exists) {
          throw Exception('City does not exist');
        }
        final currentCount = snapshot.data()?['appointmentCount'] ?? 0;
        transaction.update(cityRef, {'appointmentCount': currentCount + increment});
      });
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        '${'failedUpdateCityCount'.tr}: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}


