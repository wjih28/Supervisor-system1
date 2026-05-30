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

  List<StudentGradeItem> get students => _students;
  Map<int, double?> get grades => _grades;
  bool get isLoading => _isLoading;

  /// تحميل بيانات الطلاب والمشاريع
  Future<void> loadStudents({required int supervisorId, bool isGuest = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      List<ResearchGroup> projects;
      
      if (isGuest) {
        // Fallback or use real mock
        projects = await SupabaseService.getGroupsBySupervisor(supervisorId);
      } else {
        projects = await SupabaseService.getGroupsBySupervisor(supervisorId);
      }

      _students.clear();
      
      // Load students for each project and map them
      for (var project in projects) {
        final groupStudents = await SupabaseService.getGroupStudents(project.id!);
        for (var student in groupStudents) {
          _students.add(StudentGradeItem(
            student: student,
            projectName: project.name,
          ));
        }
      }
      
      // Initialize grades (if any existed, we could load them here. For now, null means unentered)
      // Some mock initial data based on screenshots
      _grades.clear();
      if (_students.isNotEmpty) {
        _grades[1] = 95;
        _grades[2] = 88;
        _grades[3] = 92;
        _grades[4] = 85;
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
    if (grade == null) return {'text': 'لم يتم الإدخال', 'color': const Color(0xFF9CA3AF)};
    
    if (grade >= 90) return {'text': 'ممتاز', 'color': const Color(0xFF10B981)}; // Green
    if (grade >= 80) return {'text': 'جيد جداً', 'color': const Color(0xFF2D62ED)}; // Blue
    if (grade >= 70) return {'text': 'جيد', 'color': const Color(0xFFD97706)}; // Yellow/Orange
    if (grade >= 60) return {'text': 'مقبول', 'color': const Color(0xFFEA580C)}; // Orange
    return {'text': 'ضعيف', 'color': const Color(0xFFEF4444)}; // Red
  }

  int get totalStudents => _students.length;
  int get gradedStudents => _grades.values.where((g) => g != null).length;
  int get ungradedStudents => totalStudents - gradedStudents;
  double get overallAverage {
    if (gradedStudents == 0) return 0.0;
    double sum = _grades.values.where((g) => g != null).fold(0.0, (prev, curr) => prev + curr!);
    return sum / gradedStudents;
  }

  /// حفظ الدرجات
  Future<bool> saveGrades({bool isGuest = false}) async {
    if (isGuest) return false;

    // Simulate saving
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
