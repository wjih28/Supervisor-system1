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
      return await remoteDataSource.getGroups(1).then((groups) => groups.firstWhere((g) => g.id == groupId));
    }
  }

  @override
  Future<List<Student>> getStudentsByGroup(int groupId) async {
    if (useMock) {
      return await mockDataSource.getMockStudents(groupId);
    } else {
      return await remoteDataSource.getStudents(groupId);
    }
  }

  @override
  Future<List<ProjectFile>> getGroupFiles(int groupId) async {
    if (useMock) {
      // تحويل ResearchFile إلى ProjectFile للمحاكاة
      final mockFiles = await mockDataSource.getMockFiles(groupId);
      return mockFiles.map((f) => ProjectFile(
        id: f.id,
        groupId: f.groupId,
        fileName: f.fileName,
        fileType: f.fileType,
        uploadedBy: f.uploadedBy,
        uploadedAt: f.uploadedAt,
        fileStage: f.stage,
      )).toList();
    } else {
      return await remoteDataSource.getFiles(groupId);
    }
  }

  @override
  Future<void> updateGroupProgress(int groupId, double progress) async {
    if (!useMock) {
      await remoteDataSource.updateProgress(groupId, progress);
    }
  }

  @override
  Future<void> submitGrade(int groupId, double grade, String feedback) async {
    if (!useMock) {
      // يمكن إضافة تنفيذ رصد الدرجة في SupabaseService لاحقاً
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
      return await remoteDataSource.getMessages(groupId);
    }
  }

  @override
  Future<void> sendMessage(int groupId, int senderId, String message) async {
    if (!useMock) {
      await remoteDataSource.sendMessage(groupId, senderId, message);
    }
  }
}
