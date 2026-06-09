import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

/// Controller لإدارة لوحة التحكم الرئيسية
class DashboardController extends ChangeNotifier {
  int _selectedIndex = 0;
  bool _isLoading = true;
  List<ResearchGroup> _groups = [];
  final Map<int, List<ProjectFile>> _filesByGroup = {};
  int _totalProjects = 0;
  String _supervisorName = '';
  String _departmentName = 'إدارة الأعمال';
  String _programName = 'إدارة أعمال دولية';

  // Getters
  int get selectedIndex => _selectedIndex;
  bool get isLoading => _isLoading;
  List<ResearchGroup> get groups => _groups;
  int get totalProjects => _totalProjects;
  String get supervisorName => _supervisorName;
  String get departmentName => _departmentName;
  String get programName => _programName;

  /// ملفات مجموعة معينة (تُحمَّل مع لوحة التحكم)
  List<ProjectFile> filesForGroup(int groupId) => _filesByGroup[groupId] ?? [];

  /// بيانات المشرف الضيف
  Supervisor get guestSupervisor => Supervisor(
        id: 0,
        name: 'ضيف العرض',
        email: 'guest@example.com',
        username: 'guest',
        password: '',
        isActive: false,
        programId: 1,
      );

  /// تغيير الصفحة المحددة
  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  /// تحميل البيانات
  Future<void> loadData({
    Supervisor? supervisor,
    int? supervisorId,
    String? supervisorName,
    bool isGuest = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // معرّف المشرف الفعلي: من الكائن أو الـ id المُمرّر (لا fallback صامت يخفي الخطأ)
      final effectiveId = supervisor?.id ?? supervisorId ?? (isGuest ? 0 : null);

      if (effectiveId == null) {
        // لا يوجد معرّف مشرف صالح — لا تُحمّل بيانات مشرف عشوائي
        _groups = [];
        _totalProjects = 0;
        _filesByGroup.clear();
        _supervisorName = supervisorName ?? 'المشرف';
        return;
      }

      // جلب المجموعات من الخدمة
      _groups = await SupabaseService.getGroupsBySupervisor(effectiveId);
      _totalProjects = _groups.length;

      // جلب ملفات كل مجموعة لقسم "الملفات الأخيرة"
      _filesByGroup.clear();
      for (final group in _groups) {
        if (group.id != null) {
          _filesByGroup[group.id!] =
              await SupabaseService.getGroupFiles(group.id!);
        }
      }

      // جلب بيانات المشرف
      final supervisorData =
          await SupabaseService.getSupervisorById(effectiveId);
      _supervisorName = supervisorData?.name ??
          supervisorName ??
          (isGuest ? 'ضيف العرض' : 'المشرف');

      _departmentName = 'إدارة الأعمال';
      _programName = 'إدارة أعمال دولية';
    } catch (e) {
      debugPrint('خطأ في تحميل البيانات: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
