import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../repositories/project_repository.dart';
import '../../repositories/project_repository_impl.dart';
import 'project_details.dart';

class SupervisorProjectsList extends StatefulWidget {
  final int supervisorId;
  final String supervisorName;
  final bool isGuest;

  const SupervisorProjectsList({
    super.key,
    required this.supervisorId,
    required this.supervisorName,
    this.isGuest = false,
  });

  @override
  State<SupervisorProjectsList> createState() => _SupervisorProjectsListState();
}

class _SupervisorProjectsListState extends State<SupervisorProjectsList> {
  List<ResearchGroup> _projects = [];
  bool _isLoading = true;

  late final ProjectRepository _projectRepository;

  @override
  void initState() {
    super.initState();

    _projectRepository = ProjectRepositoryImpl();

    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    try {
      if (widget.isGuest) {
        _projects = [
          ResearchGroup(
            id: 101,
            name: 'مجموعة المشروع التجريبي أ',
            progress: 45,
            currentStage: 'التخطيط',
            description: 'عرض بيانات المشروع التجريبي.',
          ),
          ResearchGroup(
            id: 102,
            name: 'مجموعة المشروع التجريبي ب',
            progress: 70,
            currentStage: 'كتابة البحث',
            description: 'عرض المشروع الثاني في حالة الضيف.',
          ),
          ResearchGroup(
            id: 103,
            name: 'مجموعة المشروع التجريبي ج',
            progress: 90,
            currentStage: 'التحضير للمناقشة',
            description: 'مجموعة اختبارية لعرض تفاصيل المشروع.',
          ),
        ];
      } else {
        _projects =
            await _projectRepository.getGroupsBySupervisor(widget.supervisorId);
      }
    } catch (e) {
      debugPrint('خطأ في تحميل المشاريع: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المشاريع المشرف عليها'),
        backgroundColor: const Color(0xFF2D62ED),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
              ? const Center(child: Text('لا توجد مشاريع حالياً'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final project = _projects[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(project.name),
                        subtitle: Text(
                            'نسبة الإنجاز: ${project.progress?.toInt() ?? 0}%'),
                        trailing: Chip(
                          label: Text(project.currentStage ?? 'غير محدد'),
                          backgroundColor:
                              const Color(0xFF2D62ED).withValues(alpha: 0.1),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectDetails(
                                projectId: project.id!,
                                supervisorId: widget.supervisorId,
                                isGuest: widget.isGuest,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
