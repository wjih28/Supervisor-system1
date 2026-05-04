import '../../../domain/models/models.dart';

class MockProjectDataSource {
  Future<List<ResearchGroup>> getMockGroups(int supervisorId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      ResearchGroup(
        id: 1,
        name: "نظام إدارة المستشفيات الذكي",
        supervisorId: supervisorId,
        description: "مشروع يهدف لأتمتة العمليات الإدارية في المستشفيات باستخدام تقنيات الذكاء الاصطناعي.",
        progress: 65.0,
        status: "نشط",
        currentStage: "التنفيذ",
      ),
      ResearchGroup(
        id: 2,
        name: "تطبيق تعلم اللغة العربية للأطفال",
        supervisorId: supervisorId,
        description: "تطبيق تفاعلي لتعليم الحروف والكلمات للأطفال في سن ما قبل المدرسة.",
        progress: 30.0,
        status: "نشط",
        currentStage: "التصميم",
      ),
      ResearchGroup(
        id: 3,
        name: "منصة تداول العملات الرقمية",
        supervisorId: supervisorId,
        description: "دراسة وتحليل سوق العملات الرقمية وتطوير خوارزميات للتنبؤ بالأسعار.",
        progress: 90.0,
        status: "مكتمل",
        currentStage: "المناقشة",
      ),
    ];
  }

  Future<Supervisor> getMockSupervisor(int id) async {
    return Supervisor(
      id: id,
      name: "د. أحمد محمد علي",
      email: "ahmed@university.edu",
      isActive: true,
      programId: 1,
    );
  }

  Future<List<Student>> getMockStudents(int groupId) async {
    return [
      Student(id: 1, name: "خالد منصور", email: "khaled@student.com", groupId: groupId),
      Student(id: 2, name: "سارة العتيبي", email: "sara@student.com", groupId: groupId),
      Student(id: 3, name: "فهد القحطاني", email: "fahad@student.com", groupId: groupId),
    ];
  }

  Future<List<ResearchFile>> getMockFiles(int groupId) async {
    return [
      ResearchFile(
        id: 1,
        groupId: groupId,
        fileName: "المقترح البحثي.pdf",
        fileType: "pdf",
        uploadedBy: "خالد منصور",
        uploadedAt: DateTime.now().subtract(const Duration(days: 10)),
        stage: "المقترح",
      ),
      ResearchFile(
        id: 2,
        groupId: groupId,
        fileName: "تقرير التحليل.docx",
        fileType: "docx",
        uploadedBy: "سارة العتيبي",
        uploadedAt: DateTime.now().subtract(const Duration(days: 5)),
        stage: "التحليل",
      ),
    ];
  }

  Future<List<Notification>> getMockNotifications(int supervisorId) async {
    return [
      Notification(
        id: 1,
        supervisorId: supervisorId,
        title: "تحديث جديد",
        message: "قام فريق 'نظام إدارة المستشفيات' برفع ملف جديد: تقرير التحليل",
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      Notification(
        id: 2,
        supervisorId: supervisorId,
        title: "موعد مناقشة",
        message: "تم تحديد موعد مناقشة مشروع 'منصة التداول' غداً الساعة 10 صباحاً",
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];
  }

  Future<List<ReviewComment>> getMockMessages(int groupId) async {
    return [
      ReviewComment(
        id: 1,
        groupId: groupId,
        supervisorId: 1,
        comment: "مرحباً يا شباب، كيف حال التقدم في مرحلة التحليل؟",
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ReviewComment(
        id: 2,
        groupId: groupId,
        comment: "أهلاً دكتور، لقد انتهينا من جمع المتطلبات ونقوم الآن برسم المخططات.",
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}
