import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

/// مزود (Provider) لإدارة حالة المشرف والبيانات المتعلقة به
class SupervisorProvider extends ChangeNotifier {
  // البيانات الأساسية
  late Supervisor _supervisor;
  List<ResearchGroup> _groups = [];
  List<ResearchGroup> _filteredGroups = [];
  Map<String, dynamic>? _statistics;

  // حالات التحميل
  bool _isLoadingGroups = false;
  bool _isLoadingStatistics = false;
  bool _isLoadingComments = false;
  bool _isLoadingFiles = false;
  bool _isLoadingStages = false;
  // البيانات المخزنة مؤقتاً
  final Map<int, List<ProjectFeedback>> _groupComments = {};
  final Map<int, List<ProjectFile>> _groupFiles = {};
  final Map<int, List<ProjectStage>> _groupStages = {};

  // حالة البحث والتصفية
  String _searchQuery = '';
  String _selectedFilter = 'all';

  // ============ Getters ============

  Supervisor get supervisor => _supervisor;
  List<ResearchGroup> get groups => _groups;
  List<ResearchGroup> get filteredGroups =>
      _filteredGroups.isEmpty ? _groups : _filteredGroups;
  Map<String, dynamic>? get statistics => _statistics;
  bool get isLoadingGroups => _isLoadingGroups;
  bool get isLoadingStatistics => _isLoadingStatistics;
  bool get isLoadingComments => _isLoadingComments;
  bool get isLoadingFiles => _isLoadingFiles;
  bool get isLoadingStages => _isLoadingStages;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;

  // ============ المهام الأساسية ============

  /// تهيئة المزود ببيانات المشرف
  void initializeSupervisor(Supervisor supervisor) {
    _supervisor = supervisor;
    notifyListeners();
  }

  /// تحميل جميع البيانات
  Future<void> loadAllData() async {
    await Future.wait([
      loadGroups(),
      loadStatistics(),
    ]);
  }

  /// تحميل المجموعات المسندة للمشرف
  Future<void> loadGroups() async {
    _isLoadingGroups = true;
    notifyListeners();

    try {
      _groups =
          await SupabaseService.getGroupsBySupervisor(_supervisor.id ?? 0);
      _filteredGroups = _groups;
    } catch (e) {
      debugPrint('Error loading groups: $e');
    } finally {
      _isLoadingGroups = false;
      notifyListeners();
    }
  }

  /// تحميل الإحصائيات
  Future<void> loadStatistics() async {
    _isLoadingStatistics = true;
    notifyListeners();

    try {
      _statistics =
          await SupabaseService.getSupervisorStatistics(_supervisor.id ?? 0);
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    } finally {
      _isLoadingStatistics = false;
      notifyListeners();
    }
  }

  /// تحميل الملاحظات لمجموعة معينة
  Future<List<ProjectFeedback>> loadGroupComments(int groupId) async {
    if (_groupComments.containsKey(groupId)) {
      return _groupComments[groupId]!;
    }

    _isLoadingComments = true;
    notifyListeners();

    try {
      final comments = await SupabaseService.getProjectFeedback(groupId);
      _groupComments[groupId] = comments;
      return comments;
    } catch (e) {
      debugPrint('Error loading comments: $e');
      return [];
    } finally {
      _isLoadingComments = false;
      notifyListeners();
    }
  }

  /// تحميل الملفات لمجموعة معينة
  Future<List<ProjectFile>> loadGroupFiles(int groupId) async {
    if (_groupFiles.containsKey(groupId)) {
      return _groupFiles[groupId]!;
    }

    _isLoadingFiles = true;
    notifyListeners();

    try {
      final files = await SupabaseService.getProjectFiles(groupId);
      _groupFiles[groupId] = files;
      return files;
    } catch (e) {
      debugPrint('Error loading files: $e');
      return [];
    } finally {
      _isLoadingFiles = false;
      notifyListeners();
    }
  }

  /// تحميل مراحل المشروع
  Future<List<ProjectStage>> loadProjectStages(int groupId) async {
    if (_groupStages.containsKey(groupId)) {
      return _groupStages[groupId]!;
    }

    _isLoadingStages = true;
    notifyListeners();

    try {
      final stages = await SupabaseService.getProjectStages(groupId);
      _groupStages[groupId] = stages;
      return stages;
    } catch (e) {
      debugPrint('Error loading project stages: $e');
      return [];
    } finally {
      _isLoadingStages = false;
      notifyListeners();
    }
  }

  // ============ وظائف البحث والتصفية ============

