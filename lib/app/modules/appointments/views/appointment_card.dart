import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/appointment_model.dart';
import '../controllers/appointments_controller.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final AppointmentsController controller;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    required this.controller,
  }) : super(key: key);

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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        collapsedIconColor: Colors.white,
        iconColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: Get.width * 0.13,
              child: Text(
                appointment.customerName,
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                  color: Colors.white,
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: () =>
                      controller.callCustomer(appointment.phoneNumber),
                  tooltip: 'callCustomer'.tr,
                ),
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => controller.updateAppointmentStatus(
                    appointment.id,
                    'achieved',
                  ),
                  tooltip: 'markAchieved'.tr,
                ),
                IconButton(
                  icon: const Icon(Icons.schedule, color: Colors.orange),
                  onPressed: () => controller.updateAppointmentStatus(
                    appointment.id,
                    'postponed',
                  ),
                  tooltip: 'markPostponed'.tr,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => controller.updateAppointmentStatus(
                    appointment.id,
                    'rejected',
                  ),
                  tooltip: 'markRejected'.tr,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () => _confirmDeletion(context),
                  tooltip: 'deleteAppointment'.tr,
                ),
              ],
            )
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('customer'.tr, appointment.customerName),
                _buildInfoRow(
                  'dateTime'.tr,
                  _formatDateTime(appointment.dateTime),
                ),
                _buildInfoRow('phone'.tr, appointment.phoneNumber),
                _buildInfoRow('service'.tr, appointment.service),
                _buildInfoRow('address'.tr, appointment.address),
                _buildInfoRow('notes'.tr, appointment.notes),
                const SizedBox(height: 16),
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      label: Text(
                        statusText,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: statusColor,
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

  String _formatDateTime(String dateTimeStr) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('MM/dd/yyyy - hh:mm a').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
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
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _confirmDeletion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('deleteAppointment'.tr),
          content: Text('confirmDeleteAppointment'.tr),
          actions: [
            TextButton(
              child: Text('cancel'.tr),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('delete'.tr, style: const TextStyle(color: Colors.red)),
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
