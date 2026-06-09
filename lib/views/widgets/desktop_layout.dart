import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/models.dart';
import '../dashboard_view.dart';
import '../supervisor/projects_list_view.dart';
import '../supervisor/chats_view.dart';
import '../supervisor/grades_entry_view.dart';
import '../supervisor/settings_view.dart';
import '../supervisor/notifications_view.dart';
import '../../services/supabase_service.dart';
import '../login_view.dart';

class DesktopLayout extends StatefulWidget {
  final Widget child;
  final int selectedIndex;
  final int? supervisorId;
  final Supervisor? supervisor;
  final bool isGuest;
  final String supervisorName;

  const DesktopLayout({
    super.key,
    required this.child,
    required this.selectedIndex,
    this.supervisorId,
    this.supervisor,
    this.isGuest = false,
    required this.supervisorName,
  });

  @override
  State<DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _unreadCount = 0;

  /// Returns first and last name only (e.g. "محمد أحمد الشامي" → "محمد الشامي")
  String _getShortName(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length <= 2) return fullName;
    return '${parts.first} ${parts.last}';
  }

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final supervisorId = widget.supervisorId ?? widget.supervisor?.id ?? 0;
    if (supervisorId != 0) {
      final notifs = await SupabaseService.getNotifications(supervisorId);
      if (mounted) {
        setState(() {
          _unreadCount = notifs.where((n) => n.isRead != true).length;
        });
      }
    }
  }

  void _onSidebarItemSelected(int index) {
    if (!MediaQuery.of(context).size.width.isFinite ||
        MediaQuery.of(context).size.width < 800) {
      if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
        Navigator.pop(context); // Close drawer
      }
    }

    if (index == widget.selectedIndex) return;

    // Based on the index, navigate to the corresponding view.
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => DashboardView(
              supervisor: widget.supervisor,
              supervisorId: widget.supervisorId ?? widget.supervisor?.id,
              supervisorName: widget.supervisorName,
              isGuest: widget.isGuest,
            ),
            transitionDuration: Duration.zero,
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ProjectsListView(
              supervisorId: widget.supervisorId ?? widget.supervisor?.id ?? 0,
              supervisorName: widget.supervisorName,
              isGuest: widget.isGuest,
            ),
            transitionDuration: Duration.zero,
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ChatsView(
              supervisorId: widget.supervisorId ?? widget.supervisor?.id ?? 0,
              supervisorName: widget.supervisorName,
              isGuest: widget.isGuest,
            ),
            transitionDuration: Duration.zero,
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => GradesEntryView(
              supervisorId: widget.supervisorId ?? widget.supervisor?.id ?? 0,
              supervisorName: widget.supervisorName,
              isGuest: widget.isGuest,
            ),
            transitionDuration: Duration.zero,
          ),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => SettingsView(
              supervisor: widget.supervisor ??
                  Supervisor(
                    id: widget.supervisorId ?? 0,
                    name: widget.supervisorName,
                    email: '',
                    username: '',
                    password: '',
                    isActive: true,
                    programId: 1,
                  ),
              isGuest: widget.isGuest,
            ),
            transitionDuration: Duration.zero,
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF5F7FB),
        drawer: isDesktop ? null : Drawer(child: _buildSidebar(context)),
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context, isDesktop),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isDesktop) ...[
                      _buildSidebar(context),
                      const VerticalDivider(
                          width: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                    ],
                    Expanded(child: widget.child),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDesktop) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine title text based on width to prevent overflow
    String titleText = 'نظام إدارة ومتابعة أبحاث التخرج';
    if (screenWidth < 600) {
      titleText = 'متابعة الأبحاث';
    }
    if (screenWidth < 360) {
      titleText = 'الأبحاث';
    }

    return Container(
      height: 70,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Right Side: Menu Button (on mobile), School Logo, and Title
          Expanded(
            child: Row(
              children: [
                if (!isDesktop) ...[
                  IconButton(
                    icon: const Icon(Icons.menu, color: Color(0xFF2D62ED)),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                ],
                const CircleAvatar(
                  backgroundColor: Color(0xFF2D62ED),
                  radius: 15,
                  child: Icon(Icons.school, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    titleText,
                    style: TextStyle(
                      fontSize: screenWidth < 400 ? 12 : 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D62ED),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Left Side: Notifications, Name/Role, Avatar, Logout
          Row(
            children: [
              // Notifications
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none,
                        color: Color(0xFF718096), size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      final supervisorId =
                          widget.supervisorId ?? widget.supervisor?.id ?? 0;
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationsView(
                            supervisorId: supervisorId,
                            supervisorName: widget.supervisorName,
                            isGuest: widget.isGuest,
                          ),
                        ),
                      );
                      _loadUnreadCount();
                    },
                  ),
                  if (_unreadCount > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$_unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),

              // Name & Role Column
              ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: screenWidth < 400 ? 80 : 110),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'د. ${_getShortName(widget.supervisorName)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth < 400 ? 10 : 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.isGuest ? 'عرض الضيف' : 'المشرف الأكاديمي',
                      style: TextStyle(
                        color: const Color(0xFF718096),
                        fontSize: screenWidth < 400 ? 8 : 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Avatar
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFF3F4F6),
                child: Image.asset(
                  'assets/images/avatar_placeholder.png',
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.person, color: Colors.grey, size: 18),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        children: [
          _buildSidebarItem(0, Icons.grid_view_rounded, 'لوحة التحكم'),
          _buildSidebarItem(1, Icons.people_outline, 'إدارة المجموعات'),
          _buildSidebarItem(2, Icons.chat_bubble_outline, 'الدردشات'),
          _buildSidebarItem(
              3, Icons.edit_note_rounded, 'إدخال الدرجات النهائية'),
          _buildSidebarItem(4, Icons.settings, 'الإعدادات'),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('تسجيل الخروج',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onTap: () async {
              try {
                await Supabase.instance.client.auth.signOut();
              } catch (e) {
                // Ignore errors if mock mode or no session
              }
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginView()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String title) {
    final isSelected = widget.selectedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2D62ED) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : const Color(0xFF718096),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF4A5568),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () => _onSidebarItemSelected(index),
      ),
    );
  }
}
