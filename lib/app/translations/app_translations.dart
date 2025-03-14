import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': {
          // General
          'hello': 'Hello',
          'welcome': 'Welcome',
          'login': 'Login',
          'logout': 'Logout',
          'search': 'Search',
          'add': 'Add',
          'edit': 'Edit',
          'delete': 'Delete',
          'save': 'Save',
          'cancel': 'Cancel',
          'yes': 'Yes',
          'no': 'No',
          'error': 'Error',
          'success': 'Success',
          'info': 'Info',
          'warning': 'Warning',
          'confirm': 'Confirm',
          'close': 'Close',
          'loading': 'Loading',

          // Loading states
          'loadingData': 'Loading data...',
          'loadingCities': 'Loading cities...',
          'loadingAppointments': 'Loading appointments...',
          'loadingProfile': 'Loading profile...',
          'loadingImage': 'Loading image...',
          'loadingUser': 'Loading user...',
          'loadingUsers': 'Loading users...',
          'loadingSettings': 'Loading settings...',

          // No data states
          'noData': 'No data available',
          'noCities': 'No cities available',
          'noAppointments': 'No appointments available',
          'noProfile': 'No profile available',
          'noImage': 'No image available',
          'noUser': 'No user available',
          'noUsers': 'No users available',
          'noSettings': 'No settings available',

          // Entities
          'user': 'User',
          'admin': 'Admin',
          'role': 'Role',
          'name': 'Name',
          'email': 'Email',
          'phone': 'Phone',
          'address': 'Address',
          'city': 'City',
          'state': 'State',
          'zip': 'Zip',
          'country': 'Country',
          'profile': 'Profile',
          'settings': 'Settings',
          'users': 'Users',
          'appointments': 'Appointments',
          'cities': 'Cities',
          'dashboard': 'Dashboard',

          // Dashboard
          'userDashboard': 'User Dashboard',
          'adminDashboard': 'Admin Dashboard',

          // Actions
          'addUser': 'Add User',
          'editUser': 'Edit User',
          'deleteUser': 'Delete User',
          'addCity': 'Add City',
          'editCity': 'Edit City',
          'deleteCity': 'Delete City',
          'addAppointment': 'Add Appointment',
          'editAppointment': 'Edit Appointment',
          'deleteAppointment': 'Delete Appointment',
          'saveChanges': 'Save Changes',

          // Messages
          'userAdded': 'User added successfully.',
          'userUpdated': 'User updated successfully.',
          'userDeleted': 'User deleted successfully.',
          'errorOccurred': 'An error occurred.',
          'appointmentAdded': 'Appointment added successfully.',
          'appointmentUpdated': 'Appointment updated successfully.',
          'appointmentDeleted': 'Appointment deleted successfully.',
          'cityAdded': 'City added successfully.',
          'cityDeleted': 'City deleted successfully.',
        },
        'ar': {
          // General
          'hello': 'مرحبا',
          'welcome': 'أهلا وسهلا',
          'login': 'تسجيل الدخول',
          'logout': 'تسجيل الخروج',
          'search': 'بحث',
          'add': 'إضافة',
          'edit': 'تعديل',
          'delete': 'حذف',
          'save': 'حفظ',
          'cancel': 'إلغاء',
          'yes': 'نعم',
          'no': 'لا',
          'error': 'خطأ',
          'success': 'نجاح',
          'info': 'معلومة',
          'warning': 'تحذير',
          'confirm': 'تأكيد',
          'close': 'إغلاق',
          'loading': 'جار التحميل',

          // Loading states
          'loadingData': 'جار تحميل البيانات...',
          'loadingCities': 'جار تحميل المدن...',
          'loadingAppointments': 'جار تحميل المواعيد...',
          'loadingProfile': 'جار تحميل الملف الشخصي...',
          'loadingImage': 'جار تحميل الصورة...',
          'loadingUser': 'جار تحميل المستخدم...',
          'loadingUsers': 'جار تحميل المستخدمين...',
          'loadingSettings': 'جار تحميل الإعدادات...',

          // No data states
          'noData': 'لا توجد بيانات',
          'noCities': 'لا توجد مدن',
          'noAppointments': 'لا توجد مواعيد',
          'noProfile': 'لا يوجد ملف شخصي',
          'noImage': 'لا توجد صورة',
          'noUser': 'لا يوجد مستخدم',
          'noUsers': 'لا يوجد مستخدمون',
          'noSettings': 'لا توجد إعدادات',

          // Entities
          'user': 'مستخدم',
          'admin': 'مدير',
          'role': 'الدور',
          'name': 'الاسم',
          'email': 'البريد الإلكتروني',
          'password': 'كلمة المرور',
          'phone': 'الهاتف',
          'address': 'العنوان',
          'city': 'المدينة',
          'state': 'الولاية',
          'zip': 'الرمز البريدي',
          'country': 'البلد',
          'profile': 'الملف الشخصي',
          'settings': 'الإعدادات',
          'users': 'المستخدمون',
          'appointments': ' من المواعيد',
          'cities': 'المدن',
          'dashboard': 'لوحة التحكم',
          "enterCityName": "أدخل اسم المدينة",
          "confirmDeleteCity": "هل أنت متأكد من حذف مدينة",
          "andAppointments": "والمواعيد",
          "callCustomer": "اتصل بالعميل",
          "markAchieved": "وضع علامة منجز",
          "markPostponed": "وضع علامة تأجيل",
          "markRejected": "وضع علامة رفض",
          "deleteAppointment": "حذف الموعد",
          "customer": "العميل",
          "achieved": "منجز",
          "postponed": "مؤجل",
          "rejected": "مرفوض",
          "dateTime": "التاريخ والوقت",
          "pending": "قيد الانتظار",
          "service": "الخدمة",
          "notes": "ملاحظات",
          "sms": "رسالة نصية قصيرة",
          "whatsapp": "واتساب",
          "addAppointment": "إضافة موعد",
          "noAppointmentsFound": "لم يتم العثور على مواعيد",
          "searchCustomerName": "ابحث عن اسم العميل",
          "filterAppointments": "تصفية المواعيد",
          "appointmentsIn": "المواعيد في",
          "failedFetchAppointments": "فشل في جلب المواعيد",
          "statusUpdated": "تم تحديث الحالة",
          "appointmentUpdated": "تم تحديث الموعد",
          "failedUpdateStatus": "فشل تحديث الحالة",
          "appointmentDeleted": "تم حذف الموعد",
          "failedDeleteAppointment": "فشل حذف الموعد",
          "failedOpenWhatsApp": "فشل فتح واتساب",
          "smsUnavailable": "الرسائل النصية غير متاحة",
          "cannotCallNumber": "لا يمكن الاتصال بالرقم",
          "notesOptional": "الملاحظات (اختياري)",
          "addressRequired": "العنوان مطلوب",
          "invalidPhone": "رقم هاتف غير صالح",
          "phoneRequired": "الهاتف مطلوب",
          "phoneNumber": "رقم الهاتف",
          "customerName": "اسم العميل",
          "nameRequired": "الاسم مطلوب",
          "serviceRequired": "الخدمة مطلوبة",
          "clearFilters": "مسح الفلاتر",
          "confirmDeleteAppointment": "هل أنت متأكد من حذف الموعد",
          "deleted": "تم الحذف",
          "appointmentAddedSuccessfully": "تمت إضافة الموعد بنجاح",
          "home": "الرئيسية",

          "confirm_save_changes": "هل تريد حفظ التغييرات؟",
          "save_changes": "حفظ التغييرات",
          "full_name": "الاسم الكامل",
          "profileUpdatedSuccessfully": "تم تحديث الملف الشخصي بنجاح",
          "version": "الإصدار",
          "buildNumber": "رقم البناء",
          "appInfo": "معلومات التطبيق",
          "language": "اللغة",
          "followSystemThemeSettings" : "اتبع إعدادات نظام السمة",
          "useSystemTheme": "استخدام سمة النظام",
          "switchBetweenLightAndDarkTheme": "التبديل بين السمات الفاتحة والداكنة",
          "darkMode": "الوضع الداكن",
          "languageEnglish": "الإنجليزية",
          "languageArabic": "العربية",
          "theme": " السمة",
          "addCity": "إضافة مدينة",
          "addNewUser": "إضافة مستخدم جديد",
          "noUsersFound": "لم يتم العثور على مستخدمين",
          "searchUsers": "ابحث عن مستخدمين",
          "addUser": "إضافة مستخدم",
          "openDrawer": "فتح الدرج",
          "Admin": "مدير",
          "User": "مستخدم",
          "deleteCityConfirmation": "تأكيد حذف المدينة",
          "searchCities": "ابحث عن مدن",
          "listCities": "قائمة المدن",
          

          // Dashboard
          'userDashboard': 'لوحة تحكم المستخدم',
          'adminDashboard': 'لوحة تحكم المدير',

          // Actions
          'editUser': 'تعديل المستخدم',
          'deleteUser': 'حذف المستخدم',
          'editCity': 'تعديل المدينة',
          'deleteCity': 'حذف المدينة',
          'editAppointment': 'تعديل الموعد',
          'saveChanges': 'حفظ التغييرات',

"searchCityCustomerPhone": "ابحث عن رقم هاتف او اسم العميل",
          // Messages
          'userAdded': 'تم إضافة المستخدم بنجاح.',
          'userUpdated': 'تم تحديث المستخدم بنجاح.',
          'userDeleted': 'تم حذف المستخدم بنجاح.',
          'errorOccurred': 'حدث خطأ.',
          'appointmentAdded': 'تمت إضافة الموعد بنجاح.',
          
          'cityAdded': 'تمت إضافة المدينة بنجاح.',
          'cityDeleted': 'تم حذف المدينة بنجاح.',
        },
      };
}
