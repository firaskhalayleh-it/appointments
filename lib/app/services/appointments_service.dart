import 'package:appointments/app/data/appointment_model.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentsService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch appointments for a specific city with real-time updates
  Stream<List<AppointmentModel>> fetchAppointments(String city) {
    return _firestore
        .collection('appointments')
        .where('city', isEqualTo: city)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return AppointmentModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
            }).toList());
  }

  /// Add a new appointment and increment city’s appointment count
  Future<void> addAppointment(AppointmentModel appointment) async {
    try {
      // Use a WriteBatch so that the appointment creation
      // and city increment happen atomically
      WriteBatch batch = _firestore.batch();

      // Create a new doc reference for the appointment
      DocumentReference appointmentRef =
          _firestore.collection('appointments').doc();

      // Add the appointment data
      batch.set(appointmentRef, appointment.toMap());

      // Increment the city’s appointmentCount field
      DocumentReference cityRef =
          _firestore.collection('cities').doc(appointment.city);

      // If the city document might not exist, you may want to create it if it doesn’t:
      // batch.set(cityRef, {'appointmentCount': 0}, SetOptions(merge: true));

      batch.update(cityRef, {
        'appointmentCount': FieldValue.increment(1),
      });

      // Commit the batch
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Update the status of an existing appointment (e.g., from 'pending' to 'completed')
  Future<void> updateAppointmentStatus(String id, String newStatus) async {
    try {
      await _firestore
          .collection('appointments')
          .doc(id)
          .update({'status': newStatus});
    } catch (e) {
      rethrow;
    }
  }

  /// Delete an appointment and decrement city’s appointment count
  Future<void> deleteAppointment(String id, String city) async {
    try {
      // Use a WriteBatch to ensure both the appointment deletion
      // and the decrement on the city’s count happen atomically
      WriteBatch batch = _firestore.batch();

      DocumentReference appointmentRef =
          _firestore.collection('appointments').doc(id);
      batch.delete(appointmentRef);

      DocumentReference cityRef = _firestore.collection('cities').doc(city);
      batch.update(cityRef, {
        'appointmentCount': FieldValue.increment(-1),
      });

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }
}
