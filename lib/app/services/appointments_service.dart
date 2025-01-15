import 'package:appointments/app/data/appointment_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appointments/app/services/notification_service.dart';

class AppointmentsService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final NotificationService _notificationService;

  static const String _errorNegativeCount = 'Cannot reduce appointment count below 0';
  static const String _errorCityNotFound = 'City document not found';
  static const String _errorAppointmentNotFound = 'Appointment not found';

  @override
  void onInit() {
    super.onInit();
    _notificationService = Get.find<NotificationService>();
    initializeService();
  }

  Future<void> initializeService() async {
    try {
      await _firestore.enablePersistence(
        const PersistenceSettings(synchronizeTabs: true),
      );
    } catch (e) {
      debugPrint('AppointmentsService initialization error: $e');
    }
  }

  Stream<List<AppointmentModel>> fetchAppointments(String city, {
    String sortBy = 'dateTime',
    bool descending = false,
  }) {
    return _firestore
        .collection('appointments')
        .where('city', isEqualTo: city)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
            .toList());
  }

  Future<DocumentReference> addAppointment(AppointmentModel appointment) async {
    try {
      DocumentReference? appointmentRef;

      await _firestore.runTransaction<void>((transaction) async {
        // Create appointment reference
        appointmentRef = _firestore.collection('appointments').doc();

        // Get city reference
        DocumentReference cityRef = _firestore.collection('cities').doc(appointment.city);
        DocumentSnapshot citySnapshot = await transaction.get(cityRef);

        // Create city if it doesn't exist
        if (!citySnapshot.exists) {
          transaction.set(cityRef, {
            'appointmentCount': 0,
            'name': appointment.city,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        // Set appointment data
        final appointmentData = {
          ...appointment.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        transaction.set(appointmentRef!, appointmentData);

        // Update city appointment count
        transaction.update(cityRef, {
          'appointmentCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }, timeout: const Duration(seconds: 10));

      // Return the appointment reference
      return appointmentRef!;
    } catch (e) {
      debugPrint('Error adding appointment: $e');
      rethrow;
    }
  }

  Future<void> updateAppointmentStatus(String id, String newStatus) async {
    try {
      final appointmentRef = _firestore.collection('appointments').doc(id);

      await _firestore.runTransaction((transaction) async {
        final appointmentSnap = await transaction.get(appointmentRef);

        if (!appointmentSnap.exists) {
          throw FirebaseException(
            plugin: 'appointments',
            message: _errorAppointmentNotFound,
          );
        }

        // Create appointment model for notification
        final appointment = AppointmentModel.fromMap(
          appointmentSnap.data() as Map<String, dynamic>,
          appointmentSnap.id,
        );

        // Update status
        transaction.update(appointmentRef, {
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Send notification after successful update
        await _notificationService.sendAppointmentNotification(
          appointmentId: appointment.copyWith(status: newStatus).id,
          customerName: appointment.customerName,
          city: appointment.city,
          notificationType: newStatus.toLowerCase(),
        );
      });
    } catch (e) {
      debugPrint('Error updating appointment status: $e');
      rethrow;
    }
  }


  /// Delete an appointment and safely decrement city's appointment count
  Future<void> deleteAppointment(String id, String city) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final appointmentRef = _firestore.collection('appointments').doc(id);
        final cityRef = _firestore.collection('cities').doc(city);

        // Get current documents
        final appointmentSnap = await transaction.get(appointmentRef);
        final citySnap = await transaction.get(cityRef);

        // Validate existence
        if (!appointmentSnap.exists) {
          throw FirebaseException(
            plugin: 'appointments',
            message: _errorAppointmentNotFound,
          );
        }

        if (!citySnap.exists) {
          throw FirebaseException(
            plugin: 'appointments',
            message: _errorCityNotFound,
          );
        }

        // Get current count and validate
        final currentCount = (citySnap.data()
            as Map<String, dynamic>)['appointmentCount'] as int;
        if (currentCount <= 0) {
          throw FirebaseException(
            plugin: 'appointments',
            message: _errorNegativeCount,
          );
        }

        // Perform the deletion and counter update
        transaction.delete(appointmentRef);
        transaction.update(cityRef, {
          'appointmentCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }, timeout: const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Error deleting appointment: $e');
      rethrow;
    }
  }

  /// Get appointment count for a city
  Future<int> getCityAppointmentCount(String city) async {
    try {
      final cityDoc = await _firestore.collection('cities').doc(city).get();
      if (!cityDoc.exists) return 0;
      return (cityDoc.data()?['appointmentCount'] as int?) ?? 0;
    } catch (e) {
      debugPrint('Error getting city appointment count: $e');
      return 0;
    }
  }

  /// Batch update appointments status
  Future<void> batchUpdateAppointmentStatus(
    List<String> appointmentIds,
    String newStatus,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final id in appointmentIds) {
        final ref = _firestore.collection('appointments').doc(id);
        batch.update(ref, {
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error batch updating appointments: $e');
      rethrow;
    }
  }

  /// Get appointments statistics for a city
  Future<Map<String, dynamic>> getCityStatistics(String city) async {
    try {
      final QuerySnapshot appointmentsSnap = await _firestore
          .collection('appointments')
          .where('city', isEqualTo: city)
          .get();

      final Map<String, int> statusCounts = {};
      int totalAppointments = 0;

      for (var doc in appointmentsSnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as String;
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
        totalAppointments++;
      }

      return {
        'total': totalAppointments,
        'statusCounts': statusCounts,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error getting city statistics: $e');
      rethrow;
    }
  }

  // Add this method to AppointmentsService class
  Future<void> updateAppointment(AppointmentModel appointment) async {
    try {
      final appointmentRef =
          _firestore.collection('appointments').doc(appointment.id);

      await _firestore.runTransaction((transaction) async {
        final appointmentSnap = await transaction.get(appointmentRef);

        if (!appointmentSnap.exists) {
          throw FirebaseException(
            plugin: 'appointments',
            message: _errorAppointmentNotFound,
          );
        }

        transaction.update(appointmentRef, {
          ...appointment.toMap(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      debugPrint('Error updating appointment: $e');
      rethrow;
    }
  }
}
