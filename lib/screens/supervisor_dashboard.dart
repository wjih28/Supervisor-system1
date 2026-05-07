import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/models.dart';
import '../domain/repositories/project_repository.dart';
import '../data/repositories/project_repository_impl.dart';
import '../data/datasources/remote/remote_project_datasource.dart';
import '../theme/app_theme.dart';
import 'supervisor/projects_list.dart';
import 'supervisor/grades_entry.dart';
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

  @override
  void initState() {
    super.initState();
    _projectRepository = ProjectRepositoryImpl(
      remoteDataSource: RemoteProjectDataSource(),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final supervisorId = widget.supervisor?.id ?? 1;
      _groups = await _projectRepository.getGroupsBySupervisor(supervisorId);
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
      backgroundColor: AppColors.backgroundLight,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildMainContent(),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: isMobile ? _buildSidebar() : null,
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildSidebarItem(0, Icons.grid_view_rounded, 'لوحة التحكم'),
          _buildSidebarItem(1, Icons.people_outline, 'إدارة المجموعات'),
          _buildSidebarItem(2, Icons.chat_bubble_outline, 'الدردشات'),
          _buildSidebarItem(3, Icons.edit_note_rounded, 'إدخال الدرجات النهائية'),
          _buildSidebarItem(4, Icons.settings_outlined, 'الإعدادات'),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.errorRed),
            title: const Text('تسجيل الخروج', style: TextStyle(color: AppColors.errorRed)),
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.white : AppColors.textGrey),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          setState(() => _selectedIndex = index);
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SupervisorProjectsList(
              supervisorId: widget.supervisor?.id ?? 0,
              supervisorName: widget.supervisor?.name ?? "",
            )));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => GradesEntry(
              supervisorId: widget.supervisor?.id ?? 0,
            )));
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.school, color: AppColors.primaryBlue, size: 32),
          const SizedBox(width: 12),
          const Text(
            'نظام إدارة ومتابعة أبحاث التخرج',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.textGrey),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.supervisor?.name ?? 'د. محمد أحمد الشامي',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Text('المشرف الأكاديمي', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
            ],
          ),
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.backgroundLight,
            child: Icon(Icons.person, color: AppColors.primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'لوحة التحكم',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          Text(
            'مرحباً بك د. ${widget.supervisor?.name ?? "محمد أحمد الشامي"}',
            style: const TextStyle(color: AppColors.textGrey),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _buildStatCard('عدد الأبحاث التي أشرف عليها', '12', AppColors.primaryBlue, [AppColors.primaryBlue, Color(0xFF6366F1)])),
              const SizedBox(width: 20),
              Expanded(child: _buildStatCard('القسم', 'إدارة الأعمال', AppColors.secondaryPurple, [AppColors.secondaryPurple, Color(0xFFA855F7)])),
              const SizedBox(width: 20),
              Expanded(child: _buildStatCard('البرنامج', 'إدارة أعمال دولية', AppColors.accentCyan, [AppColors.accentCyan, Color(0xFF22D3EE)])),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            'نسبة إنجاز الأبحاث',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 2.5,
            ),
            itemCount: _groups.length,
            itemBuilder: (context, index) => _buildProgressCard(_groups[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, List<Color> gradient) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProgressCard(ResearchGroup group) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTag('قائد الفريق', AppColors.primaryBlue),
              const SizedBox(width: 8),
              const Text('أحمد محمد علي', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('نسبة الإنجاز', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
              Text('${group.progress?.toInt() ?? 0}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (group.progress ?? 0) / 100,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return const Center(child: Text('Desktop Layout - Under Construction'));
  }
}
