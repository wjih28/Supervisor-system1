import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show RealtimeChannel;
import '../../models/models.dart';
import '../../services/supabase_service.dart';

/// Controller لإدارة تفاصيل المشروع
class ProjectDetailsController extends ChangeNotifier {
  ResearchGroup? _project;
  List<Student> _students = [];
  List<ProjectStage> _stages = [];
  bool _isLoading = true;
  RealtimeChannel? _groupChannel;
  RealtimeChannel? _stagesChannel;
  int? _supervisorId;
  int? _projectId;

  ResearchGroup? get project => _project;
  List<Student> get students => _students;
  List<ProjectStage> get stages => _stages;
  bool get isLoading => _isLoading;

  /// تحميل بيانات المشروع
  Future<void> loadData({required int projectId, bool isGuest = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (isGuest) {
        _project = ResearchGroup(
          id: projectId,
          name: 'مشروع العرض التجريبي $projectId',
          description: 'هذا وصف تجريبي لعرض شاشة تفاصيل المشروع.',
          progress: 78,
          status: 'جارٍ التنفيذ',
          currentStage: 'المرحلة النهائية',
        );
        _students = [
          Student(id: 1, name: 'أحمد علي', email: 'ahmed@example.com'),
          Student(id: 2, name: 'سارة محمد', email: 'sara@example.com'),
          Student(id: 3, name: 'خالد حسين', email: 'khaled@example.com'),
        ];
      } else {
        _projectId = projectId;
        _project = await SupabaseService.getProjectById(projectId);
        if (_project != null) {
          _supervisorId = _project!.supervisorId;
          _students = await SupabaseService.getGroupStudents(projectId);
          _stages = await SupabaseService.getProjectStages(projectId);
        }
        _startRealtime(projectId);
      }
    } catch (e) {
      debugPrint('خطأ في تحميل تفاصيل المشروع: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث بيانات المشروع بصمت (بدون شاشة تحميل) — يُستدعى من الاشتراك اللحظي
  Future<void> refreshData() async {
    final id = _projectId;
    if (id == null) return;
    try {
      _project = await SupabaseService.getProjectById(id);
      if (_project != null) {
        _stages = await SupabaseService.getProjectStages(id);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('خطأ في التحديث اللحظي لتفاصيل المشروع: $e');
    }
  }

  void _startRealtime(int projectId) {
    // الاشتراك في تغييرات المجموعة (نسبة الإنجاز، المرحلة الحالية)
    if (_supervisorId != null) {
      _groupChannel ??= SupabaseService.subscribeSupervisorGroups(
        _supervisorId!,
        refreshData,
      );
    }
    // الاشتراك في تغييرات حالات المراحل لهذه المجموعة
    _stagesChannel ??= SupabaseService.subscribeProjectStages(
      projectId,
      refreshData,
    );
  }

  @override
  void dispose() {
    final gc = _groupChannel;
    if (gc != null) SupabaseService.removeChannel(gc);
    final sc = _stagesChannel;
    if (sc != null) SupabaseService.removeChannel(sc);
    super.dispose();
  }
}
