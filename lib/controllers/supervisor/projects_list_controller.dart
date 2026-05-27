import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/supabase_service.dart';

/// Controller لإدارة قائمة المشاريع
class ProjectsListController extends ChangeNotifier {
  List<ResearchGroup> _projects = [];
  bool _isLoading = true;

  List<ResearchGroup> get projects => _projects;
  bool get isLoading => _isLoading;

  /// تحميل المشاريع
  Future<void> loadProjects(
      {required int supervisorId, bool isGuest = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (isGuest) {
        _projects = [
          ResearchGroup(
            id: 101,
            name: 'مجموعة المشروع التجريبي أ',
            progress: 45,
            currentStage: 'التخطيط',
            description: 'عرض بيانات المشروع التجريبي.',
          ),
          ResearchGroup(
            id: 102,
            name: 'مجموعة المشروع التجريبي ب',
            progress: 70,
            currentStage: 'كتابة البحث',
            description: 'عرض المشروع الثاني في حالة الضيف.',
          ),
          ResearchGroup(
            id: 103,
            name: 'مجموعة المشروع التجريبي ج',
            progress: 90,
            currentStage: 'التحضير للمناقشة',
            description: 'مجموعة اختبارية لعرض تفاصيل المشروع.',
          ),
        ];
      } else {
        _projects =
            await SupabaseService.getGroupsBySupervisor(supervisorId);
      }
    } catch (e) {
      debugPrint('خطأ في تحميل المشاريع: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
