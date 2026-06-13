import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/supabase_service.dart';

/// Controller لإدارة الإعدادات
class SettingsController extends ChangeNotifier {
  bool _isLoading = true;
  SupervisorSettings? _settings;

  bool get isLoading => _isLoading;
  SupervisorSettings? get settings => _settings;

  Future<void> loadSettings({
    required Supervisor supervisor,
    required bool isGuest,
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController phoneController,
    required TextEditingController employeeIdController,
    required TextEditingController departmentController,
    required TextEditingController programController,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (isGuest) {
        _settings = SupervisorSettings(
          supervisorId: supervisor.id!,
          phoneNumber: '+968 1234 5678',
          employeeId: 'GUEST-001',
        );
        nameController.text = supervisor.name;
        emailController.text = supervisor.email ?? 'guest@example.com';
        phoneController.text = _settings?.phoneNumber ?? '';
        employeeIdController.text = _settings?.employeeId ?? '';
        departmentController.text = 'إدارة الأعمال';
        programController.text = 'إدارة أعمال دولية';
      } else {
        // _settings = await SupabaseService.getSupervisorSettings(supervisor.id!);
        _settings = SupervisorSettings(supervisorId: supervisor.id!);
        nameController.text = supervisor.name;
        emailController.text = supervisor.email ?? '';
        phoneController.text = _settings?.phoneNumber ?? '';
        employeeIdController.text = _settings?.employeeId ?? '';
        if (supervisor.programId != null) {
          final program =
              await SupabaseService.getProgramById(supervisor.programId!);
          if (program != null) {
            programController.text = program.name;
            final department = await SupabaseService.getDepartmentById(
                program.departmentId ?? 0);
            departmentController.text = department?.name ?? '';
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSettings(SupervisorSettings? newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  Future<bool> saveSettings({
    required bool isGuest,
    required Supervisor supervisor,
    required String name,
    required String email,
    required String phone,
    required String employeeId,
  }) async {
    if (_settings == null || isGuest) return false;
    _isLoading = true;
    notifyListeners();
    try {
      // We only update the Supervisor table fields (name, email).
      // phone and employeeId are kept in local state but not saved to DB since they don't exist in Supervisor table.
      _settings = _settings!.copyWith(phoneNumber: phone, employeeId: employeeId);
      return await SupabaseService.updateSupervisor(supervisor.id!, name, email);
    } catch (e) {
      debugPrint('Error saving settings: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePassword({
    required Supervisor supervisor,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
    required bool isGuest,
  }) async {
    if (isGuest) return false;
    if (newPassword != confirmPassword) return false;
    if (currentPassword != supervisor.password) return false;
    _isLoading = true;
    notifyListeners();
    try {
      return await SupabaseService.updateSupervisorPassword(
          supervisor.id!, newPassword);
    } catch (e) {
      debugPrint('Error updating password: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
