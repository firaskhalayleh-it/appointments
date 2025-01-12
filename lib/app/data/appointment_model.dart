// lib/app/data/appointment_model.dart

enum AppointmentStatus { pending, achieved, postponed, rejected }

class AppointmentModel {
  final String id;
  final String customerName;
  final String phoneNumber;
  final String service;
  final String dateTime; // Correct field name
  final String address;
  final String notes;
  final String status;
  final String city;

  AppointmentModel({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    required this.service,
    required this.dateTime,
    required this.address,
    required this.notes,
    required this.status,
    required this.city,
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> map, String id) {
    return AppointmentModel(
      id: id,
      customerName: map['customerName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      service: map['service'] ?? '',
      dateTime: map['dateTime'] ?? DateTime.now().toIso8601String(),
      address: map['address'] ?? '',
      notes: map['notes'] ?? '',
      status: map['status'] ?? AppointmentStatus.pending.toString().split('.').last,
      city: map['city'] ?? 'Unknown City',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'service': service,
      'dateTime': dateTime, // Ensure correct field name
      'address': address,
      'notes': notes,
      'status': status,
      'city': city,
    };
  }
}
