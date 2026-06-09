import 'package:flutter/material.dart';
import '../../controllers/supervisor/projects_list_controller.dart';
import '../../models/models.dart';
import '../../services/supabase_service.dart';
import '../widgets/desktop_layout.dart';
import 'project_details_view.dart';

class ProjectsListView extends StatefulWidget {
  final int supervisorId;
  final String supervisorName;
  final bool isGuest;

  const ProjectsListView({
    super.key,
    required this.supervisorId,
    required this.supervisorName,
    this.isGuest = false,
  });

  @override
  State<ProjectsListView> createState() => _ProjectsListViewState();
}

class _ProjectsListViewState extends State<ProjectsListView> {
  final ProjectsListController _controller = ProjectsListController();
  final Map<int, List<Student>> _groupStudents = {};

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller
        .loadProjects(
            supervisorId: widget.supervisorId, isGuest: widget.isGuest)
        .then((_) {
      _loadStudents();
    });
  }

  Future<void> _loadStudents() async {
    for (var group in _controller.projects) {
      if (group.id != null) {
        final students = await SupabaseService.getGroupStudents(group.id!);
        setState(() {
          _groupStudents[group.id!] = students;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    Widget content = _controller.isLoading
        ? const Center(child: CircularProgressIndicator())
        : _controller.projects.isEmpty
            ? const Center(child: Text('لا توجد مشاريع حالياً'))
            : _buildProjectsGrid(isMobile);

    return DesktopLayout(
      selectedIndex: 1,
      supervisorId: widget.supervisorId,
      supervisorName: widget.supervisorName,
      isGuest: widget.isGuest,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إدارة المجموعات',
              style: TextStyle(
                fontSize: isMobile ? 22 : 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsGrid(bool isMobile) {
    return GridView.builder(
      padding: isMobile ? const EdgeInsets.all(16) : EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: isMobile ? 1.0 : 1.2,
      ),
      itemCount: _controller.projects.length,
      itemBuilder: (context, index) {
        final project = _controller.projects[index];
        final students = _groupStudents[project.id] ?? [];
        // قائد الفريق يُحدَّد عبر group_led_id في جدول groups
        final leaderName = project.leaderName ?? 'غير محدد';
        final members =
            students.where((s) => s.id != project.leaderId).toList();

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    leaderName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D62ED),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'قائد الفريق',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'أعضاء الفريق (${students.length})',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4B5563),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.people_outline,
                      color: Color(0xFF4B5563), size: 18),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: members.length,
                  itemBuilder: (context, idx) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4, left: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            members[idx].name,
                            style: const TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF9CA3AF),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => ProjectDetailsView(
                          projectId: project.id!,
                          supervisorId: widget.supervisorId,
                          supervisorName: widget.supervisorName,
                          isGuest: widget.isGuest,
                        ),
                        transitionDuration: Duration.zero,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D62ED),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'عرض التفاصيل',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
