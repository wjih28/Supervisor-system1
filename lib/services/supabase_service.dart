import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../constants/mock_data.dart';

class SupabaseService {
  // static final client = Supabase.instance.client;

  static Future<Map<String, dynamic>?> loginSupervisor(
      String username, String password) async {
    // محاكاة تسجيل الدخول
    final supervisor = MockData.supervisors.firstWhere(
      (s) => s.username == username && s.password == password,
      orElse: () => throw Exception('User not found'),
    );

    return {
      'user': supervisor,
      'role': 'supervisor',
    };
    /*
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
      debugPrint('Error logging in supervisor: $e');
      return null;
    }
    */
  }

  static Future<List<ResearchGroup>> getGroupsBySupervisor(
      int supervisorId) async {
    return MockData.groups.where((g) => g.supervisorId == supervisorId).toList();
    /*
    try {
      final response =
          await client.from('groups').select().eq('id_sprvsr', supervisorId);

      return (response as List)
          .map((json) => ResearchGroup.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching groups: $e');
      return [];
    }
    */
  }

  static Future<ResearchGroup?> getProjectById(int id) async {
    return MockData.groups.firstWhere((g) => g.id == id, orElse: () => MockData.groups.first);
    /*
    try {
      final response =
          await client.from('groups').select().eq('group_id', id).maybeSingle();

      if (response != null) {
        return ResearchGroup.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching project: $e');
      return null;
    }
    */
  }

  static Future<List<Student>> getGroupStudents(int groupId) async {
    return MockData.students.where((s) => s.groupId == groupId).toList();
    /*
    try {
      final response =
          await client.from('student').select().eq('id_group', groupId);

      return (response as List).map((json) => Student.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching group students: $e');
      return [];
    }
    */
  }

  static Future<List<ProjectFeedback>> getProjectFeedback(int projectId) async {
    return []; // لم نقم بإنشاء بيانات وهمية للـ Feedback بعد
    /*
    try {
      final response = await client
          .from('review_comments')
          .select()
          .eq('id_group', projectId);

      return (response as List)
          .map((json) => ProjectFeedback.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching project feedback: $e');
      return [];
    }
    */
  }

  static Future<List<ProjectFile>> getProjectFiles(int projectId,
      {String? stage}) async {
    var files = MockData.files.where((f) => f.groupId == projectId).toList();
    if (stage != null) {
      files = files.where((f) => f.stage == stage).toList();
    }
    return files;
    /*
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
      debugPrint('Error fetching project files: $e');
      return [];
    }
    */
  }

  static Future<Supervisor?> getSupervisorById(int id) async {
    return MockData.supervisors.firstWhere((s) => s.id == id, orElse: () => MockData.supervisors.first);
    /*
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
      debugPrint('Error fetching supervisor: $e');
      return null;
    }
    */
  }

  static Future<Program?> getProgramById(int id) async {
    return Program(id: 1, name: 'علوم الحاسب');
    /*
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
      debugPrint('Error fetching program: $e');
      return null;
    }
    */
  }

  static Future<Department?> getDepartmentById(int id) async {
    return Department(id: 1, name: 'تقنية المعلومات');
    /*
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
      debugPrint('Error fetching department: $e');
      return null;
    }
    */
  }

  static Future<bool> updateGroupStatus(
      int groupId, String status, double progress) async {
    try {
      final index = MockData.groups.indexWhere((g) => g.id == groupId);
      if (index != -1) {
        MockData.groups[index].status = status;
        MockData.groups[index].progress = progress;
        return true;
      }
      return false;
      /*
      await client.from('groups').update({
        'group_status': status,
        'group_progress': progress,
      }).eq('group_id', groupId);
      return true;
      */
    } catch (e) {
      debugPrint('Error updating group status: $e');
      return false;
    }
  }

  static Future<bool> updateProjectStage(int projectId, String stage) async {
    try {
      final index = MockData.groups.indexWhere((g) => g.id == projectId);
      if (index != -1) {
        MockData.groups[index] = MockData.groups[index].copyWith(currentStage: stage);
        return true;
      }
      return false;
      /*
      await client
          .from('groups')
          .update({'current_stage': stage}).eq('group_id', projectId);
      return true;
      */
    } catch (e) {
      debugPrint('Error updating project stage: $e');
      return false;
    }
  }

  static Future<bool> addSupervisorNote(int fileId, String note) async {
    try {
      final index = MockData.files.indexWhere((f) => f.id == fileId);
      if (index != -1) {
        final oldFile = MockData.files[index];
        MockData.files[index] = ProjectFile(
          id: oldFile.id,
          groupId: oldFile.groupId,
          fileName: oldFile.fileName,
          fileUrl: oldFile.fileUrl,
          fileType: oldFile.fileType,
          fileSize: oldFile.fileSize,
          uploadedBy: oldFile.uploadedBy,
          uploadedAt: oldFile.uploadedAt,
          supervisorNotes: note,
          description: oldFile.description,
          stage: oldFile.stage,
        );
        return true;
      }
      return false;
      /*
      await client
          .from('research_files')
          .update({'supervisor_notes': note}).eq('file_id', fileId);
      return true;
      */
    } catch (e) {
      debugPrint('Error adding supervisor note: $e');
      return false;
    }
  }

