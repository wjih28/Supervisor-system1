import '../../domain/models/models.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/remote/remote_project_datasource.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final RemoteProjectDataSource remoteDataSource;

  ProjectRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<ResearchGroup>> getGroupsBySupervisor(int supervisorId) async {
    return await remoteDataSource.getGroups(supervisorId);
  }

  @override
  Future<Supervisor?> getSupervisorById(int supervisorId) async {
    return await remoteDataSource.getSupervisor(supervisorId);
  }

  @override
  Future<ResearchGroup?> getGroupDetails(int groupId) async {
    final groups = await remoteDataSource.getGroups(1); // يمكن تحسينها لاحقاً لجلب مجموعة واحدة
    try {
      return groups.firstWhere((g) => g.id == groupId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Student>> getStudentsByGroup(int groupId) async {
    return await remoteDataSource.getStudents(groupId);
  }

  @override
  Future<List<ResearchFile>> getGroupFiles(int groupId) async {
    return await remoteDataSource.getFiles(groupId);
  }

  @override
  Future<void> updateGroupProgress(int groupId, double progress) async {
    await remoteDataSource.updateProgress(groupId, progress);
  }

  @override
  Future<void> submitGrade(int groupId, double grade, String feedback) async {
    // يمكن إضافة تنفيذ رصد الدرجة في SupabaseService لاحقاً
  }

  @override
  Future<List<Notification>> getNotifications(int supervisorId) async {
    // حالياً تعيد قائمة فارغة حتى يتم تجهيز جدول الإشعارات في Supabase
    return [];
  }

  @override
  Future<void> markNotificationAsRead(int notificationId) async {
    // تنفيذ التحديث في Supabase عند توفر الجدول
  }

  @override
  Future<List<ReviewComment>> getChatMessages(int groupId) async {
    return await remoteDataSource.getMessages(groupId);
  }

  @override
  Future<void> sendMessage(int groupId, int senderId, String message) async {
    await remoteDataSource.sendMessage(groupId, senderId, message);
  }
}
