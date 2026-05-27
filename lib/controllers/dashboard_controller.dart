import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

/// Controller لإدارة لوحة التحكم الرئيسية
class DashboardController extends ChangeNotifier {
  int _selectedIndex = 0;
  bool _isLoading = true;
  List<ResearchGroup> _groups = [];
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
  Future<void> loadData({Supervisor? supervisor, bool isGuest = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final supervisorId = supervisor?.id ?? 1;

      // جلب المجموعات من الخدمة (التي تم استبدالها ببيانات وهمية)
      _groups = await SupabaseService.getGroupsBySupervisor(supervisorId);
      _totalProjects = _groups.length;

      // جلب بيانات المشرف
      final supervisorData = await SupabaseService.getSupervisorById(supervisorId);
      _supervisorName = supervisorData?.name ?? (isGuest ? 'ضيف العرض' : 'المشرف');
      
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
