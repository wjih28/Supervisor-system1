// ignore_for_file: constant_identifier_names

/// ثوابت نظام المشرف
class SupervisorConstants {
  // ============ حالات المشروع ============
  static const String STATUS_PENDING = 'pending';
  static const String STATUS_IN_PROGRESS = 'in_progress';
  static const String STATUS_COMPLETED = 'completed';
  static const String STATUS_DELAYED = 'delayed';

  static const List<String> PROJECT_STATUSES = [
    STATUS_PENDING,
    STATUS_IN_PROGRESS,
    STATUS_COMPLETED,
    STATUS_DELAYED,
  ];

  // ============ أنواع الملاحظات ============
  static const String COMMENT_TYPE_NOTE = 'note';
  static const String COMMENT_TYPE_SUGGESTION = 'suggestion';
  static const String COMMENT_TYPE_ISSUE = 'issue';

  static const List<String> COMMENT_TYPES = [
    COMMENT_TYPE_NOTE,
    COMMENT_TYPE_SUGGESTION,
    COMMENT_TYPE_ISSUE,
  ];

  // ============ أنواع الإشعارات ============
  static const String NOTIFICATION_TYPE_FILE_UPLOAD = 'file_upload';
  static const String NOTIFICATION_TYPE_COMMENT = 'comment';
  static const String NOTIFICATION_TYPE_DEADLINE = 'deadline';
  static const String NOTIFICATION_TYPE_STATUS_CHANGE = 'status_change';

  static const List<String> NOTIFICATION_TYPES = [
    NOTIFICATION_TYPE_FILE_UPLOAD,
    NOTIFICATION_TYPE_COMMENT,
    NOTIFICATION_TYPE_DEADLINE,
    NOTIFICATION_TYPE_STATUS_CHANGE,
  ];

  // ============ أنواع الملفات ============
  static const List<String> SUPPORTED_FILE_TYPES = [
    'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
    'jpg', 'jpeg', 'png', 'gif', 'zip', 'rar',
  ];

  // ============ حدود الملفات ============
  static const int MAX_FILE_SIZE = 50 * 1024 * 1024; // 50 MB
  static const int MAX_FILES_PER_GROUP = 100;

  // ============ مراحل المشروع ============
  static const List<String> PROJECT_STAGES = [
    'المقدمة والخلفية',
    'الدراسة الأدبية',
    'منهجية البحث',
    'جمع البيانات',
    'تحليل النتائج',
    'الخلاصة والتوصيات',
    'المراجعة النهائية',
  ];

  // ============ تقييمات الملاحظات ============
  static const int MIN_RATING = 1;
  static const int MAX_RATING = 5;

  // ============ الألوان ============
  static const String COLOR_PRIMARY = '#2D62ED';
  static const String COLOR_SUCCESS = '#4CAF50';
  static const String COLOR_WARNING = '#FF9800';
  static const String COLOR_ERROR = '#F44336';
  static const String COLOR_INFO = '#2196F3';

  // ============ الرسائل ============
  static const String MSG_LOADING = 'جاري التحميل...';
  static const String MSG_ERROR = 'حدث خطأ. يرجى المحاولة مرة أخرى.';
  static const String MSG_NO_DATA = 'لا توجد بيانات';
  static const String MSG_SUCCESS = 'تم بنجاح';
  static const String MSG_CONFIRM_DELETE = 'هل أنت متأكد من الحذف؟';
  static const String MSG_CONFIRM_UPDATE = 'هل تريد تحديث البيانات؟';

  // ============ الحدود الزمنية ============
  static const Duration CACHE_DURATION = Duration(minutes: 5);
  static const Duration NOTIFICATION_DURATION = Duration(seconds: 3);
  static const Duration ANIMATION_DURATION = Duration(milliseconds: 300);

  // ============ الحدود العددية ============
  static const int MIN_GROUP_NAME_LENGTH = 3;
  static const int MAX_GROUP_NAME_LENGTH = 100;
  static const int MIN_COMMENT_LENGTH = 1;
  static const int MAX_COMMENT_LENGTH = 1000;

