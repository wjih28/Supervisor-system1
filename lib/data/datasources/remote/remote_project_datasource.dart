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

  Future<List<ProjectFile>> getFiles(int groupId) async {
    // استخدام الدالة الصحيحة الموجودة في SupabaseService
    return await SupabaseService.getProjectFiles(groupId);
  }

  Future<void> updateProgress(int groupId, double progress) async {
    // استخدام الدالة الصحيحة updateGroupStatus
    await SupabaseService.updateGroupStatus(groupId, 'نشط', progress);
  }

  Future<List<ReviewComment>> getMessages(int groupId) async {
    // استخدام الدالة الصحيحة getCommentsByGroup
    return await SupabaseService.getCommentsByGroup(groupId);
  }

  Future<void> sendMessage(int groupId, int senderId, String message) async {
    // استخدام الدالة الصحيحة addProjectFeedback
    await SupabaseService.addProjectFeedback(groupId, senderId, 'عام', message);
  }
}
