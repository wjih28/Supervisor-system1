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
  final Map<int, double?> _grades = {};
  bool _isLoading = true;
  int? _supervisorId;

  List<StudentGradeItem> get students => _students;
  Map<int, double?> get grades => _grades;
  bool get isLoading => _isLoading;

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
      _grades.clear();
      if (!isGuest) {
        final saved = await SupabaseService.getStudentGrades(supervisorId);
        _grades.addAll(saved);
      }
    } catch (e) {
      debugPrint('خطأ في تحميل الطلاب: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث درجة الطالب
  void updateGrade(int studentId, double? value) {
    if (value == null) {
      _grades.remove(studentId);
    } else {
      _grades[studentId] = value;
    }
    notifyListeners();
  }

  /// الحصول على التقدير واللون بناءً على الدرجة
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
  int get gradedStudents => _grades.values.where((g) => g != null).length;
  int get ungradedStudents => totalStudents - gradedStudents;
  double get overallAverage {
    if (gradedStudents == 0) return 0.0;
    double sum = _grades.values
        .where((g) => g != null)
        .fold(0.0, (prev, curr) => prev + curr!);
    return sum / gradedStudents;
  }

  /// حفظ الدرجات في قاعدة البيانات (جدول student_grades)
  Future<bool> saveGrades({bool isGuest = false}) async {
    if (isGuest || _supervisorId == null) return false;

    final rows = <Map<String, dynamic>>[];
    for (final item in _students) {
      final studentId = item.student.id;
      final grade = _grades[studentId];
      if (studentId != null && grade != null) {
        rows.add({
          'id_student': studentId,
          'id_group': item.student.groupId,
          'grade': grade,
        });
      }
    }

    if (rows.isEmpty) return false;

    return SupabaseService.saveStudentGrades(
      supervisorId: _supervisorId!,
      grades: rows,
    );
  }
}
