import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/supabase_service.dart';

/// Controller لإدارة تفاصيل المشروع
class ProjectDetailsController extends ChangeNotifier {
  ResearchGroup? _project;
  List<Student> _students = [];
  List<ProjectStage> _stages = [];
  bool _isLoading = true;

  ResearchGroup? get project => _project;
  List<Student> get students => _students;
  List<ProjectStage> get stages => _stages;
  bool get isLoading => _isLoading;

  /// تحميل بيانات المشروع
  Future<void> loadData(
      {required int projectId, bool isGuest = false}) async {
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
        _project = await SupabaseService.getProjectById(projectId);
        if (_project != null) {
          _students = await SupabaseService.getGroupStudents(projectId);
          _stages = await SupabaseService.getProjectStages(projectId);
        }
      }
    } catch (e) {
      debugPrint('خطأ في تحميل تفاصيل المشروع: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
