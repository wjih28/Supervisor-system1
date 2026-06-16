import 'package:flutter/material.dart';
import '../../controllers/supervisor/project_details_controller.dart';
import '../../models/models.dart';
import '../widgets/desktop_layout.dart';
import 'projects_list_view.dart';
import 'stage_details_view.dart';
import 'package:intl/intl.dart';

class ProjectDetailsView extends StatefulWidget {
  final int projectId;
  final int supervisorId;
  final String supervisorName;
  final bool isGuest;

  const ProjectDetailsView({
    super.key,
    required this.projectId,
    required this.supervisorId,
    required this.supervisorName,
    this.isGuest = false,
  });

  @override
  State<ProjectDetailsView> createState() => _ProjectDetailsViewState();
}

class _ProjectDetailsViewState extends State<ProjectDetailsView> {
  final ProjectDetailsController _controller = ProjectDetailsController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller.loadData(projectId: widget.projectId, isGuest: widget.isGuest);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    Widget content = _controller.isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackButton(context),
                const SizedBox(height: 32),
                _buildStatsRow(isMobile),
                const SizedBox(height: 32),
                _buildOverviewSection(),
                const SizedBox(height: 32),
                _buildTeamMembersSection(),
                const SizedBox(height: 32),
                _buildTimelineSection(),
              ],
            ),
          );

    return DesktopLayout(
      selectedIndex: 1, // Keep Sidebar selected on "إدارة المجموعات"
      supervisorId: widget.supervisorId,
      supervisorName: widget.supervisorName,
      isGuest: widget.isGuest,
      child: content,
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ProjectsListView(
              supervisorId: widget.supervisorId,
              supervisorName: widget.supervisorName,
              isGuest: widget.isGuest,
            ),
            transitionDuration: Duration.zero,
          ),
        );
      },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_back, color: Color(0xFF4B5563), size: 20),
          SizedBox(width: 8),
          Text(
            'العودة للقائمة',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildProgressCard(),
          const SizedBox(height: 16),
          _buildStatusCard(),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: _buildProgressCard()),
        const SizedBox(width: 24),
        Expanded(child: _buildStatusCard()),
      ],
    );
  }

  Widget _buildProgressCard() {
    final progress = _controller.project?.progress ?? 0;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'نسبة الإنجاز',
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF2D62ED)),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${progress.toInt()}%',
                style: const TextStyle(
                  color: Color(0xFF2D62ED),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = _controller.project?.status ?? 'غير محدد';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'حالة المشروع',
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF10B981).withAlpha(50)),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Color(0xFF10B981),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    final project = _controller.project;
    // حالة المرحلة الحالية للمجموعة (groups.current_stage)
    ProjectStage? currentStage;
    for (final s in _controller.stages) {
      if (s.id == project?.currentStageId) {
        currentStage = s;
        break;
      }
    }
    final stageDone =
        currentStage?.status == 'completed' || currentStage?.isCompleted == true;
    final stageStatusText = stageDone ? 'تمت' : 'لم تتم';
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description_outlined,
                  color: Color(0xFF2D62ED), size: 20),
              SizedBox(width: 8),
              Text(
                'وصف المشروع',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'عنوان البحث',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            project?.name ?? '',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'وصف البحث',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            project?.description ?? '',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF4B5563),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          if (MediaQuery.of(context).size.width < 600)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('المرحلة الحالية',
                        style: TextStyle(color: Color(0xFF6B7280))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            project?.currentStage ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('حالة المرحلة',
                        style: TextStyle(color: Color(0xFF6B7280))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          stageDone
                              ? Icons.check_circle_outline
                              : Icons.pending_outlined,
                          color: stageDone ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            stageStatusText,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('المرحلة الحالية',
                          style: TextStyle(color: Color(0xFF6B7280))),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              project?.currentStage ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937)),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('حالة المرحلة',
                          style: TextStyle(color: Color(0xFF6B7280))),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            stageDone
                                ? Icons.check_circle_outline
                                : Icons.pending_outlined,
                            color: stageDone ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              stageStatusText,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTeamMembersSection() {
    // قائد الفريق يُحدَّد عبر group_led_id في جدول groups
    final leaderId = _controller.project?.leaderId;
    final leader = _controller.students.firstWhere(
      (s) => s.id == leaderId,
      orElse: () =>
          Student(id: leaderId, name: _controller.project?.leaderName ?? ''),
    );
    final members =
        _controller.students.where((s) => s.id != leaderId).toList();

    // Sort students: Leader first
    final sortedStudents =
        leader.name.isNotEmpty ? [leader, ...members] : members;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.people_outline, color: Color(0xFF4B5563)),
              SizedBox(width: 12),
              Text(
                'أعضاء الفريق',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width < 600 ? 1 : 2,
              childAspectRatio: MediaQuery.of(context).size.width < 600 ? 8 : 6,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: sortedStudents.length,
            itemBuilder: (context, index) {
              final student = sortedStudents[index];
              final isLeader = student.id == leaderId;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        student.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B5563),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isLeader)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D62ED),
                          borderRadius: BorderRadius.circular(16),
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    final stages = _controller.stages;
    final totalStages = stages.length;
    // عدد المراحل المفعّلة على مستوى البرنامج
    int currentStageIndex = stages.where((s) => s.isActive == true).length;
    if (currentStageIndex == 0 && stages.isNotEmpty) currentStageIndex = 1;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مراحل البحث - الجدول الزمني',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stages.length,
            itemBuilder: (context, index) {
              final stage = stages.reversed.toList()[index];
              // التفعيل (stage_isactive) يتحكم بالفتح والتنسيق
              final isActive = stage.isActive == true;
              // الاكتمال (من جدول stages statues) يتحكم بأيقونة الصح
              final isCompleted = stage.status == 'completed';
              final dateStr = stage.startDate != null
                  ? DateFormat('yyyy/MM/dd').format(stage.startDate!)
                  : 'غير محدد';
              final dateRange =
                  'من $dateStr إلى ${stage.endDate != null ? DateFormat('yyyy/MM/dd').format(stage.endDate!) : 'غير محدد'}';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFF0FDF4) : Colors.white,
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF86EFAC)
                        : const Color(0xFFE2E8F0),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: MediaQuery.of(context).size.width < 600
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isCompleted)
                                const Icon(Icons.check_circle,
                                    color: Colors.green)
                              else if (isActive)
                                const Icon(Icons.radio_button_checked,
                                    color: Color(0xFF2D62ED))
                              else
                                const Icon(Icons.lock_outline,
                                    color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stage.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isActive
                                            ? const Color(0xFF1F2937)
                                            : const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dateRange,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: isActive
                                ? OutlinedButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (_, __, ___) =>
                                              StageDetailsView(
                                            stage: stage,
                                            projectId: widget.projectId,
                                            supervisorId: widget.supervisorId,
                                            supervisorName:
                                                widget.supervisorName,
                                            stageIndex: index +
                                                1, // Pass stage index (1-based)
                                            isGuest: widget.isGuest,
                                          ),
                                          transitionDuration: Duration.zero,
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Color(0xFF2D62ED)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    child: const Text('عرض التفاصيل',
                                        style: TextStyle(
                                            color: Color(0xFF2D62ED))),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text('مغلقة',
                                        style: TextStyle(
                                            color: Color(0xFF6B7280),
                                            fontSize: 13)),
                                  ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                if (isCompleted)
                                  const Icon(Icons.check_circle,
                                      color: Colors.green)
                                else if (isActive)
                                  const Icon(Icons.radio_button_checked,
                                      color: Color(0xFF2D62ED))
                                else
                                  const Icon(Icons.lock_outline,
                                      color: Colors.grey),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stage.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isActive
                                              ? const Color(0xFF1F2937)
                                              : const Color(0xFF9CA3AF),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dateRange,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (isActive)
                            OutlinedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) =>
                                        StageDetailsView(
                                      stage: stage,
                                      projectId: widget.projectId,
                                      supervisorId: widget.supervisorId,
                                      supervisorName: widget.supervisorName,
                                      stageIndex: index +
                                          1, // Pass stage index (1-based)
                                      isGuest: widget.isGuest,
                                    ),
                                    transitionDuration: Duration.zero,
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side:
                                    const BorderSide(color: Color(0xFF2D62ED)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('عرض التفاصيل',
                                  style: TextStyle(color: Color(0xFF2D62ED))),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text('مغلقة',
                                  style: TextStyle(
                                      color: Color(0xFF6B7280), fontSize: 12)),
                            ),
                        ],
                      ),
              );
            },
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: MediaQuery.of(context).size.width < 600
                ? Column(
                    children: [
                      _buildStatItem(
                          'نسبة الإنجاز الكلية',
                          '${_controller.project?.progress?.toInt() ?? 0}%',
                          Colors.green),
                      const Divider(height: 24),
                      _buildStatItem(
                          'المرحلة الحالية',
                          '$currentStageIndex من $totalStages',
                          const Color(0xFF2D62ED)),
                      const Divider(height: 24),
                      _buildStatItem('إجمالي المراحل', '$totalStages',
                          const Color(0xFF1F2937)),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('نسبة الإنجاز الكلية',
                              style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                              '${_controller.project?.progress?.toInt() ?? 0}%',
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('المرحلة الحالية',
                              style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('$currentStageIndex من $totalStages',
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D62ED))),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('إجمالي المراحل',
                              style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('$totalStages',
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937))),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
