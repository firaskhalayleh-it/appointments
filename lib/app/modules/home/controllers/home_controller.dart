import 'dart:async';

import 'package:appointments/app/modules/profile/controllers/profile_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  final searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _citiesWithAppointments = <Map<String, dynamic>>[].obs;
  final _filteredCitiesWithAppointments = <Map<String, dynamic>>[].obs;

  StreamSubscription<QuerySnapshot>? _citiesSubscription;

  @override
  void onInit() {
    super.onInit();
    listenToCities();
    Get.put(ProfileController());
    searchController.addListener(() {
      filterCities(searchController.text);
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    _citiesSubscription?.cancel();
    super.onClose();
  }

  List<Map<String, dynamic>> get filteredCitiesWithAppointments =>
      _filteredCitiesWithAppointments;

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
        filterCities(searchController.text);
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

  void filterCities(String query) {
    if (query.isEmpty) {
      _filteredCitiesWithAppointments.value =
          List.from(_citiesWithAppointments);
    } else {
      _filteredCitiesWithAppointments.value = _citiesWithAppointments
          .where((city) =>
              city['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void onCitySelected(String city) {
    print('${'selectedCity'.tr}: $city');
    Get.toNamed('/appointments', arguments: city);
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

