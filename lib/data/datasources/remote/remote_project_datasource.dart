import '../../../domain/models/models.dart';
import '../../../services/supabase_service.dart';

class RemoteProjectDataSource {
  Future<List<ResearchGroup>> getGroups(int supervisorId) async {
    return await SupabaseService.getGroupsBySupervisor(supervisorId);
  }

  Future<Supervisor?> getSupervisor(int id) async {
    return await SupabaseService.getSupervisorById(id);
  }

  Future<List<Student>> getStudents(int groupId) async {
    return await SupabaseService.getGroupStudents(groupId);
  }

  Future<List<ResearchFile>> getFiles(int groupId) async {
    // جلب الملفات من SupabaseService
    // ملاحظة: SupabaseService يعيد List<ProjectFile>، سنقوم بتحويلها إلى ResearchFile (الاسم الموحد في Domain)
    final files = await SupabaseService.getProjectFiles(groupId);
    return files.map((f) => ResearchFile(
      id: f.id,
      groupId: f.groupId,
      fileName: f.fileName,
      fileUrl: f.fileUrl,
      fileType: f.fileType,
      fileSize: f.fileSize,
      uploadedBy: f.uploadedBy,
      uploadedAt: f.uploadedAt,
      supervisorNotes: f.supervisorNotes,
      description: f.description,
      stage: f.fileStage,
    )).toList();
  }

  Future<void> updateProgress(int groupId, double progress) async {
    await SupabaseService.updateGroupStatus(groupId, 'نشط', progress);
  }

  Future<List<ReviewComment>> getMessages(int groupId) async {
    return await SupabaseService.getCommentsByGroup(groupId);
  }

  Future<void> sendMessage(int groupId, int senderId, String message) async {
    await SupabaseService.addProjectFeedback(groupId, senderId, 'عام', message);
  }
}
