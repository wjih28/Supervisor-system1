import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

/// Controller لإدارة إضافة الملاحظات
class FeedbackController extends ChangeNotifier {
  String _selectedStage = 'proposal';
  bool _isSubmitting = false;

  String get selectedStage => _selectedStage;
  bool get isSubmitting => _isSubmitting;

  final List<Map<String, String>> stages = [
    {'key': 'proposal', 'name': 'المقترح'},
    {'key': 'plan', 'name': 'خطة البحث'},
    {'key': 'field', 'name': 'الدراسة الميدانية'},
    {'key': 'writing', 'name': 'الكتابة'},
    {'key': 'final', 'name': 'البحث النهائي'},
  ];

  /// تغيير المرحلة المحددة
  void setSelectedStage(String stage) {
    _selectedStage = stage;
    notifyListeners();
  }

  /// إرسال الملاحظة
  Future<bool> submitFeedback({
    required int projectId,
    required int supervisorId,
    required String comment,
  }) async {
    if (comment.isEmpty) return false;

    _isSubmitting = true;
    notifyListeners();

    final success = await SupabaseService.addProjectFeedback(
      projectId,
      supervisorId,
      _selectedStage,
      comment,
    );

    _isSubmitting = false;
    notifyListeners();

    return success;
  }
}
