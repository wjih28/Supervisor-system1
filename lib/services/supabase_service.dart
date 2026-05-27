import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  static final client = Supabase.instance.client;

  // تسجيل دخول المشرف
  static Future<Map<String, dynamic>?> loginSupervisor(
      String username, String password) async {
    try {
      final response = await client
          .from('supervisor')
          .select()
          .or('sprvsr_username.eq.$username,sprvsr_email.eq.$username')
          .eq('sprvsr_password', password)
          .maybeSingle();

      if (response != null) {
        return {
          'user': Supervisor.fromJson(response),
          'role': 'supervisor',
        };
      }
      return null;
    } catch (e) {
      print('Error logging in supervisor: $e');
      return null;
    }
  }

  // جلب المجموعات التابعة للمشرف
  static Future<List<ResearchGroup>> getGroupsBySupervisor(
      int supervisorId) async {
    try {
      final response =
          await client.from('groups').select().eq('id_sprvsr', supervisorId);

      return (response as List)
          .map((json) => ResearchGroup.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching groups: $e');
      return [];
    }
  }

  // جلب بيانات المشروع بواسطة المعرف
  static Future<ResearchGroup?> getProjectById(int id) async {
    try {
      final response =
          await client.from('groups').select().eq('group_id', id).maybeSingle();

      if (response != null) {
        return ResearchGroup.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error fetching project: $e');
      return null;
    }
  }

  // جلب طلاب مجموعة معينة
  static Future<List<Student>> getGroupStudents(int groupId) async {
    try {
      final response =
          await client.from('student').select().eq('id_group', groupId);

      return (response as List).map((json) => Student.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching group students: $e');
      return [];
    }
  }

  // جلب تعليقات وملاحظات مشروع معين
  static Future<List<ProjectFeedback>> getProjectFeedback(int projectId) async {
    try {
      final response = await client
          .from('review_comments')
          .select()
          .eq('id_group', projectId);

      return (response as List)
          .map((json) => ProjectFeedback.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching project feedback: $e');
      return [];
    }
  }

  // جلب ملفات مشروع معين حسب المرحلة
  static Future<List<ProjectFile>> getProjectFiles(int projectId,
      {String? stage}) async {
    try {
      var query =
          client.from('research_files').select().eq('id_group', projectId);
      if (stage != null) {
        query = query.eq('file_stage', stage);
      }
      final response = await query;
      return (response as List)
          .map((json) => ProjectFile.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching project files: $e');
      return [];
    }
  }

  // جلب بيانات المشرف بواسطة المعرف
  static Future<Supervisor?> getSupervisorById(int id) async {
    try {
      final response = await client
          .from('supervisor')
          .select()
          .eq('sprvsr_id', id)
          .maybeSingle();

      if (response != null) {
        return Supervisor.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error fetching supervisor: $e');
      return null;
    }
  }

  // جلب بيانات البرنامج بواسطة المعرف
  static Future<Program?> getProgramById(int id) async {
    try {
      final response = await client
          .from('program')
          .select()
          .eq('program_id', id)
          .maybeSingle();

      if (response != null) {
        return Program.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error fetching program: $e');
      return null;
    }
  }

  // جلب بيانات القسم بواسطة المعرف
  static Future<Department?> getDepartmentById(int id) async {
    try {
      final response = await client
          .from('department')
          .select()
          .eq('dep_id', id)
          .maybeSingle();

      if (response != null) {
        return Department.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error fetching department: $e');
      return null;
    }
  }

  // تحديث حالة المجموعة ونسبة الإنجاز
  static Future<bool> updateGroupStatus(
      int groupId, String status, double progress) async {
    try {
      await client.from('groups').update({
        'group_status': status,
        'group_progress': progress,
      }).eq('group_id', groupId);
      return true;
    } catch (e) {
      print('Error updating group status: $e');
      return false;
    }
  }

  // تحديث مرحلة المشروع
  static Future<bool> updateProjectStage(int projectId, String stage) async {
    try {
      await client
          .from('groups')
          .update({'current_stage': stage}).eq('group_id', projectId);
      return true;
    } catch (e) {
      print('Error updating project stage: $e');
      return false;
    }
  }

  // إضافة ملاحظة مشرف على ملف
  static Future<bool> addSupervisorNote(int fileId, String note) async {
    try {
      await client
          .from('research_files')
          .update({'supervisor_notes': note}).eq('file_id', fileId);
      return true;
    } catch (e) {
      print('Error adding supervisor note: $e');
      return false;
    }
  }

  // إضافة ملاحظة/تعليق مراجعة على المشروع
  static Future<bool> addProjectFeedback(
      int projectId, int supervisorId, String stage, String comment) async {
    try {
      await client.from('review_comments').insert({
        'id_group': projectId,
        'id_sprvsr': supervisorId,
        'comment_text': comment,
        'comment_stage': stage,
        'is_resolved': false,
      });
      return true;
    } catch (e) {
      print('Error adding project feedback: $e');
      return false;
    }
  }

  // حل ملاحظة/تعليق مراجعة
  static Future<bool> resolveFeedback(int feedbackId) async {
    try {
      await client
          .from('review_comments')
          .update({'is_resolved': true}).eq('comment_id', feedbackId);
      return true;
    } catch (e) {
      print('Error resolving feedback: $e');
      return false;
    }
  }

  // إضافة تعليق مراجعة (كائن)
  static Future<bool> addReviewComment(ReviewComment comment) async {
    try {
      await client.from('review_comments').insert(comment.toJson());
      return true;
    } catch (e) {
      print('Error adding review comment: $e');
      return false;
    }
  }

  // تحديث تعليق مراجعة (كائن)
  static Future<bool> updateReviewComment(ReviewComment comment) async {
    try {
      if (comment.id == null) return false;
      await client
          .from('review_comments')
          .update(comment.toJson())
          .eq('comment_id', comment.id!);
      return true;
    } catch (e) {
      print('Error updating review comment: $e');
      return false;
    }
  }

  // إرسال إشعار
  static Future<bool> sendNotification(Notification notification) async {
    try {
      await client.from('notifications').insert(notification.toJson());
      return true;
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }

  // جلب إحصائيات المشرف
  static Future<Map<String, dynamic>?> getSupervisorStatistics(
      int supervisorId) async {
    try {
      final groups = await getGroupsBySupervisor(supervisorId);
      int total = groups.length;
      int completed = groups.where((g) => g.status == 'completed').length;
      int inProgress = groups.where((g) => g.status == 'in_progress').length;
      int pending = groups.where((g) => g.status == 'pending_approval').length;

      return {
        'totalProjects': total,
        'completedProjects': completed,
        'inProgressProjects': inProgress,
        'pendingProjects': pending,
        'pendingReviews': pending,
      };
    } catch (e) {
      print('Error fetching supervisor statistics: $e');
      return null;
    }
  }

  // جلب التعليقات حسب المجموعة
  static Future<List<ReviewComment>> getCommentsByGroup(int groupId) async {
    try {
      final response =
          await client.from('review_comments').select().eq('id_group', groupId);
      return (response as List)
          .map((json) => ReviewComment.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching comments by group: $e');
      return [];
    }
  }

  // جلب الملفات حسب المجموعة
  static Future<List<ProjectFile>> getFilesByGroup(int groupId) async {
    try {
      final response =
          await client.from('research_files').select().eq('id_group', groupId);
      return (response as List)
          .map((json) => ProjectFile.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching files by group: $e');
      return [];
    }
  }

  // جلب مراحل المشروع
  static Future<List<ProjectStage>> getProjectStages(int groupId) async {
    try {
      // يمكن جلبها من جدول مراحل مخصص أو استنتاجها من البيانات
      return [
        ProjectStage(
            id: 1, name: 'المقترح', status: 'completed', progress: 1.0),
        ProjectStage(
            id: 2, name: 'خطة البحث', status: 'in_progress', progress: 0.7),
        ProjectStage(
            id: 3, name: 'البحث النهائي', status: 'pending', progress: 0.0),
      ];
    } catch (e) {
      print('Error fetching project stages: $e');
      return [];
    }
  }

  // إضافة تعليق
  static Future<bool> addComment(ReviewComment comment) async {
    try {
      await client.from('review_comments').insert(comment.toJson());
      return true;
    } catch (e) {
      print('Error adding comment: $e');
      return false;
    }
  }

  // تحديث تعليق
  static Future<bool> updateComment(
      int commentId, ReviewComment comment) async {
    try {
      await client
          .from('review_comments')
          .update(comment.toJson())
          .eq('comment_id', commentId);
      return true;
    } catch (e) {
      print('Error updating comment: $e');
      return false;
    }
  }

  // حذف تعليق
  static Future<bool> deleteComment(int commentId) async {
    try {
      await client.from('review_comments').delete().eq('comment_id', commentId);
      return true;
    } catch (e) {
      print('Error deleting comment: $e');
      return false;
    }
  }

  // تحديث حالة المرحلة
  static Future<bool> updateStageStatus(
      int stageId, String status, double progress) async {
    try {
      // تحديث في جدول المراحل إذا وجد
      print('Updating stage $stageId to status $status with $progress%');
      return true;
    } catch (e) {
      print('Error updating stage status: $e');
      return false;
    }
  }

  // جلب إعدادات المشرف
  static Future<SupervisorSettings?> getSupervisorSettings(
      int supervisorId) async {
    try {
      final response = await client
          .from('supervisor_settings')
          .select()
          .eq('id_sprvsr', supervisorId)
          .maybeSingle();

      if (response != null) {
        return SupervisorSettings.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error fetching supervisor settings: $e');
      return null;
    }
  }

  // تحديث إعدادات المشرف
  static Future<bool> updateSupervisorSettings(
      SupervisorSettings settings) async {
    try {
      if (settings.id != null) {
        await client
            .from('supervisor_settings')
            .update(settings.toJson())
            .eq('settings_id', settings.id!);
      } else {
        await client.from('supervisor_settings').insert(settings.toJson());
      }
      return true;
    } catch (e) {
      print('Error updating supervisor settings: $e');
      return false;
    }
  }

  // تحديث كلمة مرور المشرف
  static Future<bool> updateSupervisorPassword(
      int supervisorId, String newPassword) async {
    try {
      await client.from('supervisor').update(
          {'sprvsr_password': newPassword}).eq('sprvsr_id', supervisorId);
      return true;
    } catch (e) {
      print('Error updating supervisor password: $e');
      return false;
    }
  }

  // --- دوال الدردشة (Chat Functions) ---

  // جلب المحادثات الخاصة بالمشرف
  static Future<List<Map<String, dynamic>>> getSupervisorChats(
      int supervisorId) async {
    try {
      final response = await client
          .from('chats')
          .select('*, groups(group_name)')
          .eq('id_sprvsr', supervisorId)
          .order('last_message_time', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching supervisor chats: $e');
      return [];
    }
  }

  // جلب رسائل محادثة معينة
  static Future<List<Map<String, dynamic>>> getChatMessages(int chatId) async {
    try {
      final response = await client
          .from('messages')
          .select()
          .eq('id_chat', chatId)
          .order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching chat messages: $e');
      return [];
    }
  }

  // إرسال رسالة جديدة
  static Future<bool> sendMessage(
      int chatId, String text, String senderRole) async {
    try {
      await client.from('messages').insert({
        'id_chat': chatId,
        'message_text': text,
        'sender_role': senderRole,
        'created_at': DateTime.now().toIso8601String(),
      });

      // تحديث وقت آخر رسالة في المحادثة
      await client.from('chats').update({
        'last_message': text,
        'last_message_time': DateTime.now().toIso8601String(),
      }).eq('chat_id', chatId);

      return true;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  // الاستماع للرسائل الجديدة (Real-time)
  static Stream<List<Map<String, dynamic>>> getMessagesStream(int chatId) {
    return client
        .from('messages')
        .stream(primaryKey: ['message_id'])
        .eq('id_chat', chatId)
        .order('created_at', ascending: true);
  }
}
