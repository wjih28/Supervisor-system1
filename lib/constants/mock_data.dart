import '../models/models.dart';

class MockData {
  static List<Supervisor> supervisors = [
    Supervisor(
      id: 1,
      name: 'محمد أحمد الشامي',
      email: 'dr_mohammed@example.com',
      username: 'dr_mohammed',
      password: 'password123',
      isActive: true,
      programId: 1,
    ),
  ];

  static List<ResearchGroup> groups = [
    ResearchGroup(
      id: 1,
      name: 'تأثير التسويق الرقمي على سلوك المستهلك',
      supervisorId: 1,
      progress: 68,
      currentStage: 'المرحلة الثالثة: مناقشة الخطة',
      status: 'قيد التنفيذ',
      description: 'يهدف هذا البحث إلى دراسة تأثير استراتيجيات التسويق الرقمي على سلوك المستهلك في السوق اليمني، من خلال تحليل أنماط الشراء الإلكتروني والعوامل المؤثرة في قرارات الشراء عبر المنصات الرقمية.',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    ResearchGroup(
      id: 2,
      name: 'دور الذكاء الاصطناعي في تطوير الأعمال',
      supervisorId: 1,
      progress: 45,
      currentStage: 'المرحلة الثانية: إنجاز الخطة',
      status: 'قيد التنفيذ',
      description: 'دراسة التحديات والفرص لقطاع التجارة الإلكترونية.',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    ResearchGroup(
      id: 3,
      name: 'إدارة الموارد البشرية في المؤسسات الحديثة',
      supervisorId: 1,
      progress: 85,
      currentStage: 'المرحلة الرابعة: إنجاز الدراسات الميدانية',
      status: 'قيد التنفيذ',
      description: 'تطوير استراتيجيات الموارد البشرية لمواكبة التغيرات.',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  static List<Student> students = [
    // Group 1: تأثير التسويق الرقمي
    Student(id: 1, name: 'أحمد محمد علي', groupId: 1, username: '2021001', role: 'قائد الفريق'),
    Student(id: 2, name: 'فاطمة سعيد حسن', groupId: 1, username: '2021002', role: 'عضو'),
    Student(id: 3, name: 'خالد عبدالله محمد', groupId: 1, username: '2021003', role: 'عضو'),
    Student(id: 4, name: 'نورا إبراهيم أحمد', groupId: 1, username: '2021004', role: 'عضو'),

    // Group 2: دور الذكاء الاصطناعي
    Student(id: 5, name: 'عمر سالم باسليم', groupId: 2, username: '2021005', role: 'قائد الفريق'),
    Student(id: 6, name: 'سارة علي محسن', groupId: 2, username: '2021006', role: 'عضو'),
    Student(id: 7, name: 'محمد حسين عبده', groupId: 2, username: '2021007', role: 'عضو'),

    // Group 3: إدارة الموارد البشرية
    Student(id: 8, name: 'ريم أحمد القاضي', groupId: 3, username: '2021008', role: 'قائد الفريق'),
  ];

  static List<ProjectFile> files = [
    ProjectFile(
      id: 1,
      groupId: 1,
      fileName: 'خطة البحث الأولية.pdf',
      fileUrl: 'https://example.com/file1.pdf',
      fileType: 'pdf',
      uploadedBy: 'student',
      uploadedAt: DateTime.now().subtract(const Duration(days: 10)),
      stage: 'خطة البحث',
    ),
  ];

  static List<ReviewComment> comments = [
    ReviewComment(
      id: 1,
      groupId: 1,
      supervisorId: 1,
      comment: 'يرجى مراجعة المصادر في الفصل الأول',
      stage: 'خطة البحث',
      isResolved: false,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
  
  static List<AppNotification> notifications = [
    AppNotification(
      id: 1,
      supervisorId: 1,
      title: 'تم رفع ملف جديد',
      message: "قام الطالب أحمد محمد برفع مسودة خطة البحث لمشروع 'تأثير التسويق الرقمي على سلوك المستهلك'.",
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AppNotification(
      id: 2,
      supervisorId: 1,
      title: 'طلب اعتماد مرحلة',
      message: "طلب اعتماد المرحلة الثانية (إنجاز الخطة) من فريق 'دور الذكاء الاصطناعي في تطوير الأعمال'.",
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AppNotification(
      id: 3,
      supervisorId: 1,
      title: 'رسالة دردشة جديدة',
      message: "رسالة جديدة في الدردشة من قائد فريق 'إدارة الموارد البشرية في المؤسسات الحديثة'.",
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AppNotification(
      id: 4,
      supervisorId: 1,
      title: 'تذكير برصد الدرجات',
      message: "تذكير: يرجى رصد الدرجات النهائية لمشروع 'تأثير التسويق الرقمي على سلوك المستهلك'.",
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    AppNotification(
      id: 5,
      supervisorId: 1,
      title: 'تم حل الملاحظات',
      message: "قام الطلاب في فريق 'دور الذكاء الاصطناعي' بحل الملاحظات التي تم إضافتها على خطة البحث.",
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];
}
