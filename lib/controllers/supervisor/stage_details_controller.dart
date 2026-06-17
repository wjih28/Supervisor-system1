import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show RealtimeChannel;
import '../../models/models.dart';
import '../../services/supabase_service.dart';

/// Controller لإدارة بيانات شاشة تفاصيل مرحلة واحدة وحفظ إجراءات المشرف عليها.
class StageDetailsController extends ChangeNotifier {
  final int groupId;
  final int stageNumber;
  final int? stageId;
  final int supervisorId;

  StageDetailsController({
    required this.groupId,
    required this.stageNumber,
    required this.stageId,
    required this.supervisorId,
  });

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  ResearchGroup? _group;
  List<Student> _students = [];

  Stage1Info? _stage1;
  Stage2Info? _stage2;
  List<String> _stage2Titles = [];
  Stage3Info? _stage3;
  Stage4Info? _stage4;
  List<Stage5Section> _stage5Sections = [];
  Stage6Info? _stage6;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  ResearchGroup? get group => _group;
  List<Student> get students => _students;
  int? get leaderId => _group?.leaderId;
  Stage1Info? get stage1 => _stage1;
  Stage2Info? get stage2 => _stage2;
  List<String> get stage2Titles => _stage2Titles;
  Stage3Info? get stage3 => _stage3;
  Stage4Info? get stage4 => _stage4;
  List<Stage5Section> get stage5Sections => _stage5Sections;
  Stage6Info? get stage6 => _stage6;

  final Map<int, double?> _studentGrades = {};
  Map<int, double?> get studentGrades => _studentGrades;

  RealtimeChannel? _channel;

  /// تحميل بيانات المجموعة + الطلاب + بيانات المرحلة المطلوبة.
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _group = await SupabaseService.getProjectById(groupId);
      _students = await SupabaseService.getGroupStudents(groupId);
      // جلب الدرجات الحالية لطلاب هذه المجموعة
      final allGrades = await SupabaseService.getStudentGrades(groupId);
      _studentGrades.clear();
      _studentGrades.addAll(allGrades);
      await _fetchStageData();
    } catch (e) {
      _error = e.toString();
      debugPrint('خطأ في تحميل تفاصيل المرحلة: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// جلب بيانات المرحلة الحالية فقط (يُستخدم في التحميل الأولي وفي التحديث اللحظي).
  Future<void> _fetchStageData() async {
    switch (stageNumber) {
      case 1:
        _stage1 = await SupabaseService.getStage1(groupId);
        break;
      case 2:
        _stage2 = await SupabaseService.getStage2(groupId);
        _stage2Titles = await SupabaseService.getSecondStageTitles();
        break;
      case 3:
        _stage3 = await SupabaseService.getStage3(groupId);
        break;
      case 4:
        _stage4 = await SupabaseService.getStage4(groupId);
        break;
      case 5:
        _stage5Sections = await SupabaseService.getStage5Sections(groupId);
        break;
      case 6:
        _stage6 = await SupabaseService.getStage6(groupId);
        break;
    }
  }

  /// إعادة جلب بيانات المرحلة دون إظهار شاشة التحميل (للتحديث اللحظي).
  Future<void> refreshStageData() async {
    try {
      await _fetchStageData();
      notifyListeners();
    } catch (e) {
      debugPrint('خطأ في التحديث اللحظي للمرحلة: $e');
    }
  }

  /// الاشتراك في تغييرات جدول المرحلة لهذه المجموعة (تحديث لحظي).
  void startRealtime() {
    _channel ??=
        SupabaseService.subscribeStage(stageNumber, groupId, refreshStageData);
  }

  @override
  void dispose() {
    final ch = _channel;
    if (ch != null) SupabaseService.removeChannel(ch);
    super.dispose();
  }

  Future<bool> _run(Future<bool> Function() action) async {
    _isSaving = true;
    notifyListeners();
    bool ok = false;
    try {
      ok = await action();
    } catch (e) {
      debugPrint('خطأ أثناء حفظ المرحلة: $e');
      ok = false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
    return ok;
  }

  // ---- المرحلة 1 ----
  Future<bool> setStage1Approval(bool approved) => _run(() async {
        final ok =
            await SupabaseService.updateStage1Approval(groupId, approved);
        if (ok) _stage1 = await SupabaseService.getStage1(groupId);
        return ok;
      });

  // ---- المرحلة 2 ----
  Future<bool> setStage2Approval(bool approved) => _run(() async {
        final ok =
            await SupabaseService.updateStage2Approval(groupId, approved);
        if (ok) _stage2 = await SupabaseService.getStage2(groupId);
        return ok;
      });

  Future<bool> addStage2TitleNote(String titleName, String note) =>
      _run(() async {
        final ok =
            await SupabaseService.addStage2TitleNote(groupId, titleName, note);
        if (ok) _stage2 = await SupabaseService.getStage2(groupId);
        return ok;
      });

  // ---- المرحلة 3 ----
  Future<bool> saveStage3({
    required bool discussed,
    required double percent,
    DateTime? date,
    String? note,
  }) =>
      _run(() async {
        final ok = await SupabaseService.updateStage3(
          groupId,
          discussed: discussed,
          percent: percent,
          date: date,
          note: note,
        );
        if (ok) _stage3 = await SupabaseService.getStage3(groupId);
        return ok;
      });

  // ---- المرحلة 4 ----
  Future<bool> saveStage4({required bool approved, String? notes}) =>
      _run(() async {
        final ok = await SupabaseService.updateStage4(groupId,
            approved: approved, notes: notes);
        if (ok) _stage4 = await SupabaseService.getStage4(groupId);
        return ok;
      });

  // ---- المرحلة 5 ----
  Future<bool> saveStage5Section(int titleId,
          {required bool approved, String? note}) =>
      _run(() async {
        final ok = await SupabaseService.updateStage5Section(groupId, titleId,
            approved: approved, note: note);
        if (ok) {
          _stage5Sections = await SupabaseService.getStage5Sections(groupId);
        }
        return ok;
      });

  // ---- المرحلة 6 ----
  Future<bool> saveStage6({
    bool? approval,
    DateTime? date,
    required Map<int, double?> studentGrades,
  }) =>
      _run(() async {
        final okStage = await SupabaseService.updateStage6(groupId,
            approval: approval, date: date);

        // حفظ الدرجات للطلاب
        if (studentGrades.isNotEmpty) {
          final gradesList = <Map<String, dynamic>>[];
          studentGrades.forEach((studentId, grade) {
            if (grade != null) {
              gradesList.add({
                'id_student': studentId,
                'id_group': groupId,
                'grade': grade,
              });
            }
          });
          if (gradesList.isNotEmpty) {
            await SupabaseService.saveStudentGrades(
              supervisorId: supervisorId,
              grades: gradesList,
            );
          }
        }

        if (okStage) _stage6 = await SupabaseService.getStage6(groupId);
        return okStage;
      });
}
