import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

/// طبقة الوصول الوحيدة إلى Supabase لنظام المشرف.
class SupabaseService {
  static final client = Supabase.instance.client;

  /// أعمدة groups مع العلاقات المضمّنة (قائد الفريق + الحالة + اسم المرحلة + وصف المرحلة الأولى)
  static const String _groupSelect =
      '*, student!groups_group_led_id_fkey(stud_name), GroupState(states_name), stages!groups_current_stage_fkey(stage_name), "first stage"(research_description)';

  // ============ المصادقة ============

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
      debugPrint('Error logging in supervisor: $e');
      return null;
    }
  }

  // ============ المجموعات / المشاريع ============

  static Future<List<ResearchGroup>> getGroupsBySupervisor(
      int supervisorId) async {
    try {
      final response = await client
          .from('groups')
          .select(_groupSelect)
          .eq('id_sprvsr', supervisorId);

      return (response as List)
          .map((json) => ResearchGroup.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching groups: $e');
      return [];
    }
  }

  static Future<ResearchGroup?> getProjectById(int id) async {
    try {
      final response = await client
          .from('groups')
          .select(_groupSelect)
          .eq('group_id', id)
          .maybeSingle();

      if (response != null) {
        return ResearchGroup.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching project: $e');
      return null;
    }
  }

  static Future<List<Student>> getGroupStudents(int groupId) async {
    try {
      final response =
          await client.from('student').select().eq('id_group', groupId);

      return (response as List).map((json) => Student.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching group students: $e');
      return [];
    }
  }

  static Future<bool> updateGroupStatus(
      int groupId, String status, double progress) async {
    try {
      await client.from('groups').update({
        // الواجهة تستخدم مقياس (0 - 100) والعمود يخزّن كسراً (0.0 - 1.0)
        'group_progress': progress / 100,
      }).eq('group_id', groupId);
      return true;
    } catch (e) {
      debugPrint('Error updating group status: $e');
      return false;
    }
  }

  /// تحديث المرحلة الحالية للمجموعة (current_stage هو مفتاح خارجي إلى stages)
  static Future<bool> updateProjectStage(int projectId, int stageId) async {
    try {
      await client
          .from('groups')
          .update({'current_stage': stageId}).eq('group_id', projectId);
      return true;
    } catch (e) {
      debugPrint('Error updating project stage: $e');
      return false;
    }
  }

  // ============ المراجع: البرامج / الأقسام ============

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
      debugPrint('Error fetching supervisor: $e');
      return null;
    }
  }

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
      debugPrint('Error fetching program: $e');
      return null;
    }
  }

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
      debugPrint('Error fetching department: $e');
      return null;
    }
  }

  // ============ الملاحظات / التعليقات (review_comments) ============

  static Future<List<ProjectFeedback>> getProjectFeedback(int projectId) async {
    try {
      final response = await client
          .from('review_comments')
          .select()
          .eq('id_group', projectId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ProjectFeedback.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching project feedback: $e');
      return [];
    }
  }

  static Future<List<ReviewComment>> getCommentsByGroup(int groupId) async {
    try {
      final response = await client
          .from('review_comments')
          .select()
          .eq('id_group', groupId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ReviewComment.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching comments: $e');
      return [];
    }
  }

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
      debugPrint('Error adding project feedback: $e');
      return false;
    }
  }

  static Future<bool> addReviewComment(ReviewComment comment) async {
    try {
      await client.from('review_comments').insert(comment.toJson());
      return true;
    } catch (e) {
      debugPrint('Error adding review comment: $e');
      return false;
    }
  }

  static Future<bool> updateReviewComment(ReviewComment comment) async {
    try {
      await client
          .from('review_comments')
          .update(comment.toJson())
          .eq('comment_id', comment.id!);
      return true;
    } catch (e) {
      debugPrint('Error updating review comment: $e');
      return false;
    }
  }

  static Future<bool> resolveFeedback(int feedbackId) async {
    try {
      await client
          .from('review_comments')
          .update({'is_resolved': true}).eq('comment_id', feedbackId);
      return true;
    } catch (e) {
      debugPrint('Error resolving feedback: $e');
      return false;
    }
  }

  static Future<bool> addComment(ReviewComment comment) async {
    return addReviewComment(comment);
  }

  static Future<bool> updateComment(
      int commentId, ReviewComment comment) async {
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
  }

  static Future<bool> deleteComment(int commentId) async {
    try {
      await client.from('review_comments').delete().eq('comment_id', commentId);
      return true;
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      return false;
    }
  }

  // ============ الملفات (research_files) ============

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
      debugPrint('Error fetching project files: $e');
      return [];
    }
  }

  static Future<List<ProjectFile>> getFilesByGroup(int groupId) async {
    return getProjectFiles(groupId);
  }

  static Future<bool> addSupervisorNote(int fileId, String note) async {
    try {
      await client
          .from('research_files')
          .update({'supervisor_notes': note}).eq('file_id', fileId);
      return true;
    } catch (e) {
      debugPrint('Error adding supervisor note: $e');
      return false;
    }
  }

  /// يجمع ملفات المجموعة المرفوعة فعلياً من جداول المراحل (روابط التخزين العامة)
  /// بالإضافة إلى أي صفوف في research_files (للتوافق المستقبلي).
  static Future<List<ProjectFile>> getGroupFiles(int groupId) async {
    final files = <ProjectFile>[];

    Future<void> addFrom(
      String table,
      String urlColumn,
      String groupColumn,
      String label,
      String stageKey,
    ) async {
      try {
        final rows =
            await client.from(table).select(urlColumn).eq(groupColumn, groupId);
        for (final r in (rows as List)) {
          final url = r[urlColumn];
          if (url != null && url.toString().isNotEmpty) {
            files.add(ProjectFile(
              groupId: groupId,
              fileName: label,
              fileUrl: url.toString(),
              fileType: 'pdf',
              stage: stageKey,
            ));
          }
        }
      } catch (e) {
        debugPrint('Error fetching files from $table: $e');
      }
    }

    await addFrom('stage2_titles_approval', 'pdf_file', 'id_group',
        'المرحلة الثانية - اعتماد الخطة', 'stage2');
    await addFrom('fourth stage', 'stage4_pdf', 'id_group',
        'المرحلة الرابعة - الدراسات الميدانية', 'stage4');
    await addFrom('fifth_Stage', 'pdf_file', 'group_id',
        'المرحلة الخامسة - مشروع البحث', 'stage5');

    // ملفات research_files (إن وُجدت)
    try {
      final extra = await getProjectFiles(groupId);
      files.addAll(extra.where((f) => (f.fileUrl ?? '').isNotEmpty));
    } catch (e) {
      debugPrint('Error fetching research_files: $e');
    }

    return files;
  }

  // ============ المراحل (stages + stages statues) ============

  static Future<List<ProjectStage>> getProjectStages(int groupId) async {
    try {
      // برنامج المجموعة — المراحل معرّفة على مستوى البرنامج
      final group = await client
          .from('groups')
          .select('id_program')
          .eq('group_id', groupId)
          .maybeSingle();
      final programId = group?['id_program'];
      // بدون برنامج لا يمكن تحديد مراحل المجموعة (تفادي جلب كل البرامج)
      if (programId == null) return [];

      // مراحل هذا البرنامج فقط
      final stages = await client
          .from('stages')
          .select('stages_id, stage_name, start_date, end_date, stage_isactive')
          .eq('id_program', programId)
          .order('stages_id');

      // حالة كل مرحلة لهذه المجموعة (قد تكون فارغة)
      final statuses =
          await client.from('stages statues').select().eq('id_group', groupId);

      final statusByStage = {
        for (final s in (statuses as List)) s['id_stages']: s,
      };

      // تُخفى المرحلة 7 (تسليم البحث) فقط — المرحلة 6 (المناقشة الثلاثية) مرئية للمشرف.
      final visibleStages = (stages as List).where((stage) {
        final n = int.tryParse(
            RegExp(r'\d+').firstMatch('${stage['stage_name']}')?.group(0) ??
                '');
        return n == null || n <= 6;
      }).toList();

      return visibleStages.map((stage) {
        final st = statusByStage[stage['stages_id']];
        final approval = st?['approval'] == true;
        double? progress;
        if (st?['percentage'] != null) {
          progress = double.tryParse(st!['percentage'].toString());
          if (progress != null && progress > 1) progress = progress / 100;
        }
        return ProjectStage(
          id: stage['stages_id'],
          groupId: groupId,
          name: stage['stage_name'] ?? '',
          isActive: stage['stage_isactive'] == true,
          isCompleted: approval,
          status: approval
              ? 'completed'
              : (progress != null && progress > 0 ? 'in_progress' : 'pending'),
          progress: progress ?? (approval ? 1.0 : 0.0),
          startDate: stage['start_date'] != null
              ? DateTime.tryParse(stage['start_date'].toString())
              : null,
          endDate: stage['end_date'] != null
              ? DateTime.tryParse(stage['end_date'].toString())
              : null,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching project stages: $e');
      return [];
    }
  }

  static Future<bool> updateStageStatus(
      int stageId, String status, double progress) async {
    try {
      await client.from('stages statues').update({
        'stage_state': status,
        'percentage': progress.toString(),
      }).eq('id_stages', stageId);
      return true;
    } catch (e) {
      debugPrint('Error updating stage status: $e');
      return false;
    }
  }

  /// إنشاء/تحديث حالة المرحلة لهذه المجموعة (جدول "stages statues" قد يكون فارغاً)
  static Future<bool> upsertStageStatus(
    int groupId,
    int stageId, {
    double? percentage,
    bool? approval,
    String? state,
  }) async {
    try {
      final existing = await client
          .from('stages statues')
          .select('state_id')
          .eq('id_group', groupId)
          .eq('id_stages', stageId)
          .maybeSingle();

      final data = <String, dynamic>{};
      if (percentage != null) data['percentage'] = percentage.toString();
      if (approval != null) data['approval'] = approval;
      if (state != null) data['stage_state'] = state;

      if (existing == null) {
        data['id_group'] = groupId;
        data['id_stages'] = stageId;
        await client.from('stages statues').insert(data);
      } else {
        await client
            .from('stages statues')
            .update(data)
            .eq('state_id', existing['state_id']);
      }
      return true;
    } catch (e) {
      debugPrint('Error upserting stage status: $e');
      return false;
    }
  }

  // ============ تفاصيل المراحل (جداول كل مرحلة) ============

  /// المرحلة 1 — جدول "first stage"
  static Future<Stage1Info?> getStage1(int groupId) async {
    try {
      final row = await client
          .from('first stage')
          .select()
          .eq('group_id', groupId)
          .maybeSingle();
      return row != null ? Stage1Info.fromJson(row) : null;
    } catch (e) {
      debugPrint('Error fetching stage 1: $e');
      return null;
    }
  }

  /// اعتماد/رفض المرحلة الأولى (sprvsr_approval). تُنشئ الصف إن لم يكن موجوداً.
  static Future<bool> updateStage1Approval(int groupId, bool approved) async {
    try {
      final existing = await client
          .from('first stage')
          .select('stage1_id')
          .eq('group_id', groupId)
          .maybeSingle();
      if (existing == null) {
        await client
            .from('first stage')
            .insert({'group_id': groupId, 'sprvsr_approval': approved});
      } else {
        await client
            .from('first stage')
            .update({'sprvsr_approval': approved}).eq('group_id', groupId);
      }
      return true;
    } catch (e) {
      debugPrint('Error updating stage 1 approval: $e');
      return false;
    }
  }

  /// المرحلة 2 — جدول "stage2_titles_approval"
  static Future<Stage2Info?> getStage2(int groupId) async {
    try {
      final row = await client
          .from('stage2_titles_approval')
          .select()
          .eq('id_group', groupId)
          .maybeSingle();
      return row != null ? Stage2Info.fromJson(row) : null;
    } catch (e) {
      debugPrint('Error fetching stage 2: $e');
      return null;
    }
  }

  /// عناوين/عناصر المرحلة الثانية (قائمة مرجعية عامة) — جدول "Title of second stage"
  static Future<List<String>> getSecondStageTitles() async {
    try {
      final rows = await client
          .from('Title of second stage')
          .select('title_name')
          .order('id_title');
      return (rows as List)
          .map((r) => (r['title_name'] ?? '').toString())
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('Error fetching second stage titles: $e');
      return [];
    }
  }

  /// اعتماد المرحلة الثانية (stage_approval). تُنشئ الصف إن لم يكن موجوداً.
  static Future<bool> updateStage2Approval(int groupId, bool approved) async {
    try {
      final existing = await client
          .from('stage2_titles_approval')
          .select('stage2_id')
          .eq('id_group', groupId)
          .maybeSingle();
      if (existing == null) {
        await client
            .from('stage2_titles_approval')
            .insert({'id_group': groupId, 'stage_approval': approved});
      } else {
        await client
            .from('stage2_titles_approval')
            .update({'stage_approval': approved}).eq('id_group', groupId);
      }
      return true;
    } catch (e) {
      debugPrint('Error updating stage 2 approval: $e');
      return false;
    }
  }

  /// إضافة ملاحظة "يحتاج تعديل" على عنوان من المرحلة الثانية.
  /// تُخزَّن بصيغة (اسم العنوان: الملاحظة) وتُلحَق بحقل sprvsr_note.
  static Future<bool> addStage2TitleNote(
      int groupId, String titleName, String note) async {
    try {
      final entry = '$titleName: $note';
      final row = await client
          .from('stage2_titles_approval')
          .select('stage2_id, sprvsr_note')
          .eq('id_group', groupId)
          .maybeSingle();
      if (row == null) {
        await client
            .from('stage2_titles_approval')
            .insert({'id_group': groupId, 'sprvsr_note': entry});
      } else {
        final current = (row['sprvsr_note'] ?? '').toString().trim();
        final updated = current.isEmpty ? entry : '$current\n$entry';
        await client
            .from('stage2_titles_approval')
            .update({'sprvsr_note': updated}).eq('id_group', groupId);
      }
      return true;
    } catch (e) {
      debugPrint('Error adding stage 2 title note: $e');
      return false;
    }
  }

  /// المرحلة 3 — جدول "third stage(discussion)"
  static Future<Stage3Info?> getStage3(int groupId) async {
    try {
      final row = await client
          .from('third stage(discussion)')
          .select()
          .eq('id_group', groupId)
          .maybeSingle();
      return row != null ? Stage3Info.fromJson(row) : null;
    } catch (e) {
      debugPrint('Error fetching stage 3: $e');
      return null;
    }
  }

  /// حفظ نتيجة مناقشة الخطة (المرحلة 3). تُنشئ الصف إن لم يكن موجوداً.
  static Future<bool> updateStage3(
    int groupId, {
    required bool discussed,
    required double percent,
    DateTime? date,
    String? note,
  }) async {
    try {
      final data = <String, dynamic>{
        'discussion_state': discussed,
        'discussion_percent': percent,
        if (date != null)
          'discus_date':
              date.toIso8601String().split('T').first, // صيغة DATE: yyyy-MM-dd
        if (note != null) 'sprvsr_note': note,
      };
      final existing = await client
          .from('third stage(discussion)')
          .select('stage3_id')
          .eq('id_group', groupId)
          .maybeSingle();
      if (existing == null) {
        data['id_group'] = groupId;
        await client.from('third stage(discussion)').insert(data);
      } else {
        await client
            .from('third stage(discussion)')
            .update(data)
            .eq('id_group', groupId);
      }
      return true;
    } catch (e) {
      debugPrint('Error updating stage 3: $e');
      return false;
    }
  }

  /// المرحلة 4 — جدول "fourth stage"
  static Future<Stage4Info?> getStage4(int groupId) async {
    try {
      final row = await client
          .from('fourth stage')
          .select()
          .eq('id_group', groupId)
          .maybeSingle();
      return row != null ? Stage4Info.fromJson(row) : null;
    } catch (e) {
      debugPrint('Error fetching stage 4: $e');
      return null;
    }
  }

  /// اعتماد/رفض المرحلة الرابعة + ملاحظات المشرف. تُنشئ الصف إن لم يكن موجوداً.
  static Future<bool> updateStage4(
    int groupId, {
    required bool approved,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        'approval': approved,
        if (notes != null) 'sprvsr_notes': notes,
      };
      final existing = await client
          .from('fourth stage')
          .select('stage4_id')
          .eq('id_group', groupId)
          .maybeSingle();
      if (existing == null) {
        data['id_group'] = groupId;
        await client.from('fourth stage').insert(data);
      } else {
        await client.from('fourth stage').update(data).eq('id_group', groupId);
      }
      return true;
    } catch (e) {
      debugPrint('Error updating stage 4: $e');
      return false;
    }
  }

  /// المرحلة 5 — جدول "fifth_Stage" (صف لكل قسم) + أسماء الأقسام من "fifth stage titles".
  /// تُعاد الأقسام السبعة كلها مرتبة بـ title_id حتى وإن لم يرفع الطالب ملفاً لبعضها.
  static Future<List<Stage5Section>> getStage5Sections(int groupId) async {
    try {
      final titles = await client
          .from('fifth stage titles')
          .select('title_id, title_name')
          .order('title_id');
      final rows =
          await client.from('fifth_Stage').select().eq('group_id', groupId);
      final rowByTitle = {
        for (final r in (rows as List)) r['title_id']: r,
      };
      return (titles as List).map((t) {
        final titleId = t['title_id'] as int;
        return Stage5Section.from(
          titleId,
          (t['title_name'] ?? '').toString(),
          rowByTitle[titleId] as Map<String, dynamic>?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching stage 5 sections: $e');
      return [];
    }
  }

  /// اعتماد/رفض قسم من المرحلة الخامسة + ملاحظة المشرف. تُنشئ الصف إن لم يكن موجوداً.
  static Future<bool> updateStage5Section(
    int groupId,
    int titleId, {
    required bool approved,
    String? note,
  }) async {
    try {
      final data = <String, dynamic>{
        'approval': approved,
        if (note != null) 'sprvsr_note': note,
      };
      final existing = await client
          .from('fifth_Stage')
          .select('stage5_id')
          .eq('group_id', groupId)
          .eq('title_id', titleId)
          .maybeSingle();
      if (existing == null) {
        data['group_id'] = groupId;
        data['title_id'] = titleId;
        await client.from('fifth_Stage').insert(data);
      } else {
        await client
            .from('fifth_Stage')
            .update(data)
            .eq('stage5_id', existing['stage5_id']);
      }
      return true;
    } catch (e) {
      debugPrint('Error updating stage 5 section: $e');
      return false;
    }
  }

  /// المرحلة 6 — جدول "stage 6 (trio discussion)"
  static Future<Stage6Info?> getStage6(int groupId) async {
    try {
      final row = await client
          .from('stage 6 (trio discussion)')
          .select()
          .eq('group_id', groupId)
          .maybeSingle();
      return row != null ? Stage6Info.fromJson(row) : null;
    } catch (e) {
      debugPrint('Error fetching stage 6: $e');
      return null;
    }
  }

  /// اعتماد المرحلة 6 وتحديث التاريخ
  static Future<bool> updateStage6(
    int groupId, {
    bool? approval,
    DateTime? date,
  }) async {
    try {
      final data = <String, dynamic>{
        if (approval != null) 'approval': approval,
        if (date != null)
          'discuss_date': date.toIso8601String().split('T').first,
      };
      if (data.isEmpty) return false;

      final existing = await client
          .from('stage 6 (trio discussion)')
          .select('stage6_id')
          .eq('group_id', groupId)
          .maybeSingle();

      if (existing == null) {
        data['group_id'] = groupId;
        await client.from('stage 6 (trio discussion)').insert(data);
      } else {
        await client
            .from('stage 6 (trio discussion)')
            .update(data)
            .eq('group_id', groupId);
      }
      return true;
    } catch (e) {
      debugPrint('Error updating stage 6: $e');
      return false;
    }
  }

  // ============ الإحصائيات ============

  static Future<Map<String, dynamic>?> getSupervisorStatistics(
      int supervisorId) async {
    try {
      final groups = await client
          .from('groups')
          .select('group_progress, GroupState(states_name)')
          .eq('id_sprvsr', supervisorId);

      final list = groups as List;
      final int total = list.length;
      final double avgProgress = total > 0
          ? list.fold<double>(
                  0.0,
                  (sum, g) =>
                      sum +
                      ((g['group_progress'] as num?)?.toDouble() ?? 0.0)) /
              total
          : 0.0;

      // عدد المجموعات لكل حالة (states_name)
      final Map<String, int> byState = {};
      for (final g in list) {
        final name = g['GroupState']?['states_name'] as String?;
        if (name != null) {
          byState[name] = (byState[name] ?? 0) + 1;
        }
      }

      return {
        'totalProjects': total,
        'averageProgress': avgProgress,
        'byState': byState,
      };
    } catch (e) {
      debugPrint('Error fetching statistics: $e');
      return null;
    }
  }

  // ============ الإعدادات ============

  static Future<bool> updateSupervisor(
      int supervisorId, String name, String email) async {
    try {
      await client.from('supervisor').update({
        'sprvsr_name': name,
        'sprvsr_email': email,
      }).eq('sprvsr_id', supervisorId);
      return true;
    } catch (e) {
      debugPrint('Error updating supervisor: $e');
      return false;
    }
  }

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
      debugPrint('Error fetching supervisor settings: $e');
      return null;
    }
  }

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
      debugPrint('Error updating supervisor settings: $e');
      return false;
    }
  }

  static Future<bool> updateSupervisorPassword(
      int supervisorId, String newPassword) async {
    try {
      await client.from('supervisor').update(
          {'sprvsr_password': newPassword}).eq('sprvsr_id', supervisorId);
      return true;
    } catch (e) {
      debugPrint('Error updating supervisor password: $e');
      return false;
    }
  }

  static Future<bool> updateSupervisorPhoto(
      int supervisorId, String? photoUrl) async {
    try {
      await client.from('supervisor').update({
        'supervis_photo': photoUrl,
      }).eq('sprvsr_id', supervisorId);
      return true;
    } catch (e) {
      debugPrint('Error updating supervisor photo: $e');
      return false;
    }
  }

  // ============ الإشعارات ============

  static Future<List<AppNotification>> getNotifications(
      int supervisorId) async {
    try {
      final response = await client
          .from('notifications')
          .select()
          .eq('id_sprvsr', supervisorId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => AppNotification.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  static Future<bool> sendNotification(AppNotification notification) async {
    try {
      await client.from('notifications').insert(notification.toJson());
      return true;
    } catch (e) {
      debugPrint('Error sending notification: $e');
      return false;
    }
  }

  static Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      await client
          .from('notifications')
          .update({'is_read': true}).eq('notification_id', notificationId);
      return true;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  static Future<bool> markAllNotificationsAsRead(int supervisorId) async {
    try {
      await client
          .from('notifications')
          .update({'is_read': true}).eq('id_sprvsr', supervisorId);
      return true;
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      return false;
    }
  }

  static Future<bool> clearAllNotifications(int supervisorId) async {
    try {
      await client.from('notifications').delete().eq('id_sprvsr', supervisorId);
      return true;
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
      return false;
    }
  }

  // ============ الدرجات (student_grades) ============

  /// يعيد خريطة {stud_id: final_grade} لكل طلاب في المجموعة (للمرحلة 6)
  static Future<Map<int, double>> getStudentGrades(int groupId) async {
    try {
      final rows = await client
          .from('student_grades')
          .select('id_student, final_grade')
          .eq('id_group', groupId);

      final map = <int, double>{};
      for (final r in (rows as List)) {
        if (r['id_student'] != null && r['final_grade'] != null) {
          map[r['id_student']] = (r['final_grade'] as num).toDouble();
        }
      }
      return map;
    } catch (e) {
      debugPrint('Error fetching student grades: $e');
      return {};
    }
  }

  static Future<List<Map<String, dynamic>>> getStudentGradesBySupervisor(int supervisorId) async {
    try {
      final rows = await client
          .from('student_grades')
          .select('id_student, id_group, supervisor_grade, final_grade, total_grade')
          .eq('id_sprvsr', supervisorId);
      return (rows as List).map((r) => Map<String, dynamic>.from(r)).toList();
    } catch (e) {
      debugPrint('Error fetching student grades by supervisor: $e');
      return [];
    }
  }

  /// حفظ final_grade لكل طالب في جدول student_grades.
  /// كل عنصر: {'id_student': int, 'id_group': int, 'grade': double}
  static Future<bool> saveStudentGrades({
    required int supervisorId,
    required List<Map<String, dynamic>> grades,
  }) async {
    try {
      for (final g in grades) {
        final studentId = g['id_student'] as int;
        final groupId   = g['id_group']   as int;
        final grade     = (g['grade'] as num).toDouble();

        final existing = await client
            .from('student_grades')
            .select('grade_id')
            .eq('id_student', studentId)
            .eq('id_group', groupId)
            .maybeSingle();

        if (existing == null) {
          await client.from('student_grades').insert({
            'id_student':       studentId,
            'id_group':         groupId,
            'id_sprvsr':        supervisorId,
            'final_grade':      grade,
            'updated_at':       DateTime.now().toIso8601String(),
          });
        } else {
          await client
              .from('student_grades')
              .update({
                'final_grade':      grade,
                'id_sprvsr':        supervisorId,
                'updated_at':       DateTime.now().toIso8601String(),
              })
              .eq('grade_id', existing['grade_id']);
        }
      }
      return true;
    } catch (e) {
      debugPrint('Error saving student grades: $e');
      return false;
    }
  }

  /// حفظ supervisor_grade لكل طالب في جدول student_grades.
  /// كل عنصر: {'id_student': int, 'id_group': int, 'supervisor_grade': double, 'total_grade': double}
  static Future<bool> saveStudentFinalGrades({
    required int supervisorId,
    required List<Map<String, dynamic>> grades,
  }) async {
    try {
      for (final g in grades) {
        final studentId = g['id_student'] as int;
        final groupId   = g['id_group']   as int;
        final supGrade  = (g['supervisor_grade'] as num).toDouble();
        final totalGrade = (g['total_grade'] as num).toDouble();

        // ابحث عن صف موجود لهذا الطالب في هذه المجموعة
        final existing = await client
            .from('student_grades')
            .select('grade_id')
            .eq('id_student', studentId)
            .eq('id_group', groupId)
            .maybeSingle();

        if (existing == null) {
          // إنشاء صف جديد
          await client.from('student_grades').insert({
            'id_student':       studentId,
            'id_group':         groupId,
            'id_sprvsr':        supervisorId,
            'supervisor_grade': supGrade,
            'total_grade':      totalGrade,
            'updated_at':       DateTime.now().toIso8601String(),
          });
        } else {
          // تحديث الصف الموجود
          await client
              .from('student_grades')
              .update({
                'supervisor_grade': supGrade,
                'total_grade':      totalGrade,
                'id_sprvsr':        supervisorId,
                'updated_at':       DateTime.now().toIso8601String(),
              })
              .eq('grade_id', existing['grade_id']);
        }
      }
      return true;
    } catch (e) {
      debugPrint('Error saving student grades: $e');
      return false;
    }
  }

  // ============ الدردشة (chats + messages) ============

  static Future<List<Map<String, dynamic>>> getSupervisorChats(
      int supervisorId) async {
    try {
      final response = await client
          .from('chats')
          .select('*, groups(group_name)')
          .eq('id_sprvsr', supervisorId)
          .order('last_message_time', ascending: false);

      return (response as List).map((row) {
        final map = Map<String, dynamic>.from(row);
        map['group_name'] = row['groups']?['group_name'];
        return map;
      }).toList();
    } catch (e) {
      debugPrint('Error fetching supervisor chats: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getChatMessages(int chatId) async {
    try {
      final response = await client
          .from('messages')
          .select()
          .eq('id_chat', chatId)
          .order('created_at');

      return (response as List)
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
    } catch (e) {
      debugPrint('Error fetching chat messages: $e');
      return [];
    }
  }

  /// إيجاد محادثة المجموعة أو إنشاؤها إذا لم تكن موجودة (إنشاء كسول).
  /// يعيد chat_id أو null عند الفشل.
  static Future<int?> getOrCreateChat({
    required int supervisorId,
    required int groupId,
  }) async {
    try {
      final existing = await client
          .from('chats')
          .select('chat_id')
          .eq('id_sprvsr', supervisorId)
          .eq('id_group', groupId)
          .maybeSingle();
      if (existing != null) return existing['chat_id'] as int;

      final inserted = await client
          .from('chats')
          .insert({'id_sprvsr': supervisorId, 'id_group': groupId})
          .select('chat_id')
          .single();
      return inserted['chat_id'] as int;
    } catch (e) {
      debugPrint('Error creating chat: $e');
      return null;
    }
  }

  static Future<bool> sendMessage(int chatId, String text, String senderRole,
      {int? senderId}) async {
    try {
      await client.from('messages').insert({
        'id_chat': chatId,
        'message_text': text,
        'sender_role': senderRole,
        'sender_id': senderId,
        'message_status': 'sent',
      });

      await client.from('chats').update({
        'last_message': text,
        'last_message_time': DateTime.now().toIso8601String(),
      }).eq('chat_id', chatId);

      return true;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    }
  }

  static Stream<List<Map<String, dynamic>>> getMessagesStream(int chatId) {
    return client
        .from('messages')
        .stream(primaryKey: ['message_id'])
        .eq('id_chat', chatId)
        .order('created_at');
  }

  static Future<bool> updateMessagesStatus(int chatId, String status) async {
    try {
      if (status == 'delivered') {
        await client
            .from('messages')
            .update({'message_status': 'delivered'})
            .eq('id_chat', chatId)
            .neq('sender_role', 'supervisor')
            .eq('message_status', 'sent');
      } else if (status == 'read') {
        await client
            .from('messages')
            .update({'message_status': 'read'})
            .eq('id_chat', chatId)
            .neq('sender_role', 'supervisor')
            .neq('message_status', 'read');
      }
      return true;
    } catch (e) {
      debugPrint('Error updating message status: $e');
      return false;
    }
  }

  // ============ التحديث اللحظي للمراحل (Realtime) ============

  /// (اسم الجدول، عمود المجموعة) لكل مرحلة — تُستخدم للاشتراك اللحظي.
  static const Map<int, List<String>> _stageRealtimeTables = {
    1: ['first stage', 'group_id'],
    2: ['stage2_titles_approval', 'id_group'],
    3: ['third stage(discussion)', 'id_group'],
    4: ['fourth stage', 'id_group'],
    5: ['fifth_Stage', 'group_id'],
  };

  /// الاشتراك في تغييرات جدول المرحلة لمجموعة محددة. عند أي تغيير يُستدعى [onChange].
  /// تُعاد القناة لإغلاقها لاحقاً عبر [removeChannel].
  static RealtimeChannel subscribeStage(
      int stageNumber, int groupId, void Function() onChange) {
    final channel = client.channel('stage_${stageNumber}_$groupId');
    final entry = _stageRealtimeTables[stageNumber];
    if (entry != null) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: entry[0],
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: entry[1],
          value: groupId,
        ),
        callback: (_) => onChange(),
      );
    }
    channel.subscribe();
    return channel;
  }

  static void removeChannel(RealtimeChannel channel) {
    client.removeChannel(channel);
  }

  /// الاشتراك في الرسائل الجديدة (INSERT) لمحادثة بعينها —
  /// يُستخدم لتحديث معاينة قائمة المحادثات للمحادثات غير المفتوحة.
  static RealtimeChannel subscribeMessagesForChat(
      int chatId, void Function(Map<String, dynamic> newMsg) onNew) {
    final channel = client.channel('msg_insert_$chatId');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id_chat',
        value: chatId,
      ),
      callback: (payload) => onNew(payload.newRecord),
    );
    channel.subscribe();
    return channel;
  }

  /// الاشتراك في تغييرات جدول chats لمشرف معين
  static RealtimeChannel subscribeSupervisorChats(
      int supervisorId, void Function() onChange) {
    final channel = client.channel('chats_$supervisorId');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'chats',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id_sprvsr',
        value: supervisorId,
      ),
      callback: (_) => onChange(),
    );
    channel.subscribe();
    return channel;
  }

  /// الاشتراك في تغييرات جدول groups لمشرف معين (يفيد في حالة تغير نسبة الإنجاز)
  static RealtimeChannel subscribeSupervisorGroups(
      int supervisorId, void Function() onChange) {
    final channel = client.channel('groups_sprvsr_$supervisorId');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'groups',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id_sprvsr',
        value: supervisorId,
      ),
      callback: (_) => onChange(),
    );
    channel.subscribe();
    return channel;
  }

  /// الاشتراك في جدول states statues لمجموعة محددة (لمعرفة تغيرات نسبة الإنجاز لكل مرحلة)
  static RealtimeChannel subscribeProjectStages(
      int groupId, void Function() onChange) {
    final channel = client.channel('stages_statues_$groupId');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'stages statues',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id_group',
        value: groupId,
      ),
      callback: (_) => onChange(),
    );
    channel.subscribe();
    return channel;
  }
}
