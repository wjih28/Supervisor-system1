import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/project_repository.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../data/datasources/remote/remote_project_datasource.dart';

class GradesEntry extends StatefulWidget {
  final int supervisorId;

  const GradesEntry({super.key, required this.supervisorId});

  @override
  State<GradesEntry> createState() => _GradesEntryState();
}

class _GradesEntryState extends State<GradesEntry> {
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
      _groups = await _projectRepository.getGroupsBySupervisor(widget.supervisorId);
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('إدخال الدرجات النهائية'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save, size: 18),
              label: const Text('حفظ الدرجات'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'إدخال ومتابعة درجات الطلاب في أبحاث التخرج',
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('إجمالي الطلاب', '8', AppColors.primaryBlue)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('تم إدخال الدرجات', '4', AppColors.successGreen)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('في انتظار الإدخال', '4', AppColors.warningOrange)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('المعدل العام', '90.0', Color(0xFF7C3AED))),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildGradesTable(),
                  const SizedBox(height: 40),
                  _buildGradesKey(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGradesTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          _buildTableRow(1, 'أحمد محمد علي', 'تأثير التسويق الرقمي على سلوك المستهلك', 'قائد الفريق', '95', 'ممتاز'),
          _buildTableRow(2, 'فاطمة سعيد حسن', 'تأثير التسويق الرقمي على سلوك المستهلك', 'عضو', '88', 'جيد جداً'),
          _buildTableRow(3, 'سارة علي محسن', 'دور الذكاء الاصطناعي في تطوير الأعمال', 'عضو', '', ''),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: const Row(
        children: [
          SizedBox(width: 40, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('اسم الطالب', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text('عنوان البحث', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text('الدور', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text('الدرجة (من 100)', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 1, child: Text('التقدير', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildTableRow(int id, String name, String research, String role, String grade, String rating) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(id.toString())),
          Expanded(flex: 2, child: Text(name)),
          Expanded(flex: 3, child: Text(research, style: const TextStyle(fontSize: 13))),
          Expanded(flex: 1, child: _buildRoleTag(role)),
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: grade.isEmpty ? 'أدخل الدرجة' : grade,
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              rating,
              style: TextStyle(
                color: rating == 'ممتاز' ? AppColors.successGreen : AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTag(String role) {
    final isLeader = role == 'قائد الفريق';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLeader ? AppColors.primaryBlue : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: isLeader ? Colors.white : AppColors.textGrey,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildGradesKey() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('مفتاح التقديرات', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildKeyItem('ممتاز: 90-100', AppColors.successGreen),
            const SizedBox(width: 20),
            _buildKeyItem('جيد جداً: 80-89', AppColors.primaryBlue),
            const SizedBox(width: 20),
            _buildKeyItem('جيد: 70-79', AppColors.warningOrange),
            const SizedBox(width: 20),
            _buildKeyItem('مقبول: 60-69', Colors.deepOrange),
            const SizedBox(width: 20),
            _buildKeyItem('ضعيف: أقل من 60', AppColors.errorRed),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyItem(String text, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
      ],
    );
  }
}
