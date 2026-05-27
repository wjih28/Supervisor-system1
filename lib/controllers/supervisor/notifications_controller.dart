import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/supabase_service.dart';

/// Controller لإدارة الإشعارات
class NotificationsController extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;

  Future<void> loadNotifications(int supervisorId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = await SupabaseService.getNotifications(supervisorId);
    } catch (e) {
      debugPrint('خطأ في تحميل الإشعارات: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId, int supervisorId) async {
    await SupabaseService.markNotificationAsRead(notificationId);
    await loadNotifications(supervisorId);
  }

  Future<void> markAllAsRead(int supervisorId) async {
    await SupabaseService.markAllNotificationsAsRead(supervisorId);
    await loadNotifications(supervisorId);
  }

  Future<void> clearAll(int supervisorId) async {
    await SupabaseService.clearAllNotifications(supervisorId);
    await loadNotifications(supervisorId);
  }
}
