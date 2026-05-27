import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/supabase_service.dart';

/// Controller لإدارة ملفات المشروع
class ProjectFilesController extends ChangeNotifier {
  final Map<String, List<ProjectFile>> _files = {};
  bool _isLoading = true;

  Map<String, List<ProjectFile>> get files => _files;
  bool get isLoading => _isLoading;

  final List<Map<String, String>> stages = [
    {'key': 'proposal', 'name': 'المقترح', 'icon': '📄'},
    {'key': 'plan', 'name': 'خطة البحث', 'icon': '📋'},
    {'key': 'field', 'name': 'الدراسة الميدانية', 'icon': '🔬'},
    {'key': 'final', 'name': 'البحث النهائي', 'icon': '📚'},
  ];

  /// تحميل الملفات
  Future<void> loadFiles(int projectId) async {
    _isLoading = true;
    notifyListeners();

    for (var stage in stages) {
      final stageFiles = await SupabaseService.getProjectFiles(
        projectId,
        stage: stage['key'],
      );
      _files[stage['key']!] = stageFiles;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// إضافة ملاحظة على ملف
  Future<bool> addNote(int fileId, String note) async {
    if (note.isEmpty) return false;
    return await SupabaseService.addSupervisorNote(fileId, note);
  }

  /// الحصول على ملفات مرحلة معينة
  List<ProjectFile> getFilesForStage(String stageKey) {
    return _files[stageKey] ?? [];
  }

  /// تنسيق التاريخ
  String formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}/${date.month}/${date.day} ${date.hour}:${date.minute}';
  }
}