  static Future<bool> addProjectFeedback(
      int projectId, int supervisorId, String stage, String comment) async {
    try {
      MockData.comments.add(ReviewComment(
        id: MockData.comments.length + 1,
        groupId: projectId,
        supervisorId: supervisorId,
        comment: comment,
        stage: stage,
        isResolved: false,
        createdAt: DateTime.now(),
      ));
      return true;
      /*
      await client.from('review_comments').insert({
        'id_group': projectId,
        'id_sprvsr': supervisorId,
        'comment_text': comment,
        'comment_stage': stage,
        'is_resolved': false,
      });
      return true;
      */
    } catch (e) {
      debugPrint('Error adding project feedback: $e');
      return false;
    }
  }

  // حل ملاحظة/تعليق مراجعة
  static Future<bool> resolveFeedback(int feedbackId) async {
    return true;
  }

  // إضافة تعليق مراجعة (كائن)
  static Future<bool> addReviewComment(ReviewComment comment) async {
    MockData.comments.add(comment);
    return true;
  }

  // تحديث تعليق مراجعة (كائن)
  static Future<bool> updateReviewComment(ReviewComment comment) async {
    final index = MockData.comments.indexWhere((c) => c.id == comment.id);
    if (index != -1) {
      MockData.comments[index] = comment;
      return true;
    }
    return false;
  }

  // إرسال إشعار
  static Future<bool> sendNotification(AppNotification notification) async {
    return true;
  }

  static Future<Map<String, dynamic>?> getSupervisorStatistics(
      int supervisorId) async {
    final groups = MockData.groups.where((g) => g.supervisorId == supervisorId).toList();
    int total = groups.length;
    int completed = groups.where((g) => g.status == 'completed').length;
    int inProgress = groups.where((g) => g.status == 'in_progress').length;
    int pending = groups.where((g) => g.status == 'pending').length;

    return {
      'totalProjects': total,
      'completedProjects': completed,
      'inProgressProjects': inProgress,
      'pendingProjects': pending,
      'pendingReviews': pending,
    };
  }

  static Future<List<ReviewComment>> getCommentsByGroup(int groupId) async {
    return MockData.comments.where((c) => c.groupId == groupId).toList();
  }

  static Future<List<ProjectFile>> getFilesByGroup(int groupId) async {
    return MockData.files.where((f) => f.groupId == groupId).toList();
  }

  static Future<List<ProjectStage>> getProjectStages(int groupId) async {
    try {
      return [
        ProjectStage(id: 1, name: 'المرحلة الأولى: اختيار عنوان البحث', status: 'completed', progress: 1.0, startDate: DateTime(2025, 9, 1), endDate: DateTime(2025, 9, 15)),
        ProjectStage(id: 2, name: 'المرحلة الثانية: إنجاز الخطة', status: 'completed', progress: 1.0, startDate: DateTime(2025, 9, 16), endDate: DateTime(2025, 10, 1)),
        ProjectStage(id: 3, name: 'المرحلة الثالثة: مناقشة الخطة', status: 'in_progress', progress: 0.6, startDate: DateTime(2025, 10, 2), endDate: DateTime(2025, 10, 15)),
        ProjectStage(id: 4, name: 'المرحلة الرابعة: إنجاز الدراسات الميدانية', status: 'in_progress', progress: 0.0, startDate: DateTime(2025, 10, 16), endDate: DateTime(2025, 11, 30)),
        ProjectStage(id: 5, name: 'المرحلة الخامسة: إنجاز مشروع البحث', status: 'pending', progress: 0.0, startDate: DateTime(2025, 12, 1), endDate: DateTime(2025, 12, 20)),
        ProjectStage(id: 6, name: 'المرحلة السادسة: مناقشة البحث', status: 'pending', progress: 0.0, startDate: DateTime(2025, 12, 21), endDate: DateTime(2025, 12, 28)),
        ProjectStage(id: 7, name: 'المرحلة السابعة: تسليم البحث', status: 'pending', progress: 0.0, startDate: DateTime(2025, 12, 29), endDate: DateTime(2026, 1, 10)),
      ];
    } catch (e) {
      debugPrint('Error fetching project stages: $e');
      return [];
    }
  }

  static Future<bool> addComment(ReviewComment comment) async {
    MockData.comments.add(comment);
    return true;
    /*
    try {
      await client.from('review_comments').insert(comment.toJson());
      return true;
    } catch (e) {
      debugPrint('Error adding comment: $e');
      return false;
    }
    */
  }

