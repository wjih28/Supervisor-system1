import 'package:flutter/material.dart';
import '../../controllers/supervisor/notifications_controller.dart';
import '../widgets/desktop_layout.dart';
import 'projects_list_view.dart';
import 'chats_view.dart';
import 'grades_entry_view.dart';
import 'package:intl/intl.dart';

class NotificationsView extends StatefulWidget {
  final int supervisorId;
  final String supervisorName;
  final bool isGuest;

  const NotificationsView({
    super.key,
    required this.supervisorId,
    required this.supervisorName,
    this.isGuest = false,
  });

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> with SingleTickerProviderStateMixin {
  final NotificationsController _controller = NotificationsController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller.loadNotifications(widget.supervisorId);
  }

  void _handleNotificationTap(dynamic notification) async {
    // 1. Mark as read
    if (notification.isRead != true) {
      await _controller.markAsRead(notification.id!, widget.supervisorId);
    }
    
    if (!mounted) return;

    // 2. Context-aware navigation based on title keywords
    final title = notification.title.toLowerCase();
    if (title.contains('ملف') || title.contains('اعتماد') || title.contains('مرحلة')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProjectsListView(
            supervisorId: widget.supervisorId,
            supervisorName: widget.supervisorName,
            isGuest: widget.isGuest,
          ),
        ),
      );
    } else if (title.contains('دردشة') || title.contains('رسالة')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatsView(
            supervisorId: widget.supervisorId,
            supervisorName: widget.supervisorName,
            isGuest: widget.isGuest,
          ),
        ),
      );
    } else if (title.contains('درجات')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GradesEntryView(
            supervisorId: widget.supervisorId,
            supervisorName: widget.supervisorName,
            isGuest: widget.isGuest,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(isDesktop),
        _buildTabBar(isDesktop),
        Expanded(
          child: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNotificationsList(_controller.notifications, isDesktop),
                    _buildNotificationsList(_controller.notifications.where((n) => n.isRead != true).toList(), isDesktop),
                  ],
                ),
        ),
      ],
    );

    return DesktopLayout(
      selectedIndex: -1, // No sidebar item selected
      supervisorId: widget.supervisorId,
      supervisorName: widget.supervisorName,
      isGuest: widget.isGuest,
      child: Container(color: const Color(0xFFF5F7FB), child: content),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isDesktop ? 32 : 16, isDesktop ? 32 : 16, isDesktop ? 32 : 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF4B5563)),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Text(
                'الإشعارات',
                style: TextStyle(
                  fontSize: isDesktop ? 28 : 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (isDesktop) ...[
                OutlinedButton.icon(
                  onPressed: () => _controller.markAllAsRead(widget.supervisorId),
                  icon: const Icon(Icons.done_all, size: 18),
                  label: const Text('تحديد الكل كمقروء'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2D62ED),
                    side: const BorderSide(color: Color(0xFF2D62ED)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _controller.clearAll(widget.supervisorId),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('مسح الكل'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ] else ...[
                IconButton(
                  onPressed: () => _controller.markAllAsRead(widget.supervisorId),
                  icon: const Icon(Icons.done_all, color: Color(0xFF2D62ED)),
                  tooltip: 'تحديد الكل كمقروء',
                ),
                IconButton(
                  onPressed: () => _controller.clearAll(widget.supervisorId),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'مسح الكل',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDesktop) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF2D62ED),
        unselectedLabelColor: const Color(0xFF718096),
        indicatorColor: const Color(0xFF2D62ED),
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'الكل'),
          Tab(text: 'غير المقروءة'),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<dynamic> notifs, bool isDesktop) {
    if (notifs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('لا توجد إشعارات حالياً', style: TextStyle(fontSize: 18, color: Color(0xFF718096))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isDesktop ? 32 : 16),
      itemCount: notifs.length,
      itemBuilder: (context, index) {
        final notification = notifs[index];
        final isRead = notification.isRead == true;
        
        // Determine icon and colors based on notification title
        IconData icon = Icons.notifications_active;
        Color iconColor = Colors.white;
        Color bgColor = const Color(0xFF2D62ED); // Blue default
        
        if (notification.title.contains('ملف')) {
          icon = Icons.file_present;
          bgColor = const Color(0xFF3B82F6); // Blue
        } else if (notification.title.contains('اعتماد')) {
          icon = Icons.check_circle_outline;
          bgColor = const Color(0xFF10B981); // Green
        } else if (notification.title.contains('دردشة')) {
          icon = Icons.chat_bubble_outline;
          bgColor = const Color(0xFFF59E0B); // Orange
        } else if (notification.title.contains('درجات')) {
          icon = Icons.grade;
          bgColor = const Color(0xFFEF4444); // Red
        }

        final timeStr = notification.createdAt != null
            ? DateFormat('hh:mm a - yyyy/MM/dd').format(notification.createdAt!)
            : '';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : const Color(0xFFEFF6FF), // Light blue for unread
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isRead ? const Color(0xFFE2E8F0) : const Color(0xFFBFDBFE)),
            boxShadow: isRead ? null : [
              BoxShadow(color: const Color(0xFF3B82F6).withAlpha(15), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _handleNotificationTap(notification),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: isRead ? Colors.grey[300] : bgColor,
                      radius: 24,
                      child: Icon(icon, color: isRead ? Colors.grey[600] : iconColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                  fontSize: 16,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              if (!isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(color: Color(0xFF2D62ED), shape: BoxShape.circle),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            notification.message,
                            style: TextStyle(
                              color: isRead ? const Color(0xFF6B7280) : const Color(0xFF4B5563),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            timeStr,
                            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }
}
