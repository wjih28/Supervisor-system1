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
    return await SupabaseService.getStudentsByGroup(groupId);
  }

  Future<List<ResearchFile>> getFiles(int groupId) async {
    return await SupabaseService.getFilesByGroup(groupId);
  }

  Future<void> updateProgress(int groupId, double progress) async {
    await SupabaseService.updateGroupProgress(groupId, progress);
  }

  Future<List<ReviewComment>> getMessages(int groupId) async {
    return await SupabaseService.getMessagesByGroup(groupId);
  }

  Future<void> sendMessage(int groupId, int senderId, String message) async {
    await SupabaseService.sendMessage(groupId, senderId, message);
  }
}
