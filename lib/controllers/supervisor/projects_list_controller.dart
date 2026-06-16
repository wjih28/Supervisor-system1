import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show RealtimeChannel;
import '../../models/models.dart';
import '../../services/supabase_service.dart';

/// Controller لإدارة قائمة المشاريع
class ProjectsListController extends ChangeNotifier {
  List<ResearchGroup> _projects = [];
  bool _isLoading = true;
  RealtimeChannel? _groupsChannel;

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
        _projects = await SupabaseService.getGroupsBySupervisor(supervisorId);
        _subscribeGroups(supervisorId);
      }
    } catch (e) {
      debugPrint('خطأ في تحميل المشاريع: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث القائمة بصمت عند حدوث تغيير في جدول groups
  Future<void> refreshProjects(int supervisorId) async {
    try {
      _projects = await SupabaseService.getGroupsBySupervisor(supervisorId);
      notifyListeners();
    } catch (e) {
      debugPrint('خطأ في التحديث اللحظي للمشاريع: $e');
    }
  }

  void _subscribeGroups(int supervisorId) {
    _groupsChannel ??= SupabaseService.subscribeSupervisorGroups(
      supervisorId,
      () => refreshProjects(supervisorId),
    );
  }

  @override
  void dispose() {
    final ch = _groupsChannel;
    if (ch != null) SupabaseService.removeChannel(ch);
    super.dispose();
  }
}
