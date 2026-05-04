import 'package:flutter/material.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/project_repository.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../data/datasources/mock/mock_project_datasource.dart';
import '../../data/datasources/remote/remote_project_datasource.dart';
import 'project_files.dart';
import 'add_feedback.dart';

class ProjectDetails extends StatefulWidget {
  final int projectId;
  final int supervisorId;

  const ProjectDetails({
    super.key,
    required this.projectId,
    required this.supervisorId,
  });

  @override
  State<ProjectDetails> createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends State<ProjectDetails> {
  ResearchGroup? _project;
  List<Student> _students = [];
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
    
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _project = await _projectRepository.getGroupDetails(widget.projectId);
      if (_project != null) {
        _students = await _projectRepository.getStudentsByGroup(widget.projectId);
      }
    } catch (e) {
      debugPrint('خطأ في تحميل تفاصيل المشروع: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المشروع'),
        backgroundColor: const Color(0xFF2D62ED),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildProgressCard(),
                  const SizedBox(height: 16),
                  _buildStudentsList(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_project?.name ?? 'بدون عنوان', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_project?.description ?? 'لا يوجد وصف', style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBadge('الحالة: ${_project?.status ?? "نشط"}', Colors.green),
                _buildBadge('المرحلة: ${_project?.currentStage ?? "غير محدد"}', Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('نسبة الإنجاز', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (_project?.progress ?? 0) / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2D62ED)),
              minHeight: 10,
            ),
            const SizedBox(height: 8),
            Text('${_project?.progress?.toInt() ?? 0}% مكتمل', style: const TextStyle(color: Color(0xFF2D62ED), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('أعضاء الفريق', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ..._students.map((student) => Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(student.name),
            subtitle: Text(student.email ?? ''),
          ),
        )),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.folder_open),
            label: const Text('الملفات'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_comment),
            label: const Text('إضافة ملاحظة'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
          ),
        ),
      ],
    );
  }
}
