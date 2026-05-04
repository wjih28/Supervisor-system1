import '../models/models.dart';

abstract class ProjectRepository {
  // Supervisor & Groups
  Future<List<ResearchGroup>> getGroupsBySupervisor(int supervisorId);
  Future<Supervisor?> getSupervisorById(int supervisorId);
  Future<ResearchGroup?> getGroupDetails(int groupId);
  
  // Students
  Future<List<Student>> getStudentsByGroup(int groupId);
  
  // Files & Grades
  Future<List<ProjectFile>> getGroupFiles(int groupId);
  Future<void> updateGroupProgress(int groupId, double progress);
  Future<void> submitGrade(int groupId, double grade, String feedback);
  
  // Notifications
  Future<List<Notification>> getNotifications(int supervisorId);
  Future<void> markNotificationAsRead(int notificationId);
  
  // Chats
  Future<List<ReviewComment>> getChatMessages(int groupId);
  Future<void> sendMessage(int groupId, int senderId, String message);
}