  static Future<bool> updateComment(
      int commentId, ReviewComment comment) async {
    final index = MockData.comments.indexWhere((c) => c.id == commentId);
    if (index != -1) {
      MockData.comments[index] = comment;
      return true;
    }
    return false;
    /*
    try {
      await client
          .from('review_comments')
          .update(comment.toJson())
          .eq('comment_id', commentId);
      return true;
    } catch (e) {
      debugPrint('Error updating comment: $e');
      return false;
    }
    */
  }

  static Future<bool> deleteComment(int commentId) async {
    MockData.comments.removeWhere((c) => c.id == commentId);
    return true;
    /*
    try {
      await client.from('review_comments').delete().eq('comment_id', commentId);
      return true;
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      return false;
    }
    */
  }

  // تحديث حالة المرحلة
  static Future<bool> updateStageStatus(
      int stageId, String status, double progress) async {
    try {
      debugPrint('Updating stage $stageId to status $status with $progress%');
      return true;
    } catch (e) {
      debugPrint('Error updating stage status: $e');
      return false;
    }
  }

  static Future<SupervisorSettings?> getSupervisorSettings(
      int supervisorId) async {
    return SupervisorSettings(
      id: 1,
      supervisorId: supervisorId,
      emailNotifications: true,
      language: 'العربية',
    );
    /*
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
      debugPrint('Error fetching supervisor settings: $e');
      return null;
    }
    */
  }

  static Future<bool> updateSupervisorSettings(
      SupervisorSettings settings) async {
    return true;
    /*
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
      debugPrint('Error updating supervisor settings: $e');
      return false;
    }
    */
  }

  static Future<bool> updateSupervisorPassword(
      int supervisorId, String newPassword) async {
    return true;
    /*
    try {
      await client.from('supervisor').update(
          {'sprvsr_password': newPassword}).eq('sprvsr_id', supervisorId);
      return true;
    } catch (e) {
      debugPrint('Error updating supervisor password: $e');
      return false;
    }
    */
  }

  // --- دوال الإشعارات ---

  static Future<List<AppNotification>> getNotifications(
      int supervisorId) async {
    return MockData.notifications.where((n) => n.supervisorId == supervisorId).toList();
  }

  static Future<bool> markNotificationAsRead(int notificationId) async {
    final index = MockData.notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final old = MockData.notifications[index];
      MockData.notifications[index] = AppNotification(
        id: old.id,
        supervisorId: old.supervisorId,
        title: old.title,
        message: old.message,
        createdAt: old.createdAt,
        isRead: true,
      );
      return true;
    }
    return false;
  }

  static Future<bool> markAllNotificationsAsRead(int supervisorId) async {
    for (int i = 0; i < MockData.notifications.length; i++) {
      if (MockData.notifications[i].supervisorId == supervisorId) {
        final old = MockData.notifications[i];
        MockData.notifications[i] = AppNotification(
          id: old.id,
          supervisorId: old.supervisorId,
          title: old.title,
          message: old.message,
          createdAt: old.createdAt,
          isRead: true,
        );
      }
    }
    return true;
  }

  static Future<bool> clearAllNotifications(int supervisorId) async {
    MockData.notifications.removeWhere((n) => n.supervisorId == supervisorId);
    return true;
  }

  static Future<bool> submitGrade(
      int projectId, double total, String comment) async {
    return true;
    /*
    try {
      await client.from('project_grades').insert({
        'id_group': projectId,
        'total_grade': total,
        'comment': comment,
      });
      return true;
    } catch (e) {
      debugPrint('Error submitting grade: $e');
      return false;
    }
    */
  }

  // --- دوال الدردشة (Chat Functions) ---

  static Future<List<Map<String, dynamic>>> getSupervisorChats(
      int supervisorId) async {
    return [
      {
        'chat_id': 1,
        'group_name': 'تأثير التسويق الرقمي',
        'last_message': 'شكراً دكتور',
        'last_message_time': DateTime.now().toIso8601String(),
      }
    ];
  }

  static Future<List<Map<String, dynamic>>> getChatMessages(int chatId) async {
    return [
      {
        'message_id': 1,
        'message_text': 'مرحباً دكتور، هل يمكننا البدء؟',
        'sender_role': 'student',
        'created_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      },
      {
        'message_id': 2,
        'message_text': 'نعم بالتأكيد',
        'sender_role': 'supervisor',
        'created_at': DateTime.now().toIso8601String(),
      }
    ];
  }

  static Future<bool> sendMessage(
      int chatId, String text, String senderRole) async {
    return true;
    /*
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
      debugPrint('Error sending message: $e');
      return false;
    }
    */
  }

  static Stream<List<Map<String, dynamic>>> getMessagesStream(int chatId) {
    // محاكاة الـ Stream
    return Stream.value([
      {
        'message_id': 1,
        'message_text': 'مرحباً دكتور، هل يمكننا البدء؟',
        'sender_role': 'student',
        'created_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      }
    ]);
  }
}
