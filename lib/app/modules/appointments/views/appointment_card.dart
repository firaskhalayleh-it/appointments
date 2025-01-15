import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/appointment_model.dart';
import '../controllers/appointments_controller.dart';
import 'package:intl/intl.dart' as intl;

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final AppointmentsController controller;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    required this.controller,
  }) : super(key: key);

  String _formatPhoneNumber(String phone) {
    if (!phone.startsWith('+')) {
      return '+$phone';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (appointment.status.toLowerCase()) {
      case 'achieved':
        statusColor = Colors.green;
        statusText = 'achieved'.tr;
        break;
      case 'postponed':
        statusColor = Colors.orange;
        statusText = 'postponed'.tr;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'rejected'.tr;
        break;
      default:
        statusColor = Colors.blue;
        statusText = 'pending'.tr;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.15),
      child: ExpansionTile(
        initiallyExpanded: false,
        collapsedIconColor: Colors.white,
        iconColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer name section
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.customerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Action buttons row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildActionIconButton(
                    icon: Icons.call,
                    color: Colors.green,
                    tooltip: 'callCustomer'.tr,
                    onPressed: () =>
                        controller.callCustomer(appointment.phoneNumber),
                  ),
                  _buildActionIconButton(
                    icon: Icons.check_circle,
                    color: Colors.green,
                    tooltip: 'markAchieved'.tr,
                    onPressed: () => controller.updateAppointmentStatus(
                      appointment.id,
                      'achieved',
                    ),
                  ),
                  _buildActionIconButton(
                    icon: Icons.schedule,
                    color: Colors.orange,
                    tooltip: 'markPostponed'.tr,
                    onPressed: () => controller.updateAppointmentStatus(
                      appointment.id,
                      'postponed',
                    ),
                  ),
                  _buildActionIconButton(
                    icon: Icons.cancel,
                    color: Colors.red,
                    tooltip: 'markRejected'.tr,
                    onPressed: () => controller.updateAppointmentStatus(
                      appointment.id,
                      'rejected',
                    ),
                  ),
                  _buildActionIconButton(
                    icon: Icons.delete_outline,
                    color: Colors.white70,
                    tooltip: 'deleteAppointment'.tr,
                    onPressed: () => _confirmDeletion(context),
                  ),
                  _buildActionIconButton(
                    icon: Icons.edit,
                    color: Colors.blue,
                    tooltip: 'editAppointment'.tr,
                    onPressed: () => _editAppointment(context),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Phone number with left-to-right alignment
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.white70, size: 20),
                      const SizedBox(width: 12),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          _formatPhoneNumber(appointment.phoneNumber),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildInfoRow(
                  'dateTime'.tr,
                  _formatDateTime(appointment.dateTime),
                  Icons.calendar_today,
                ),
                _buildInfoRow(
                  'service'.tr,
                  appointment.service,
                  Icons.business_center,
                ),
                _buildInfoRow(
                  'address'.tr,
                  appointment.address,
                  Icons.location_on,
                ),
                _buildInfoRow(
                  'notes'.tr,
                  appointment.notes,
                  Icons.notes,
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.message,
                      label: 'whatsapp'.tr,
                      onPressed: () =>
                          controller.openWhatsApp(appointment.phoneNumber),
                      color: Colors.green.shade700,
                    ),
                    _buildActionButton(
                      icon: Icons.message,
                      label: 'sms'.tr,
                      onPressed: () =>
                          controller.sendSMS(appointment.phoneNumber),
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Rest of the methods remain the same...
  Widget _buildActionIconButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        tooltip: tooltip,
        splashRadius: 24,
      ),
    );
  }

  void _editAppointment(BuildContext context) {
    Get.toNamed(
      '/edit-appointment'
,
      arguments: {
        'appointment': appointment,
        'city': appointment.city,
      },
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeStr);
      return intl.DateFormat('MM/dd/yyyy - hh:mm a').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  void _confirmDeletion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('deleteAppointment'.tr),
          content: Text('confirmDeleteAppointment'.tr),
          actions: [
            TextButton(
              child: Text('cancel'.tr),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'delete'.tr,
                style: const TextStyle(color: Colors.red),
              ),
              onPressed: () {
                controller.deleteAppointment(appointment.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
