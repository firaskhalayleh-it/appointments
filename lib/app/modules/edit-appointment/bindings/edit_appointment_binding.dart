import 'package:get/get.dart';

import '../controllers/edit_appointment_controller.dart';

class EditAppointmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditAppointmentController>(
      () => EditAppointmentController(),
    );
  }
}
