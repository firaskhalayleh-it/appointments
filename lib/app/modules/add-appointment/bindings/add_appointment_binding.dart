import 'package:get/get.dart';

import '../controllers/add_appointment_controller.dart';

class AddAppointmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddAppointmentController>(
      () => AddAppointmentController(),
    );
  }
}
