import 'package:flutter/material.dart';
import '../../domain/models/models.dart' as app_models;
import '../../domain/repositories/project_repository.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../data/datasources/mock/mock_project_datasource.dart';
import '../../data/datasources/remote/remote_project_datasource.dart';

class Notifications extends StatefulWidget {
  final int supervisorId;
  final String supervisorName;

  const Notifications({
    super.key,
    required this.supervisorId,
    required this.supervisorName,
  });

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<app_models.Notification> _notifications = [];
  bool _isLoading = true;
  
  late final ProjectRepository _projectRepository;

  @override
  void initState() {
    super.initState();
    
    _projectRepository = ProjectRepositoryImpl(
      mockDataSource: MockProjectDataSource(),
      remoteDataSource: RemoteProjectDataSource(),
      useMock: true,
    );
    
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      _notifications = await _projectRepository.getNotifications(widget.supervisorId);
    } catch (e) {
      debugPrint('خطأ في تحميل الإشعارات: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        backgroundColor: const Color(0xFF2D62ED),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text('لا توجد إشعارات حالياً'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: notification.isRead == true ? Colors.grey : const Color(0xFF2D62ED),
                          child: const Icon(Icons.notifications, color: Colors.white),
                        ),
                        title: Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(notification.message),
                        onTap: () async {
                          await _projectRepository.markNotificationAsRead(notification.id!);
                          _loadNotifications();
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
