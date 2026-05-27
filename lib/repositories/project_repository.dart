import '../models/models.dart';

abstract class ProjectRepository {
  Future<List<ResearchGroup>> getGroupsBySupervisor(int supervisorId);
  Future<Supervisor?> getSupervisorById(int supervisorId);
  Future<ResearchGroup?> getGroupDetails(int projectId);
  Future<List<Student>> getStudentsByGroup(int projectId);
  Future<List<ReviewComment>> getChatMessages(int chatId);
  Future<bool> sendMessage(int chatId, int supervisorId, String text);
  Future<List<Notification>> getNotifications(int supervisorId);
  Future<bool> markNotificationAsRead(int notificationId);
  Future<bool> submitGrade(int projectId, double total, String comment);
}
