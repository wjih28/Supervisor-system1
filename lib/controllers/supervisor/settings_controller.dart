import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/supabase_service.dart';

/// Controller لإدارة الإعدادات
class SettingsController extends ChangeNotifier {
  bool _isLoading = true;
  SupervisorSettings? _settings;
  String? _supervisPhoto;

  bool get isLoading => _isLoading;
  SupervisorSettings? get settings => _settings;
  String? get supervisPhoto => _supervisPhoto;

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
      _supervisPhoto = supervisor.supervisPhoto;
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

  Future<void> pickAndUploadImage(Supervisor supervisor, bool isGuest, BuildContext context) async {
    if (isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('عرض الضيف: تغيير الصورة غير متاح')),
      );
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        _isLoading = true;
        notifyListeners();

        final fileBytes = await image.readAsBytes();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        
        final String path = '${supervisor.id}/$fileName';

        if (kIsWeb) {
          await Supabase.instance.client.storage
              .from('supervisor_photo')
              .uploadBinary(path, fileBytes);
        } else {
          final file = File(image.path);
          await Supabase.instance.client.storage
              .from('supervisor_photo')
              .upload(path, file);
        }

        final photoUrl = Supabase.instance.client.storage
            .from('supervisor_photo')
            .getPublicUrl(path);

        final success = await SupabaseService.updateSupervisorPhoto(
            supervisor.id!, photoUrl);

        if (success) {
          _supervisPhoto = photoUrl;
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم رفع الصورة بنجاح')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء رفع الصورة')),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteImage(Supervisor supervisor, bool isGuest, BuildContext context) async {
    if (isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('عرض الضيف: تغيير الصورة غير متاح')),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();
    try {
      final success = await SupabaseService.updateSupervisorPhoto(
          supervisor.id!, null);

      if (success) {
        _supervisPhoto = null;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف الصورة بنجاح')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('حدث خطأ أثناء حذف الصورة')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error deleting image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء حذف الصورة')),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
