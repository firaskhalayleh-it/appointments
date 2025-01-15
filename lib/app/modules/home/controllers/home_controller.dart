import 'dart:async';
import 'package:appointments/app/data/appointment_model.dart';
import 'package:appointments/app/modules/appointments/controllers/appointments_controller.dart';
import 'package:appointments/app/modules/profile/controllers/profile_controller.dart';
import 'package:appointments/app/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  final searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _citiesWithAppointments = <Map<String, dynamic>>[].obs;
  final _filteredCitiesWithAppointments = <Map<String, dynamic>>[].obs;
  final _searchedAppointments = <AppointmentModel>[].obs;
  final isLoading = false.obs;
  final isSearching = false.obs;

  StreamSubscription<QuerySnapshot>? _citiesSubscription;
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    listenToCities();
    Get.put(ProfileController());
    searchController.addListener(() {
      _onSearchChanged();
      filterCities(searchController.text);
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    _citiesSubscription?.cancel();
    _debounceTimer?.cancel();
    Get.isRegistered<AppointmentsController>()
        ? Get.delete<AppointmentsController>()
        : null;
    super.onClose();
  }

  List<Map<String, dynamic>> get filteredCitiesWithAppointments =>
      _filteredCitiesWithAppointments;

  List<AppointmentModel> get searchedAppointments => _searchedAppointments;

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    if (searchController.text.isNotEmpty) {
      isSearching.value = true;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      performSearch(searchController.text);
    });
  }

  Future<void> performSearch(String query) async {
    if (query.isEmpty) {
      isSearching.value = false;
      _filteredCitiesWithAppointments.value =
          List.from(_citiesWithAppointments);
      _searchedAppointments.clear();
      return;
    }

    isLoading.value = true;
    isSearching.value = true;

    try {
      // Search cities first
      _filteredCitiesWithAppointments.value = _citiesWithAppointments
          .where((city) => city['name']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();

      // Search for customer names with case-insensitive partial match
      final customerNameSnapshot = await _firestore
          .collection('appointments')
          .orderBy('customerName')
          .startAt([query.toLowerCase()]).endAt(
              [query.toLowerCase() + '\uf8ff']).get();

      // Search for phone numbers with partial match
      final phoneSnapshot = await _firestore
          .collection('appointments')
          .orderBy('phoneNumber')
          .startAt([query]).endAt([query + '\uf8ff']).get();

      final Set<String> addedIds = {};
      final List<AppointmentModel> appointments = [];

      // Helper function to add appointments while avoiding duplicates
      void processSnapshot(QuerySnapshot snapshot) {
        for (var doc in snapshot.docs) {
          if (!addedIds.contains(doc.id)) {
            addedIds.add(doc.id);
            final data = doc.data() as Map<String, dynamic>;
            appointments.add(AppointmentModel.fromMap(data, doc.id));
          }
        }
      }

      // Process both search results
      processSnapshot(customerNameSnapshot);
      processSnapshot(phoneSnapshot);

      // Sort appointments by date (newest first)
      appointments.sort((a, b) =>
          DateTime.parse(b.dateTime).compareTo(DateTime.parse(a.dateTime)));

      _searchedAppointments.value = appointments;

      // Update search state based on results
      isSearching.value = appointments.isNotEmpty || query.isNotEmpty;
    } catch (e) {
      print('Search error: $e');
      Get.snackbar(
        'error'.tr,
        '${'searchError'.tr}: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      _searchedAppointments.clear();
      isSearching.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void filterCities(String query) {
    if (query.isEmpty) {
      _filteredCitiesWithAppointments.value =
          List.from(_citiesWithAppointments);
      isSearching.value = false;
    } else {
      _filteredCitiesWithAppointments.value = _citiesWithAppointments
          .where((city) => city['name']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    }
  }

  void listenToCities() {
    _citiesSubscription = _firestore.collection('cities').snapshots().listen(
      (snapshot) {
        final updatedCitiesData = snapshot.docs.map((doc) {
          return {
            'name': doc.id,
            'count': doc['appointmentCount'] ?? 0,
          };
        }).toList();

        _citiesWithAppointments.value = updatedCitiesData;
        if (!isSearching.value) {
          _filteredCitiesWithAppointments.value = updatedCitiesData;
        }
      },
      onError: (e) {
        Get.snackbar(
          'error'.tr,
          '${'failedListenCities'.tr}: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
    );
  }

  void onCitySelected(String cityName) {
    print('Navigating to appointments with city: $cityName');
    Get.isRegistered<AppointmentsController>()
        ? Get.delete<AppointmentsController>()
        : null;

    Get.toNamed('/appointments', arguments: cityName);
    searchController.clear();
    _searchedAppointments.clear();
    isSearching.value = false;
  }

  void showSearchOverlay() {
    isSearching.value = true;
    searchController.clear();
  }

  void hideSearchOverlay() {
    isSearching.value = false;
    searchController.clear();
  }

  Future<void> deleteCity(String city) async {
    try {
      final batch = _firestore.batch();

      final cityRef = _firestore.collection('cities').doc(city);
      batch.delete(cityRef);

      final appointmentsSnapshot = await _firestore
          .collection('appointments')
          .where('city', isEqualTo: city)
          .get();

      for (var doc in appointmentsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

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
          child: SingleChildScrollView(
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
                      prefixIcon: const Icon(Icons.location_city,
                          color: Colors.white70),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
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
                            'emptyCityName'.tr,
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
      ),
    );
  }
}
