import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/models.dart';
import '../domain/repositories/project_repository.dart';
import '../data/repositories/project_repository_impl.dart';
import '../data/datasources/mock/mock_project_datasource.dart';
import '../data/datasources/remote/remote_project_datasource.dart';
import 'supervisor/projects_list.dart';
import 'supervisor/grades_entry.dart';
import 'supervisor/settings_screen.dart';
import 'supervisor/chats_screen.dart';

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

  @override
  void initState() {
    super.initState();
    
    // تهيئة الـ Repository مع إمكانية التبديل بين Mock و Real
    _projectRepository = ProjectRepositoryImpl(
      mockDataSource: MockProjectDataSource(),
      remoteDataSource: RemoteProjectDataSource(),
      useMock: true, // اجعلها false للتحويل إلى Supabase
    );
    
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final supervisorId = widget.supervisor?.id ?? 1;
      
      _groups = await _projectRepository.getGroupsBySupervisor(supervisorId);
      _totalProjects = _groups.length;

      final supervisorData = await _projectRepository.getSupervisorById(supervisorId);
      _supervisorName = supervisorData?.name ?? 'المشرف';

    } catch (e) {
      debugPrint('خطأ في تحميل البيانات: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: isMobile ? _buildMobileAppBar() : null,
      drawer: isMobile ? _buildDrawer() : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : isMobile
              ? _buildMobileLayout()
              : _buildDesktopLayout(),
    );
  }

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: const Text(
        'نظام إدارة ومتابعة أبحاث التخرج',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D62ED),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.grey),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF2D62ED)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Color(0xFF2D62ED)),
                ),
                const SizedBox(height: 12),
                Text(
                  _supervisorName,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Text('المشرف الأكاديمي', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          _buildDrawerItem(0, Icons.grid_view_rounded, 'لوحة التحكم', () {
            Navigator.pop(context);
            setState(() => _selectedIndex = 0);
          }),
          _buildDrawerItem(1, Icons.people_outline, 'إدارة المجموعات', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => SupervisorProjectsList(
              supervisorId: widget.supervisor?.id ?? 0,
              supervisorName: _supervisorName,
              isGuest: widget.isGuest,
            )));
          }),
          _buildDrawerItem(2, Icons.chat_bubble_outline, 'الدردشات', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatsScreen(
              supervisorId: widget.supervisor?.id ?? 0,
              supervisorName: _supervisorName,
              isGuest: widget.isGuest,
            )));
          }),
          _buildDrawerItem(3, Icons.edit_note_rounded, 'إدخال الدرجات', () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => GradesEntry(
              supervisorId: widget.supervisor?.id ?? 0,
            )));
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
    );
  }

  Widget _buildDrawerItem(int index, IconData icon, String title, VoidCallback onTap) {
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('لوحة التحكم', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
          const SizedBox(height: 8),
          Text('مرحباً بك د. $_supervisorName', style: const TextStyle(fontSize: 14, color: Color(0xFF718096))),
          const SizedBox(height: 24),
          _buildMobileInfoCard(title: 'البرنامج', value: _programName, color: const Color(0xFF06B6D4)),
          const SizedBox(height: 12),
          _buildMobileInfoCard(title: 'القسم', value: _departmentName, color: const Color(0xFF7C3AED)),
          const SizedBox(height: 12),
          _buildMobileInfoCard(title: 'عدد الأبحاث', value: _totalProjects.toString(), color: const Color(0xFF2D62ED)),
          const SizedBox(height: 24),
          const Text('المجموعات الحالية (Mock Data)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ..._groups.map((group) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(group.name),
              subtitle: Text('المرحلة: ${group.currentStage ?? "غير محدد"}'),
              trailing: Text('${group.progress?.toInt() ?? 0}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D62ED))),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildMobileInfoCard({required String title, required String value, required Color color}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF718096), fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return const Center(child: Text('Desktop Layout - Under Construction'));
  }
}
