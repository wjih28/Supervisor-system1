import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

/// Controller لإدارة منطق تسجيل الدخول
class LoginController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// تسجيل دخول المشرف
  Future<Supervisor?> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response =
          await SupabaseService.loginSupervisor(username, password);

      if (response != null && response['role'] == 'supervisor') {
        final Supervisor supervisor = response['user'];
        _isLoading = false;
        notifyListeners();
        return supervisor;
      } else {
        _errorMessage = 'اسم المستخدم أو كلمة المرور غير صحيحة.';
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء تسجيل الدخول: $e';
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  /// مسح رسالة الخطأ
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
