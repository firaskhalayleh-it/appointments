import 'package:get/get.dart';

import '../modules/add-appointment/bindings/add_appointment_binding.dart';
import '../modules/add-appointment/views/add_appointment_view.dart';
import '../modules/appointments/bindings/appointments_binding.dart';
import '../modules/appointments/views/appointments_view.dart';
import '../modules/edit-appointment/bindings/edit_appointment_binding.dart';
import '../modules/edit-appointment/views/edit_appointment_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/user-dashboard/bindings/user_dashboard_binding.dart';
import '../modules/user-dashboard/views/user_dashboard_view.dart';
import '../modules/users/bindings/users_binding.dart';
import '../modules/users/views/users_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.APPOINTMENTS,
      page: () => const AppointmentsView(),
      binding: AppointmentsBinding(),
    ),
    GetPage(
      name: _Paths.ADD_APPOINTMENT,
      page: () => const AddAppointmentView(),
      binding: AddAppointmentBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.USERS,
      page: () => UsersView(),
      binding: UsersBinding(),
    ),
    GetPage(
      name: _Paths.USER_DASHBOARD,
      page: () => const UserDashboardView(),
      binding: UserDashboardBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_APPOINTMENT,
      page: () => const EditAppointmentView(),
      binding: EditAppointmentBinding(),
    ),
  ];
}