  /// البحث عن مجموعات
  Future<void> searchGroups(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredGroups = _groups;
    } else {
      _filteredGroups = _groups
          .where((g) => g.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    notifyListeners();
  }

  /// تصفية المجموعات حسب الحالة
  Future<void> filterGroups(String status) async {
    _selectedFilter = status;

    if (status == 'all') {
      _filteredGroups = _groups;
    } else {
      _filteredGroups = _groups.where((g) => g.status == status).toList();
    }

    notifyListeners();
  }

  /// تطبيق البحث والتصفية معاً
  Future<void> applySearchAndFilter(String query, String status) async {
    _searchQuery = query;
    _selectedFilter = status;

    _filteredGroups = _groups;

    // تطبيق التصفية حسب الحالة
    if (status != 'all') {
      _filteredGroups =
          _filteredGroups.where((g) => g.status == status).toList();
    }

    // تطبيق البحث
    if (query.isNotEmpty) {
      _filteredGroups = _filteredGroups
          .where((g) => g.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    notifyListeners();
  }

  // ============ وظائف تحديث البيانات ============

  /// إضافة ملاحظة جديدة
  Future<bool> addComment(int projectId, int supervisorId, String stage, String commentText) async {
    try {
      final success = await SupabaseService.addProjectFeedback(projectId, supervisorId, stage, commentText);
      if (success) {
        // تحديث الملاحظات المخزنة مؤقتاً
        if (_groupComments.containsKey(projectId)) {
          _groupComments[projectId]!.insert(0, ProjectFeedback(
            id: null,
            groupId: projectId,
            supervisorId: supervisorId,
            stage: stage,
            comment: commentText,
            createdAt: DateTime.now(),
            isResolved: false
          ));
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error adding comment: $e');
      return false;
    }
  }

  /// تحديث ملاحظة موجودة
  Future<bool> updateComment(
      int groupId, int commentId, ProjectFeedback comment) async {
    try {
      final success = await SupabaseService.updateReviewComment(comment);
      if (success) {
        // تحديث الملاحظات المخزنة مؤقتاً
        if (_groupComments.containsKey(groupId)) {
          final index =
              _groupComments[groupId]!.indexWhere((c) => c.id == commentId);
          if (index != -1) {
            _groupComments[groupId]![index] = comment;
          }
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error updating comment: $e');
      return false;
    }
  }

  /// حذف ملاحظة
  Future<bool> deleteComment(int groupId, int commentId) async {
    try {
      final success = await SupabaseService.deleteComment(commentId);
      if (success) {
        // حذف الملاحظة من البيانات المخزنة مؤقتاً
        if (_groupComments.containsKey(groupId)) {
          _groupComments[groupId]!.removeWhere((c) => c.id == commentId);
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      return false;
    }
  }

  /// تحديث حالة المجموعة
  Future<bool> updateGroupStatus(
      int groupId, String status, double progress) async {
    try {
      final success =
          await SupabaseService.updateGroupStatus(groupId, status, progress);
      if (success) {
        // تحديث البيانات المحلية
        final index = _groups.indexWhere((g) => g.id == groupId);
        if (index != -1) {
          final group = _groups[index];
          _groups[index] = ResearchGroup(
            id: group.id,
            name: group.name,
            supervisorId: group.supervisorId,
            stateId: group.stateId,
            leaderId: group.leaderId,
            description: group.description,
            progress: progress,
            status: status,
            createdAt: group.createdAt,
            updatedAt: DateTime.now(),
            currentStage: group.currentStage,
          );
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error updating group status: $e');
      return false;
    }
  }

  /// تحديث حالة المرحلة
  Future<bool> updateStageStatus(
      int stageId, String status, double progress) async {
    try {
      final success = await SupabaseService.updateStageStatus(
          stageId, status, progress);
      if (success) {
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error updating stage status: $e');
      return false;
    }
  }

  // ============ وظائف التنظيف والمساعدة ============

  /// تحديث جميع البيانات
  Future<void> refreshAllData() async {
    // مسح البيانات المخزنة مؤقتاً
    _groupComments.clear();
    _groupFiles.clear();
    _groupStages.clear();

    // إعادة تحميل البيانات
    await loadAllData();
  }

  /// مسح البيانات المخزنة مؤقتاً لمجموعة معينة
  void clearGroupCache(int groupId) {
    _groupComments.remove(groupId);
    _groupFiles.remove(groupId);
    _groupStages.remove(groupId);
    notifyListeners();
  }

  /// مسح جميع البيانات المخزنة مؤقتاً
  void clearAllCache() {
    _groupComments.clear();
    _groupFiles.clear();
    _groupStages.clear();
    notifyListeners();
  }

  /// الحصول على عدد الملاحظات غير المقروءة
  int getUnreadCommentsCount(int groupId) {
    if (!_groupComments.containsKey(groupId)) {
      return 0;
    }
    return _groupComments[groupId]!.where((c) => c.isResolved == false).length;
  }

  /// الحصول على عدد الملفات الجديدة
  int getNewFilesCount(int groupId) {
    if (!_groupFiles.containsKey(groupId)) {
      return 0;
    }
    final now = DateTime.now();
    final oneDayAgo = now.subtract(const Duration(days: 1));
    return _groupFiles[groupId]!
        .where((f) => f.uploadedAt != null && f.uploadedAt!.isAfter(oneDayAgo))
        .length;
  }

  /// الحصول على نسبة التقدم الإجمالية
  double getOverallProgress() {
    if (_groups.isEmpty) {
      return 0.0;
    }
    final totalProgress =
        _groups.fold(0.0, (sum, g) => sum + (g.progress ?? 0.0));
    return totalProgress / _groups.length;
  }

  /// الحصول على عدد المجموعات حسب الحالة
  int getGroupCountByStatus(String status) {
    return _groups.where((g) => g.status == status).length;
  }
}
