import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/supervisor/project_files_controller.dart';
import '../../models/models.dart';

class ProjectFilesView extends StatefulWidget {
  final int projectId;
  final int supervisorId;
  final String projectTitle;

  const ProjectFilesView({
    super.key,
    required this.projectId,
    required this.supervisorId,
    required this.projectTitle,
  });

  @override
  State<ProjectFilesView> createState() => _ProjectFilesViewState();
}

class _ProjectFilesViewState extends State<ProjectFilesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProjectFilesController _controller = ProjectFilesController();
  String? _noteText;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: _controller.stages.length, vsync: this);
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller.loadFiles(widget.projectId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showNoteDialog(int? fileId, String fileName) {
    _noteText = null;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة ملاحظة على $fileName'),
        content: TextField(
          onChanged: (value) => _noteText = value,
          decoration: const InputDecoration(
            hintText: 'أدخل ملاحظتك هنا...',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: fileId != null
                ? () async {
                    final success =
                        await _controller.addNote(fileId, _noteText ?? '');
                    if (!context.mounted) return;
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('تم إضافة الملاحظة بنجاح')),
                      );
                      _controller.loadFiles(widget.projectId);
                      Navigator.pop(context);
                    }
                  }
                : null,
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _openFile(String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد رابط ملف للفتح')),
      );
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رابط الملف غير صالح')),
      );
      return;
    }
    try {
      final canLaunch = await canLaunchUrl(uri);
      if (!mounted) return;
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن فتح الرابط حالياً')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء فتح الملف')),
      );
    }
  }

  Widget _getFileIcon(String? fileType) {
    if (fileType == 'pdf') {
      return const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40);
    } else if (fileType == 'doc' || fileType == 'docx') {
      return const Icon(Icons.description, color: Colors.blue, size: 40);
    } else if (fileType == 'zip') {
      return const Icon(Icons.folder_zip, color: Colors.orange, size: 40);
    }
    return const Icon(Icons.insert_drive_file, color: Colors.grey, size: 40);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ملفات المشروع: ${widget.projectTitle}'),
        backgroundColor: const Color(0xFF2D62ED),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _controller.stages.map((stage) {
            return Tab(
              child: Row(
                children: [
                  Text(stage['icon']!),
                  const SizedBox(width: 8),
                  Text(stage['name']!),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: _controller.stages.map((stage) {
                final files = _controller.getFilesForStage(stage['key']!);
                return _buildFilesList(files, stage['name']!);
              }).toList(),
            ),
    );
  }

  Widget _buildFilesList(List<ProjectFile> files, String stageName) {
    if (files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('لا توجد ملفات مرفوعة للمرحلة: $stageName',
                style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: _getFileIcon(file.fileType),
            title: Text(file.fileName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'رفع بواسطة: ${file.uploadedBy == 'student' ? 'الطالب' : 'المشرف'}'),
                Text(
                    'التاريخ: ${_controller.formatDate(file.uploadedAt)}'),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openFile(file.fileUrl),
                          icon: const Icon(Icons.download),
                          label: const Text('تحميل الملف'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    if (file.supervisorNotes != null &&
                        file.supervisorNotes!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('ملاحظة المشرف:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue)),
                            const SizedBox(height: 8),
                            Text(file.supervisorNotes!),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () =>
                            _showNoteDialog(file.id, file.fileName),
                        icon: const Icon(Icons.add_comment, size: 18),
                        label: const Text('إضافة ملاحظة'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
