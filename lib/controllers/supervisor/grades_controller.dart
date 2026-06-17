import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/supabase_service.dart';

class StudentGradeItem {
  final Student student;
  final String projectName;

  StudentGradeItem({
    required this.student,
    required this.projectName,
  });
}

/// Controller لإدارة إدخال الدرجات للطلاب
class GradesController extends ChangeNotifier {
  final List<StudentGradeItem> _students = [];
  final Map<int, double?> _stage6Grades = {};
  final Map<int, double?> _finalEntryGrades = {};
  bool _isLoading = true;
  int? _supervisorId;

  List<StudentGradeItem> get students => _students;
  Map<int, double?> get stage6Grades => _stage6Grades;
  Map<int, double?> get finalEntryGrades => _finalEntryGrades;
  bool get isLoading => _isLoading;

  double? getTotalGrade(int studentId) {
    final s6 = _stage6Grades[studentId];
    final fin = _finalEntryGrades[studentId];
    if (s6 == null && fin == null) return null;
    return (s6 ?? 0.0) + (fin ?? 0.0);
  }

  /// تحميل بيانات الطلاب والمشاريع والدرجات المحفوظة
  Future<void> loadStudents(
      {required int supervisorId, bool isGuest = false}) async {
    _isLoading = true;
    _supervisorId = supervisorId;
    notifyListeners();

    try {
      final projects =
          await SupabaseService.getGroupsBySupervisor(supervisorId);

      _students.clear();

      // Load students for each project and map them
      for (var project in projects) {
        final groupStudents =
            await SupabaseService.getGroupStudents(project.id!);
        for (var student in groupStudents) {
          _students.add(StudentGradeItem(
            student: student,
            projectName: project.name,
          ));
        }
      }

      // تحميل الدرجات المحفوظة من قاعدة البيانات (مفتاحها معرّف الطالب)
      _stage6Grades.clear();
      _finalEntryGrades.clear();
      if (!isGuest) {
        final saved = await SupabaseService.getStudentGradesBySupervisor(supervisorId);
        for (var row in saved) {
          final sId = row['id_student'] as int?;
          if (sId != null) {
            // Stage 6 grade is now stored in 'final_grade' column
            if (row['final_grade'] != null) {
              _stage6Grades[sId] = (row['final_grade'] as num).toDouble();
            }
            // Final Entry grade is now stored in 'supervisor_grade' column
            if (row['supervisor_grade'] != null) {
              _finalEntryGrades[sId] = (row['supervisor_grade'] as num).toDouble();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('خطأ في تحميل الطلاب: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث الدرجة النهائية للطالب
  void updateGrade(int studentId, double? value) {
    if (value == null) {
      _finalEntryGrades.remove(studentId);
    } else {
      _finalEntryGrades[studentId] = value;
    }
    notifyListeners();
  }

  /// الحصول على التقدير واللون بناءً على الدرجة الكلية
  Map<String, dynamic> getRating(double? grade) {
    if (grade == null) {
      return {'text': 'لم يتم الإدخال', 'color': const Color(0xFF9CA3AF)};
    }
    if (grade >= 90) {
      return {'text': 'ممتاز', 'color': const Color(0xFF10B981)}; // Green
    }
    if (grade >= 80) {
      return {'text': 'جيد جداً', 'color': const Color(0xFF2D62ED)}; // Blue
    }
    if (grade >= 70) {
      return {'text': 'جيد', 'color': const Color(0xFFD97706)}; // Yellow/Orange
    }
    if (grade >= 60) {
      return {'text': 'مقبول', 'color': const Color(0xFFEA580C)}; // Orange
    }
    return {'text': 'ضعيف', 'color': const Color(0xFFEF4444)}; // Red
  }

  int get totalStudents => _students.length;
  int get gradedStudents => _finalEntryGrades.values.where((g) => g != null).length;
  int get ungradedStudents => totalStudents - gradedStudents;
  double get overallAverage {
    if (gradedStudents == 0) return 0.0;
    double sum = _students.map((e) => getTotalGrade(e.student.id!) ?? 0.0).fold(0.0, (prev, curr) => prev + curr);
    return sum / totalStudents;
  }

  /// حفظ الدرجات في قاعدة البيانات (جدول student_grades)
  Future<bool> saveGrades({bool isGuest = false}) async {
    if (isGuest || _supervisorId == null) return false;

    final rows = <Map<String, dynamic>>[];
    for (final item in _students) {
      final studentId = item.student.id;
      final finGrade = _finalEntryGrades[studentId];
      if (studentId != null && finGrade != null) {
        final s6Grade = _stage6Grades[studentId] ?? 0.0;
        final total = s6Grade + finGrade;
        rows.add({
          'id_student': studentId,
          'id_group': item.student.groupId,
          'supervisor_grade': finGrade,
          'total_grade': total,
        });
      }
    }

    if (rows.isEmpty) return false;

    return SupabaseService.saveStudentFinalGrades(
      supervisorId: _supervisorId!,
      grades: rows,
    );
  }
}
