import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../repositories/project_repository.dart';
import '../repositories/project_repository_impl.dart';
import 'supervisor/projects_list.dart';
import 'supervisor/grades_entry.dart';
import 'supervisor/chats_screen.dart';
import 'supervisor/settings_screen.dart';

class SupervisorDashboard extends StatefulWidget {
  final Supervisor? supervisor;
  final bool isGuest;

  const SupervisorDashboard({super.key, this.supervisor, this.isGuest = false});

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  List<ResearchGroup> _groups = [];

  late final ProjectRepository _projectRepository;

  int _totalProjects = 0;
  String _supervisorName = '';
  String _departmentName = 'إدارة الأعمال';
  String _programName = 'إدارة أعمال دولية';

  Supervisor get _guestSupervisor => Supervisor(
        id: 0,
        name: 'ضيف العرض',
        email: 'guest@example.com',
        username: 'guest',
        password: '',
        isActive: false,
        programId: 1,
      );

  @override
  void initState() {
    super.initState();

    // تهيئة الـ Repository للاعتماد الكلي على Supabase
    _projectRepository = ProjectRepositoryImpl();

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      if (widget.isGuest) {
        _supervisorName = 'ضيف العرض';
        _departmentName = 'إدارة الأعمال';
        _programName = 'إدارة أعمال دولية';
        _groups = [
          ResearchGroup(
            id: 1,
            name: 'مجموعة بحثية تجريبية 1',
            progress: 82,
            currentStage: 'إعداد التقرير النهائي',
            status: 'قيد التنفيذ',
            description: 'بحث تجريبي لعرض تصميم الواجهة.',
          ),
          ResearchGroup(
            id: 2,
            name: 'مجموعة بحثية تجريبية 2',
            progress: 58,
            currentStage: 'مراجعة المشرف',
            status: 'قيد التنفيذ',
            description: 'مجموعة اختبارية لعرض واجهة المشاريع.',
          ),
          ResearchGroup(
            id: 3,
            name: 'مجموعة بحثية تجريبية 3',
            progress: 97,
            currentStage: 'العرض والمناقشة',
            status: 'قيد التنفيذ',
            description: 'مجموعة تجريبية متقدمة لعرض الواجهة.',
          ),
        ];
        _totalProjects = _groups.length;
      } else {
        final supervisorId = widget.supervisor?.id ?? 1;

        _groups = await _projectRepository.getGroupsBySupervisor(supervisorId);
        _totalProjects = _groups.length;

        final supervisorData =
            await _projectRepository.getSupervisorById(supervisorId);
        _supervisorName = supervisorData?.name ?? 'المشرف';
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: isMobile
          ? AppBar(
              title: const Text('نظام إدارة أبحاث التخرج'),
              backgroundColor: const Color(0xFF2D62ED),
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {},
                ),
              ],
            )
          : null,
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
      drawer: isMobile
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Color(0xFF2D62ED),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.school, color: Colors.white, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          _supervisorName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                            widget.isGuest
                                ? 'عرض الضيف التجريبي'
                                : 'المشرف الأكاديمي',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  _buildDrawerItem(0, Icons.grid_view_rounded, 'لوحة التحكم',
                      () {
                    Navigator.pop(context);
                    setState(() => _selectedIndex = 0);
                  }),
                  _buildDrawerItem(1, Icons.people_outline, 'إدارة المجموعات',
                      () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SupervisorProjectsList(
                                  supervisorId: widget.supervisor?.id ?? 0,
                                  supervisorName: _supervisorName,
                                  isGuest: widget.isGuest,
                                )));
                  }),
                  _buildDrawerItem(2, Icons.chat_bubble_outline, 'الدردشات',
                      () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatsScreen(
                                  supervisorId: widget.supervisor?.id ?? 0,
                                  supervisorName: _supervisorName,
                                  isGuest: widget.isGuest,
                                )));
                  }),
                  _buildDrawerItem(3, Icons.edit_note_rounded, 'إدخال الدرجات',
                      () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GradesEntry(
                                  supervisorId: widget.supervisor?.id ?? 0,
                                  isGuest: widget.isGuest,
                                )));
                  }),
                  _buildDrawerItem(4, Icons.settings, 'الإعدادات', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsScreen(
                          supervisor: widget.isGuest
                              ? _guestSupervisor
                              : widget.supervisor!,
                          isGuest: widget.isGuest,
                        ),
                      ),
                    );
                  }),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('تسجيل الخروج'),
                    onTap: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildDrawerItem(
      int index, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2D62ED)),
      title: Text(title),
      selected: _selectedIndex == index,
      selectedTileColor: const Color(0xFF2D62ED).withOpacity(0.1),
      onTap: onTap,
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('لوحة التحكم',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748))),
          const SizedBox(height: 8),
          Text(
            widget.isGuest
                ? 'مرحباً بك في عرض الضيف التجريبي'
                : 'مرحباً بك د. $_supervisorName',
            style: const TextStyle(fontSize: 14, color: Color(0xFF718096)),
          ),
          const SizedBox(height: 24),
          _buildMobileInfoCard(
              title: 'البرنامج',
              value: _programName,
              color: const Color(0xFF06B6D4)),
          const SizedBox(height: 12),
          _buildMobileInfoCard(
              title: 'القسم',
              value: _departmentName,
              color: const Color(0xFF7C3AED)),
          const SizedBox(height: 12),
          _buildMobileInfoCard(
              title: 'عدد الأبحاث',
              value: _totalProjects.toString(),
              color: const Color(0xFF2D62ED)),
          const SizedBox(height: 24),
          const Text('المجموعات الحالية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ..._groups
              .map((group) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(group.name),
                      subtitle:
                          Text('المرحلة: ${group.currentStage ?? "غير محدد"}'),
                      trailing: Text('${group.progress?.toInt() ?? 0}%',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D62ED))),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildMobileInfoCard(
      {required String title, required String value, required Color color}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Color(0xFF718096), fontWeight: FontWeight.w500)),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return const Center(child: Text('Desktop Layout - Under Construction'));
  }
}
