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
    return await SupabaseService.getFilesByGroup(groupId);
  }

  Future<void> updateProgress(int groupId, double progress) async {
    // استخدام الحالة الافتراضية 'نشط' عند تحديث النسبة
    await SupabaseService.updateGroupStatus(groupId, 'نشط', progress);
  }

  Future<List<ReviewComment>> getMessages(int groupId) async {
    return await SupabaseService.getCommentsByGroup(groupId);
  }

  Future<void> sendMessage(int groupId, int senderId, String message) async {
    // إرسال رسالة كمراجعة في المرحلة الحالية
    await SupabaseService.addProjectFeedback(groupId, senderId, 'عام', message);
  }
}