  // ============ الفهارس والمعرفات ============
  static const String FILTER_ALL = 'all';
  static const String FILTER_COMPLETED = 'completed';
  static const String FILTER_IN_PROGRESS = 'in_progress';
  static const String FILTER_DELAYED = 'delayed';
  static const String FILTER_PENDING = 'pending';

  // ============ رسائل الخطأ ============
  static const Map<String, String> ERROR_MESSAGES = {
    'network_error': 'خطأ في الاتصال بالشبكة',
    'server_error': 'خطأ في الخادم',
    'invalid_input': 'إدخال غير صحيح',
    'file_too_large': 'حجم الملف كبير جداً',
    'unsupported_file_type': 'نوع الملف غير مدعوم',
    'permission_denied': 'لا توجد صلاحيات كافية',
    'not_found': 'لم يتم العثور على البيانات',
    'duplicate_entry': 'هذا الإدخال موجود بالفعل',
  };

  // ============ رسائل النجاح ============
  static const Map<String, String> SUCCESS_MESSAGES = {
    'comment_added': 'تم إضافة الملاحظة بنجاح',
    'comment_updated': 'تم تحديث الملاحظة بنجاح',
    'comment_deleted': 'تم حذف الملاحظة بنجاح',
    'file_uploaded': 'تم رفع الملف بنجاح',
    'status_updated': 'تم تحديث الحالة بنجاح',
    'data_refreshed': 'تم تحديث البيانات بنجاح',
  };

  // ============ أيقونات الحالات ============
  static const Map<String, String> STATUS_ICONS = {
    'completed': '✓',
    'in_progress': '⏳',
    'delayed': '⚠',
    'pending': '⏱',
  };

  // ============ نسب التقدم ============
  static const double PROGRESS_MINIMAL = 0.1;
  static const double PROGRESS_LOW = 0.25;
  static const double PROGRESS_MEDIUM = 0.5;
  static const double PROGRESS_HIGH = 0.75;
  static const double PROGRESS_COMPLETE = 1.0;

  // ============ معايير التقييم ============
  static const Map<int, String> RATING_LABELS = {
    1: 'ضعيف جداً',
    2: 'ضعيف',
    3: 'متوسط',
    4: 'جيد',
    5: 'ممتاز',
  };

  // ============ معايير الأداء ============
  static const double COMPLETION_RATE_EXCELLENT = 80.0;
  static const double COMPLETION_RATE_GOOD = 60.0;
  static const double COMPLETION_RATE_ACCEPTABLE = 40.0;
  static const double COMPLETION_RATE_POOR = 20.0;

  // ============ الفترات الزمنية ============
  static const int DAYS_TO_DEADLINE_URGENT = 3;
  static const int DAYS_TO_DEADLINE_WARNING = 7;
  static const int DAYS_TO_DEADLINE_NORMAL = 14;

  // ============ أحجام الخطوط ============
  static const double FONT_SIZE_SMALL = 12.0;
  static const double FONT_SIZE_NORMAL = 14.0;
  static const double FONT_SIZE_MEDIUM = 16.0;
  static const double FONT_SIZE_LARGE = 18.0;
  static const double FONT_SIZE_EXTRA_LARGE = 24.0;

  // ============ المسافات ============
  static const double SPACING_SMALL = 8.0;
  static const double SPACING_NORMAL = 16.0;
  static const double SPACING_MEDIUM = 24.0;
  static const double SPACING_LARGE = 32.0;

  // ============ نصف القطر ============
  static const double BORDER_RADIUS_SMALL = 4.0;
  static const double BORDER_RADIUS_NORMAL = 8.0;
  static const double BORDER_RADIUS_MEDIUM = 12.0;
  static const double BORDER_RADIUS_LARGE = 16.0;
  static const double BORDER_RADIUS_CIRCLE = 50.0;
}
