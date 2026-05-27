import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';
import 'project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  @override
  Future<List<ResearchGroup>> getGroupsBySupervisor(int supervisorId) {
    return SupabaseService.getGroupsBySupervisor(supervisorId);
  }

  @override
  Future<Supervisor?> getSupervisorById(int supervisorId) {
    return SupabaseService.getSupervisorById(supervisorId);
  }

  @override
  Future<ResearchGroup?> getGroupDetails(int projectId) {
    return SupabaseService.getProjectById(projectId);
  }

  @override
  Future<List<Student>> getStudentsByGroup(int projectId) {
    return SupabaseService.getGroupStudents(projectId);
  }

  @override
  Future<List<ReviewComment>> getChatMessages(int chatId) async {
    final messages = await SupabaseService.getChatMessages(chatId);
    return messages.map((json) {
      return ReviewComment(
        id: json['message_id'],
        groupId: json['id_chat'],
        supervisorId: json['sender_role'] == 'supervisor' ? 1 : null,
        comment: json['message_text'] ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
      );
    }).toList();
  }

  @override
  Future<bool> sendMessage(int chatId, int supervisorId, String text) {
    return SupabaseService.sendMessage(chatId, text, 'supervisor');
  }

  @override
  Future<List<Notification>> getNotifications(int supervisorId) async {
    try {
      final response = await Supabase.instance.client
          .from('notifications')
          .select()
          .eq('id_sprvsr', supervisorId)
          .order('created_at', ascending: false);
      return (response as List)
          .map((json) => Notification.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  @override
  Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': true}).eq('notification_id', notificationId);
      return true;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  @override
  Future<bool> submitGrade(int projectId, double total, String comment) async {
    try {
      await Supabase.instance.client.from('project_grades').insert({
        'id_group': projectId,
        'total_grade': total,
        'comment': comment,
      });
      return true;
    } catch (e) {
      debugPrint('Error submitting grade: $e');
      return false;
    }
  }
}
