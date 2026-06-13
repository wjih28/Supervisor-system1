import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/dashboard_controller.dart';
import '../models/models.dart';
import 'widgets/desktop_layout.dart';
import 'supervisor/project_details_view.dart';
import 'supervisor/projects_list_view.dart';

class DashboardView extends StatefulWidget {
  final Supervisor? supervisor;
  final int? supervisorId;
  final String? supervisorName;
  final bool isGuest;

  const DashboardView({
    super.key,
    this.supervisor,
    this.supervisorId,
    this.supervisorName,
    this.isGuest = false,
  });

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final DashboardController _controller = DashboardController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller.loadData(
        supervisor: widget.supervisor,
        supervisorId: widget.supervisorId,
        supervisorName: widget.supervisorName,
        isGuest: widget.isGuest);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    if (_controller.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FB),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DesktopLayout(
      selectedIndex: 0,
      supervisorId: widget.supervisor?.id ?? widget.supervisorId,
      supervisor: widget.supervisor,
      isGuest: widget.isGuest,
      supervisorName: _controller.supervisorName,
      child: isMobile ? _buildMobileLayout() : _buildDesktopContent(),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - same as desktop
          const Text(
            'لوحة التحكم',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isGuest
                ? 'مرحباً بك في عرض الضيف التجريبي'
                : 'مرحباً بك د. ${_controller.supervisorName}',
            style: const TextStyle(fontSize: 14, color: Color(0xFF718096)),
          ),
          const SizedBox(height: 24),

          // Stats - stacked vertically on mobile
          _buildStatCard(
            title: 'البرنامج',
            value: _controller.programName,
            color: const Color(0xFF06B6D4),
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            title: 'القسم',
            value: _controller.departmentName,
            color: const Color(0xFF6366F1),
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            title: 'عدد الأبحاث التي أشرف عليها',
            value: _controller.totalProjects.toString(),
            color: const Color(0xFF2D62ED),
            isCount: true,
            onTap: _openProjectsList,
          ),
          const SizedBox(height: 32),

          // Progress Section - same title, 1 column grid
          const Text(
            'نسبة إنجاز الأبحاث',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          _buildMobileProgressSection(),
          const SizedBox(height: 32),

          // Recent Files Section - same title, 1 column grid
          const Text(
            'الملفات الأخيرة التي تم إرفاقها',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          _buildMobileRecentFilesSection(),
        ],
      ),
    );
  }

  Widget _buildMobileProgressSection() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _controller.groups.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final group = _controller.groups[index];
        return _buildMobileProgressCard(group);
      },
    );
  }

  Widget _buildMobileProgressCard(ResearchGroup group) {
    final progress = group.progress ?? 0;
    final isDelayed = progress < 40;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _openProjectDetails(group),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDelayed ? const Color(0xFFFEF2F2) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isDelayed ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isDelayed)
                    const Icon(Icons.error, color: Colors.red, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E7FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'قائد الفريق',
                      style: TextStyle(
                        color: Color(0xFF4338CA),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      group.leaderName ?? 'غير محدد',
                      style: const TextStyle(
                          color: Color(0xFF4B5563), fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('نسبة الإنجاز',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                  Text('${progress.toInt()}%',
                      style: TextStyle(
                          color:
                              isDelayed ? Colors.red : const Color(0xFF2D62ED),
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDelayed ? Colors.red : const Color(0xFF2D62ED),
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileRecentFilesSection() {
    final count = _controller.groups.length > 4 ? 4 : _controller.groups.length;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final group = _controller.groups[index];
        return _buildMobileRecentFileCard(group);
      },
    );
  }

  Widget _buildMobileRecentFileCard(ResearchGroup group) {
    final files = _controller.filesForGroup(group.id ?? -1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          if (files.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('لا توجد ملفات مرفقة',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
            ),
          ...files.map((file) => InkWell(
                onTap: () => _openFile(file.fileUrl),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf,
                          color: Colors.red, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          file.fileName,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF4B5563)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.download,
                          color: Color(0xFF2D62ED), size: 16),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showAllFilesDialog(context, group),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2D62ED)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text(
                'عرض الكل',
                style: TextStyle(
                  color: Color(0xFF2D62ED),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // DESKTOP LAYOUT
  // ---------------------------------------------------------

  Widget _buildDesktopContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'لوحة التحكم',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'مرحباً بك د. ${_controller.supervisorName}',
                    style:
                        const TextStyle(fontSize: 16, color: Color(0xFF718096)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'البرنامج',
                  value: _controller.programName,
                  color: const Color(0xFF06B6D4), // Teal
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildStatCard(
                  title: 'القسم',
                  value: _controller.departmentName,
                  color: const Color(0xFF6366F1), // Indigo/Purple
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildStatCard(
                  title: 'عدد الأبحاث التي أشرف عليها',
                  value: _controller.totalProjects.toString(),
                  color: const Color(0xFF2D62ED), // Blue
                  isCount: true,
                  onTap: _openProjectsList,
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),

          // Progress Section
          const Text(
            'نسبة إنجاز الأبحاث',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 24),
          _buildProgressSection(),

          const SizedBox(height: 48),

          // Recent Files Section
          const Text(
            'الملفات الأخيرة التي تم إرفاقها',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 24),
          _buildRecentFilesSection(),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    bool isCount = false,
    VoidCallback? onTap,
  }) {
    final card = Container(
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: isCount ? 48 : 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      ),
    );
  }

  Widget _buildProgressSection() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 2.5,
      ),
      itemCount: _controller.groups.length,
      itemBuilder: (context, index) {
        final group = _controller.groups[index];
        return _buildProgressCard(group);
      },
    );
  }

  Widget _buildProgressCard(ResearchGroup group) {
    final progress = group.progress ?? 0;
    // Mocking logic to match UI colors: < 40 is delayed/red
    final isDelayed = progress < 40;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _openProjectDetails(group),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDelayed ? const Color(0xFFFEF2F2) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isDelayed ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isDelayed) const Icon(Icons.error, color: Colors.red),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E7FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'قائد الفريق',
                      style: TextStyle(
                        color: Color(0xFF4338CA),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      group.leaderName ?? 'غير محدد',
                      style: const TextStyle(
                          color: Color(0xFF4B5563), fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('نسبة الإنجاز',
                          style: TextStyle(
                              color: Color(0xFF6B7280), fontSize: 12)),
                      Text('${progress.toInt()}%',
                          style: TextStyle(
                              color: isDelayed
                                  ? Colors.red
                                  : const Color(0xFF2D62ED),
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDelayed ? Colors.red : const Color(0xFF2D62ED),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentFilesSection() {
    // We mock the files based on the groups to match UI layout
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 1.5,
      ),
      itemCount: _controller.groups.length > 4 ? 4 : _controller.groups.length,
      itemBuilder: (context, index) {
        final group = _controller.groups[index];
        return _buildRecentFileCard(group);
      },
    );
  }

  Widget _buildRecentFileCard(ResearchGroup group) {
    final files = _controller.filesForGroup(group.id ?? -1);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: files.isEmpty
                ? const Center(
                    child: Text('لا توجد ملفات مرفقة',
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))),
                  )
                : ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      final file = files[index];
                      return InkWell(
                        onTap: () => _openFile(file.fileUrl),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.picture_as_pdf,
                                  color: Colors.red, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  file.fileName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF4B5563),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.download,
                                  color: Color(0xFF2D62ED), size: 18),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showAllFilesDialog(context, group),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2D62ED)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'عرض الكل',
                style: TextStyle(
                  color: Color(0xFF2D62ED),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// فتح تفاصيل المشروع عند النقر على بطاقة مجموعة
  void _openProjectDetails(ResearchGroup group) {
    if (group.id == null) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ProjectDetailsView(
          projectId: group.id!,
          supervisorId: widget.supervisor?.id ?? widget.supervisorId ?? 0,
          supervisorName: _controller.supervisorName,
          isGuest: widget.isGuest,
        ),
        transitionDuration: Duration.zero,
      ),
    );
  }

  /// فتح قائمة المجموعات عند النقر على بطاقة عدد الأبحاث
  void _openProjectsList() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ProjectsListView(
          supervisorId: widget.supervisor?.id ?? widget.supervisorId ?? 0,
          supervisorName: _controller.supervisorName,
          isGuest: widget.isGuest,
        ),
        transitionDuration: Duration.zero,
      ),
    );
  }

  Future<void> _openFile(String? url) async {
    if (url == null || url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يوجد رابط للملف')),
        );
      }
      return;
    }
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح الملف')),
        );
      }
    }
  }

  void _showAllFilesDialog(BuildContext context, ResearchGroup group) {
    final files = _controller.filesForGroup(group.id ?? -1);
    final isMobile = MediaQuery.of(context).size.width < 600;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: isMobile ? double.infinity : 600,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'جميع ملفات: ${group.name}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                if (files.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('لا توجد ملفات مرفقة',
                          style: TextStyle(
                              fontSize: 14, color: Color(0xFF9CA3AF))),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        final file = files[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.picture_as_pdf,
                                  color: Colors.red, size: 36),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  file.fileName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937),
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              isMobile
                                  ? IconButton(
                                      onPressed: () => _openFile(file.fileUrl),
                                      icon: const Icon(Icons.download,
                                          color: Color(0xFF2D62ED)),
                                      style: IconButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFE0E7FF),
                                      ),
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: () => _openFile(file.fileUrl),
                                      icon:
                                          const Icon(Icons.download, size: 18),
                                      label: const Text('تنزيل'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF2D62ED),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 10),
                                      ),
                                    ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
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
