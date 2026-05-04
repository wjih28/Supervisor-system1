import '../../domain/models/models.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/mock/mock_project_datasource.dart';
import '../datasources/remote/remote_project_datasource.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final MockProjectDataSource mockDataSource;
  final RemoteProjectDataSource remoteDataSource;
  final bool useMock;

  ProjectRepositoryImpl({
    required this.mockDataSource,
    required this.remoteDataSource,
    this.useMock = true,
  });

  @override
  Future<List<ResearchGroup>> getGroupsBySupervisor(int supervisorId) async {
    if (useMock) {
      return await mockDataSource.getMockGroups(supervisorId);
    } else {
      return await remoteDataSource.getGroups(supervisorId);
    }
  }

  @override
  Future<Supervisor?> getSupervisorById(int supervisorId) async {
    if (useMock) {
      return await mockDataSource.getMockSupervisor(supervisorId);
    } else {
      return await remoteDataSource.getSupervisor(supervisorId);
    }
  }

  @override
  Future<ResearchGroup?> getGroupDetails(int groupId) async {
    if (useMock) {
      final groups = await mockDataSource.getMockGroups(1);
      return groups.firstWhere((g) => g.id == groupId);
    } else {
      // تنفيذ جلب تفاصيل المجموعة من Supabase
      return null;
    }
  }

  @override
  Future<List<Student>> getStudentsByGroup(int groupId) async {
    if (useMock) {
      return await mockDataSource.getMockStudents(groupId);
    } else {
      // تنفيذ جلب الطلاب من Supabase
      return [];
    }
  }

  @override
  Future<List<ResearchFile>> getGroupFiles(int groupId) async {
    if (useMock) {
      return await mockDataSource.getMockFiles(groupId);
    } else {
      // تنفيذ جلب الملفات من Supabase
      return [];
    }
  }

  @override
  Future<void> updateGroupProgress(int groupId, double progress) async {
    if (!useMock) {
      // تنفيذ التحديث في Supabase
    }
  }

  @override
  Future<void> submitGrade(int groupId, double grade, String feedback) async {
    if (!useMock) {
      // تنفيذ رصد الدرجة في Supabase
    }
  }

  @override
  Future<List<Notification>> getNotifications(int supervisorId) async {
    if (useMock) {
      return await mockDataSource.getMockNotifications(supervisorId);
    } else {
      return await mockDataSource.getMockNotifications(supervisorId);
    }
  }

  @override
  Future<void> markNotificationAsRead(int notificationId) async {
    if (!useMock) {
      // تنفيذ التحديث في Supabase
    }
  }

  @override
  Future<List<ReviewComment>> getChatMessages(int groupId) async {
    if (useMock) {
      return await mockDataSource.getMockMessages(groupId);
    } else {
      // تنفيذ جلب الرسائل من Supabase
      return [];
    }
  }

  @override
  Future<void> sendMessage(int groupId, int senderId, String message) async {
    if (!useMock) {
      // تنفيذ إرسال الرسالة في Supabase
    }
  }
}
