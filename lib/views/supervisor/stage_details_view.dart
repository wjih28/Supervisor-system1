import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/supervisor/stage_details_controller.dart';
import '../../models/models.dart';
import '../widgets/desktop_layout.dart';
import 'project_details_view.dart';

class StageDetailsView extends StatefulWidget {
  final ProjectStage stage;
  final int projectId;
  final int supervisorId;
  final String supervisorName;
  final bool isGuest;
  final int
      stageIndex; // ترتيب المرحلة في القائمة (احتياطي إن خلا الاسم من رقم)

  const StageDetailsView({
    super.key,
    required this.stage,
    required this.projectId,
    required this.supervisorId,
    required this.supervisorName,
    required this.stageIndex,
    this.isGuest = false,
  });

  @override
  State<StageDetailsView> createState() => _StageDetailsViewState();
}

class _StageDetailsViewState extends State<StageDetailsView> {
  late final StageDetailsController _controller;
  late final int _stageNumber;
  bool _seeded = false;

  // حقول المرحلة 3 القابلة للتحرير
  final _s3PercentCtrl = TextEditingController();
  final _s3NoteCtrl = TextEditingController();
  DateTime? _s3Date;

  // حقول المرحلة 4 القابلة للتحرير
  final _s4NotesCtrl = TextEditingController();

  // ملاحظات المرحلة 5 (ملاحظة لكل قسم — title_id)
  final Map<int, TextEditingController> _s5Notes = {};

  // حقول المرحلة 6
  DateTime? _s6Date;
  final Map<int, TextEditingController> _s6GradesCtrls = {};

  // حالة عرض محلية (لم يعد هناك اعتماد فردي)

  @override
  void initState() {
    super.initState();
    _stageNumber = _parseStageNumber(widget.stage.name);
    _controller = StageDetailsController(
      groupId: widget.projectId,
      stageNumber: _stageNumber,
      stageId: widget.stage.id,
      supervisorId: widget.supervisorId,
    );
    _controller.addListener(_onControllerChange);
    _controller.load();
    _controller.startRealtime();
  }

  void _onControllerChange() {
    if (!mounted) return;
    if (!_controller.isLoading && !_seeded) {
      _seedFields();
      _seeded = true;
    }
    setState(() {});
  }

  void _seedFields() {
    final s3 = _controller.stage3;
    if (s3 != null) {
      _s3Date = s3.discussionDate;
      if (s3.discussionPercent != null) {
        _s3PercentCtrl.text = _fmtPercent(s3.discussionPercent!);
      }
      _s3NoteCtrl.text = s3.supervisorNote ?? '';
    }
    final s4 = _controller.stage4;
    if (s4 != null) _s4NotesCtrl.text = s4.supervisorNotes ?? '';
    for (final sec in _controller.stage5Sections) {
      _s5Notes.putIfAbsent(sec.titleId,
          () => TextEditingController(text: sec.supervisorNote ?? ''));
    }
    final s6 = _controller.stage6;
    if (s6 != null) {
      _s6Date = s6.discussDate;
    }
    // تهيئة حقول درجات المرحلة 6 للطلاب
    for (var s in _controller.students) {
      if (s.id != null) {
        final grade = _controller.studentGrades[s.id!];
        _s6GradesCtrls.putIfAbsent(
          s.id!,
          () => TextEditingController(
              text: grade != null ? grade.toInt().toString() : ''),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    _controller.dispose();
    _s3PercentCtrl.dispose();
    _s3NoteCtrl.dispose();
    _s4NotesCtrl.dispose();
    for (final c in _s5Notes.values) {
      c.dispose();
    }
    for (final c in _s6GradesCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  int _parseStageNumber(String name) {
    final match = RegExp(r'\d+').firstMatch(name);
    if (match != null) {
      final n = int.tryParse(match.group(0)!);
      if (n != null) return n;
    }
    return widget.stageIndex;
  }

  String _fmtPercent(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toString();

  /// تنفيذ إجراء حفظ وإظهار رسالة نتيجة موحّدة.
  Future<void> _handle(
      Future<bool> Function() action, String successMsg) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await action();
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? successMsg : 'حدث خطأ أثناء الحفظ'),
        backgroundColor: ok ? const Color(0xFF10B981) : Colors.red,
      ),
    );
  }

  Future<void> _openFile(String? url) async {
    final messenger = ScaffoldMessenger.of(context);
    if (url == null || url.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('لا يوجد رابط ملف للفتح')),
      );
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      messenger.showSnackBar(
        const SnackBar(content: Text('رابط الملف غير صالح')),
      );
      return;
    }
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        messenger.showSnackBar(
            const SnackBar(content: Text('لا يمكن فتح الرابط حالياً')));
      }
    } catch (_) {
      messenger.showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء فتح الملف')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    Widget content = _controller.isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackButton(context),
                const SizedBox(height: 24),
                Text(
                  widget.stage.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 32),
                _buildStageContent(),
              ],
            ),
          );

    return DesktopLayout(
      selectedIndex: 1, // إبقاء "إدارة المجموعات" محدّداً في الشريط الجانبي
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
            pageBuilder: (_, __, ___) => ProjectDetailsView(
              projectId: widget.projectId,
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
            'العودة إلى التفاصيل',
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// اختيار محتوى المرحلة حسب رقمها الفعلي (لا حسب موضعها في القائمة).
  Widget _buildStageContent() {
    switch (_stageNumber) {
      case 1:
        return _buildStage1Content();
      case 2:
        return _buildStage2Content();
      case 3:
        return _buildStage3Content();
      case 4:
        return _buildStage4Content();
      case 5:
        return _buildStage5Content();
      case 6:
        return _buildStage6Content();
      default:
        return _buildUnknownStageContent();
    }
  }

  Widget _buildUnknownStageContent() {
    return _buildCard(
      title: 'محتوى المرحلة',
      icon: Icons.info_outline,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'لا يوجد محتوى مخصص لهذه المرحلة بعد.',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
          ),
        ),
      ),
    );
  }

  // ===================== المرحلة 1 =====================
  Widget _buildStage1Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTeamMembersCard(),
        const SizedBox(height: 24),
        _buildResearchDetailsCard(),
        const SizedBox(height: 24),
        _buildApprovalCard(),
      ],
    );
  }

  Widget _buildTeamMembersCard() {
    final students = _controller.students;
    final leaderId = _controller.leaderId;

    return _buildCard(
      title: 'أعضاء الفريق',
      icon: Icons.people_outline,
      child: students.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('لا يوجد أعضاء مسجّلون لهذه المجموعة',
                  style: TextStyle(color: Color(0xFF6B7280))),
            )
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width < 600 ? 1 : 2,
                childAspectRatio:
                    MediaQuery.of(context).size.width < 600 ? 8 : 6,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final s = students[index];
                final isLeader = s.id != null && s.id == leaderId;
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
                          s.name,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4B5563)),
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
                              borderRadius: BorderRadius.circular(16)),
                          child: const Text('قائد الفريق',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildResearchDetailsCard() {
    final s1 = _controller.stage1;
    final title = (s1?.researchTitle?.trim().isNotEmpty == true)
        ? s1!.researchTitle!.trim()
        : (_controller.group?.name ?? '');
    final desc = (s1?.researchDescription?.trim().isNotEmpty == true)
        ? s1!.researchDescription!.trim()
        : (_controller.group?.description ?? 'لا يوجد وصف');

    return _buildCard(
      title: 'تفاصيل البحث',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('عنوان البحث',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: title,
            readOnly: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          const Text('وصف البحث',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: desc,
            readOnly: true,
            maxLines: 4,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalCard() {
    final approved = _controller.stage1?.supervisorApproval;
    return _buildCard(
      title: 'اعتماد البحث',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (approved != null) ...[
            _buildStatusChip(
              approved ? 'تم اعتماد البحث' : 'تم رفض البحث',
              approved,
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _controller.isSaving
                      ? null
                      : () => _handle(
                          () => _controller.setStage1Approval(false),
                          'تم رفض البحث'),
                  icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                  label: const Text('رفض البحث',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _controller.isSaving
                      ? null
                      : () => _handle(() => _controller.setStage1Approval(true),
                          'تم اعتماد البحث'),
                  icon: const Icon(Icons.check_circle_outline,
                      color: Colors.white),
                  label: const Text('اعتماد البحث',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== المرحلة 2 =====================
  Widget _buildStage2Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (MediaQuery.of(context).size.width < 800)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStageSummaryCard(),
              const SizedBox(height: 24),
              _buildStageFileCard(),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: _buildStageSummaryCard()),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: _buildStageFileCard()),
            ],
          ),
        const SizedBox(height: 24),
        _buildStageRequirementsCard(),
        const SizedBox(height: 24),
        _buildStage2ApprovalCard(),
      ],
    );
  }

  Widget _buildStage2ApprovalCard() {
    final approval = _controller.stage2?.stageApproval;
    return _buildCard(
      title: 'اعتماد المرحلة',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (approval != null) ...[
            _buildStatusChip(
              approval ? 'تم اعتماد الخطة' : 'تم رفض الخطة',
              approval,
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _controller.isSaving
                      ? null
                      : () => _handle(
                          () => _controller.setStage2Approval(false),
                          'تم رفض الخطة'),
                  icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                  label: const Text('رفض الخطة',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _controller.isSaving
                      ? null
                      : () => _handle(() => _controller.setStage2Approval(true),
                          'تم اعتماد الخطة'),
                  icon: const Icon(Icons.check_circle_outline,
                      color: Colors.white),
                  label: const Text('اعتماد الخطة',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getNotesCount() {
    final noteStr = _controller.stage2?.supervisorNote?.trim() ?? '';
    if (noteStr.isEmpty) return 0;
    return noteStr.split('\n').where((s) => s.trim().isNotEmpty).length;
  }

  Widget _buildStageSummaryCard() {
    final notesCount = _getNotesCount();
    return _buildCard(
      title: 'ملخص التعديلات',
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text('$notesCount',
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF59E0B))),
          const Text('ملاحظات مرسلة للتعديل',
              style: TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStageFileCard() {
    final pdf = _controller.stage2?.pdfFile;
    final hasFile = pdf != null && pdf.isNotEmpty;
    return _buildCard(
      title: 'ملف المرحلة الثانية',
      icon: Icons.description_outlined,
      titleIconColor: Colors.red,
      child: hasFile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text('ملف الخطة المرفوع',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _openFile(pdf),
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('عرض الملف'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2D62ED),
                      side: const BorderSide(color: Color(0xFF2D62ED)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            )
          : Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('لم يتم رفع ملف بعد',
                    style: TextStyle(color: Color(0xFF9CA3AF))),
              ),
            ),
    );
  }

  Widget _buildStageRequirementsCard() {
    final titles = _controller.stage2Titles;
    return _buildCard(
      title: 'متطلبات المرحلة الثانية',
      child: titles.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('لا توجد عناصر',
                  style: TextStyle(color: Color(0xFF6B7280))),
            )
          : Column(
              children: titles.reversed.toList().asMap().entries.map((entry) {
                final title = entry.value;
                final isApproved = _controller.stage2?.stageApproval == true;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isApproved
                        ? const Color(0xFFF0FDF4)
                        : const Color(0xFFFFFBEB),
                    border: Border.all(
                        color: isApproved
                            ? const Color(0xFF86EFAC)
                            : const Color(0xFFFDE68A)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: isApproved
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(title,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => _showNeedsEditDialog(context, title),
                        icon: const Icon(Icons.info_outline,
                            size: 16, color: Color(0xFFF59E0B)),
                        label: const Text('يحتاج تعديل',
                            style: TextStyle(color: Color(0xFFF59E0B))),
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFF59E0B))),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  // ===================== المرحلة 3 =====================
  Widget _buildStage3Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDiscussionStatusCard(),
        const SizedBox(height: 24),
        _buildDiscussionDetailsCard(),
      ],
    );
  }

  Widget _buildDiscussionStatusCard() {
    final pct =
        ((_controller.stage3?.discussionPercent ?? 0) / 100).clamp(0.0, 1.0);
    return _buildCard(
      title: 'حالة مناقشة الخطة',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Wrap(
          spacing: 24,
          runSpacing: 24,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: pct,
                    strokeWidth: 12,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF2D62ED)),
                  ),
                  Center(
                    child: Text(
                      '${(pct * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('نسبة إنجاز المناقشة',
                    style: TextStyle(color: Color(0xFF6B7280))),
                const SizedBox(height: 16),
                Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF2D62ED)),
                      minHeight: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscussionDetailsCard() {
    return _buildCard(
      title: 'تفاصيل المناقشة',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('نسبة الإنجاز (%)',
                        style:
                            TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _s3PercentCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFFE5E7EB))),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('تاريخ المناقشة',
                        style:
                            TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
                    const SizedBox(height: 8),
                    TextFormField(
                      readOnly: true,
                      onTap: _pickS3Date,
                      controller: TextEditingController(
                          text: _s3Date != null
                              ? DateFormat('yyyy/MM/dd').format(_s3Date!)
                              : ''),
                      decoration: InputDecoration(
                        hintText: 'اختر التاريخ',
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: const Icon(Icons.calendar_today,
                            color: Color(0xFF9CA3AF), size: 18),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFFE5E7EB))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _controller.isSaving || _s3Date == null
                            ? null
                            : () async {
                                await _handle(
                                  () => _controller.saveStage3(
                                    date: _s3Date,
                                  ),
                                  'تم حفظ تاريخ المناقشة بنجاح',
                                );
                              },
                        icon: const Icon(Icons.save_outlined, size: 18),
                        label: const Text('حفظ التاريخ'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF3B82F6),
                          side: const BorderSide(color: Color(0xFF3B82F6)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('ملاحظة (اختياري)',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _s3NoteCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'أدخل أي ملاحظات حول المناقشة',
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      _controller.isSaving ? null : () => _saveStage3(false),
                  icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                  label: const Text('لم تتم المناقشة',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      _controller.isSaving ? null : () => _saveStage3(true),
                  icon: const Icon(Icons.check_circle_outline,
                      color: Colors.white),
                  label: const Text('تمت المناقشة',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickS3Date() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _s3Date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _s3Date = picked);
  }

  void _saveStage3(bool discussed) {
    final percent = double.tryParse(_s3PercentCtrl.text.trim()) ?? 0;
    _handle(
      () => _controller.saveStage3(
        discussed: discussed,
        percent: percent,
        date: _s3Date,
        note: _s3NoteCtrl.text.trim(),
      ),
      'تم حفظ نتيجة المناقشة',
    );
  }

  // ===================== المرحلة 4 =====================
  Widget _buildStage4Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStudentDocumentCard(),
        const SizedBox(height: 24),
        _buildStageEvaluationCard(),
      ],
    );
  }

  Widget _buildStudentDocumentCard() {
    final pdf = _controller.stage4?.pdfFile;
    final hasFile = pdf != null && pdf.isNotEmpty;
    return _buildCard(
      title: 'مراجعة المستند المرفق من الطالب',
      icon: Icons.find_in_page_outlined,
      titleIconColor: const Color(0xFF2D62ED),
      child: hasFile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text('مستند النزول الميداني المرفوع',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _openFile(pdf),
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('عرض المستند'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2D62ED),
                      side: const BorderSide(color: Color(0xFF2D62ED)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            )
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('لم يرفع الطالب مستنداً بعد',
                    style: TextStyle(color: Color(0xFF9CA3AF))),
              ),
            ),
    );
  }

  Widget _buildStageEvaluationCard() {
    final approval = _controller.stage4?.approval;
    return _buildCard(
      title: 'تقييم المرحلة',
      icon: Icons.fact_check_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (approval != null) ...[
            _buildStatusChip(
                approval ? 'تم اعتماد المرحلة' : 'تم رفض المستند', approval),
            const SizedBox(height: 16),
          ],
          const Text('ملاحظات المشرف (اختياري)',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _s4NotesCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'أدخل ملاحظاتك حول أداء الطالب في النزول الميداني',
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      _controller.isSaving ? null : () => _saveStage4(false),
                  icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                  label: const Text('رفض المستند',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      _controller.isSaving ? null : () => _saveStage4(true),
                  icon: const Icon(Icons.check_circle_outline,
                      color: Colors.white),
                  label: const Text('اعتماد المرحلة',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveStage4(bool approved) {
    _handle(
      () => _controller.saveStage4(
          approved: approved, notes: _s4NotesCtrl.text.trim()),
      approved ? 'تم اعتماد المرحلة' : 'تم رفض المستند',
    );
  }

  // ===================== المرحلة 5 =====================
  Widget _buildStage5Content() {
    final sections = _controller.stage5Sections;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (sections.isEmpty)
          _buildCard(
            title: 'أقسام مشروع البحث',
            icon: Icons.menu_book_outlined,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('لا توجد أقسام لعرضها بعد.',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 16)),
              ),
            ),
          )
        else
          ...sections.reversed.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _buildStage5SectionCard(s),
              )),
        _buildStage5ProgressCard(),
      ],
    );
  }

  Widget _buildStage5SectionCard(Stage5Section s) {
    final hasFile = s.pdfFile != null && s.pdfFile!.isNotEmpty;
    final noteCtrl =
        _s5Notes.putIfAbsent(s.titleId, () => TextEditingController());
    return _buildCard(
      title: s.titleName,
      icon: Icons.description_outlined,
      titleIconColor: const Color(0xFF2D62ED),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasFile) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('ملف ${s.titleName} المرفوع',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openFile(s.pdfFile),
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('عرض الملف'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2D62ED),
                  side: const BorderSide(color: Color(0xFF2D62ED)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ] else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('لم يُرفع الملف بعد',
                    style: TextStyle(color: Color(0xFF9CA3AF))),
              ),
            ),
          const SizedBox(height: 16),
          _buildStatusChip(
              s.approval == true ? 'تم الاعتماد' : 'في انتظار الاعتماد',
              s.approval == true),
          const SizedBox(height: 16),
          const Text('ملاحظة المشرف (اختياري)',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            controller: noteCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'أدخل ملاحظتك على هذا الفصل',
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (!hasFile || _controller.isSaving)
                      ? null
                      : () => _saveStage5Section(s, false),
                  icon: const Icon(Icons.edit_note, color: Colors.white),
                  label: const Text('طلب تعديل',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (!hasFile || _controller.isSaving)
                      ? null
                      : () => _saveStage5Section(s, true),
                  icon: const Icon(Icons.check_circle_outline,
                      color: Colors.white),
                  label: const Text('اعتماد الفصل',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveStage5Section(Stage5Section s, bool approved) {
    final note = (_s5Notes[s.titleId]?.text ?? '').trim();
    _handle(
      () => _controller.saveStage5Section(s.titleId,
          approved: approved, note: note),
      approved ? 'تم اعتماد الفصل' : 'تم إرسال طلب التعديل',
    );
  }

  /// نسبة إنجاز المرحلة الخامسة محسوبة تلقائياً = الفصول المعتمدة ÷ إجمالي الفصول (عرض فقط).
  Widget _buildStage5ProgressCard() {
    final sections = _controller.stage5Sections;
    final total = sections.length;
    final approved = sections.where((s) => s.approval == true).length;
    final underReview = sections
        .where((s) =>
            s.approval == null && s.pdfFile != null && s.pdfFile!.isNotEmpty)
        .length;
    final rejected = sections.where((s) => s.approval == false).length;
    final pct = total == 0 ? 0.0 : approved / total;
    final pctInt = (pct * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الصف العلوي: النسبة الكبيرة يسار + العنوان والوصف يمين
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // النسبة المئوية الكبيرة
                Text(
                  '$pctInt%',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D62ED),
                  ),
                ),
                // العنوان والوصف الفرعي
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'نسبة الإنجاز',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A5F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$approved من $total فصول معتمدة',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // شريط التقدم الأفقي
            Row(
              children: [
                Text(
                  '$pctInt%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D62ED),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: const Color(0xFFD1D5DB),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF2D62ED)),
                      minHeight: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: Color(0xFFBFDBFE)),
            const SizedBox(height: 16),
            // الإحصاءات الثلاث في الأسفل
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // معتمد
                Column(
                  children: [
                    Text(
                      '$approved',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'معتمد',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                // قيد المراجعة
                Column(
                  children: [
                    Text(
                      '$underReview',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'قيد المراجعة',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                // مرفوض
                Column(
                  children: [
                    Text(
                      '$rejected',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'مرفوض',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===================== المرحلة 6 =====================
  Widget _buildStage6Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStage6DiscussionCard(),
        const SizedBox(height: 24),
        _buildStage6StudentsGradesCard(),
        const SizedBox(height: 24),
        _buildStage6ApprovalCard(),
      ],
    );
  }

  Widget _buildStage6DiscussionCard() {
    return _buildCard(
      title: 'تفاصيل المناقشة',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صف: منتقي التاريخ + حالة المناقشة
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('تاريخ المناقشة',
                        style:
                            TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _s6Date ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _s6Date = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _s6Date == null
                                  ? 'اختر التاريخ'
                                  : DateFormat('yyyy/MM/dd').format(_s6Date!),
                              style: TextStyle(
                                color: _s6Date == null
                                    ? Colors.grey
                                    : const Color(0xFF1F2937),
                              ),
                            ),
                            const Icon(Icons.calendar_today_outlined,
                                color: Color(0xFF9CA3AF), size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // زر حفظ التاريخ فقط
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _controller.isSaving || _s6Date == null
                            ? null
                            : () async {
                                await _handle(
                                  () => _controller.saveStage6(
                                    date: _s6Date,
                                    studentGrades: const {},
                                  ),
                                  'تم حفظ تاريخ المناقشة بنجاح',
                                );
                              },
                        icon: const Icon(Icons.save_outlined, size: 18),
                        label: const Text('حفظ التاريخ'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF3B82F6),
                          side: const BorderSide(color: Color(0xFF3B82F6)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('حالة المناقشة',
                        style:
                            TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: _controller.stage6?.approval == true
                            ? const Color(0xFFF0FDF4)
                            : const Color(0xFFFFFBEB),
                        border: Border.all(
                            color: _controller.stage6?.approval == true
                                ? const Color(0xFF86EFAC)
                                : const Color(0xFFFDE68A)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _controller.stage6?.approval == true
                                ? 'تم اعتماد المناقشة'
                                : 'بانتظار الاعتماد',
                            style: TextStyle(
                              color: _controller.stage6?.approval == true
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            _controller.stage6?.approval == true
                                ? Icons.check_circle_outline
                                : Icons.hourglass_empty_outlined,
                            color: _controller.stage6?.approval == true
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    if (_controller.stage6?.discussDate != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event,
                                size: 16, color: Color(0xFF64748B)),
                            const SizedBox(width: 6),
                            Text(
                              'التاريخ المحفوظ: ${DateFormat('yyyy/MM/dd').format(_controller.stage6!.discussDate!)}',
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStage6StudentsGradesCard() {
    final students = _controller.students;
    return _buildCard(
      title: 'درجات الطلاب للمناقشة الثلاثية',
      icon: Icons.people_outline,
      child: students.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('لا يوجد أعضاء مسجّلون لهذه المجموعة',
                  style: TextStyle(color: Color(0xFF6B7280))),
            )
          : Column(
              children: students.map((s) {
                final ctrl = _s6GradesCtrls[s.id];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          s.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                       Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: ctrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: 'الدرجة / 40',
                            hintText: '0 – 40',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Color(0xFFE5E7EB))),
                            errorStyle:
                                const TextStyle(fontSize: 11),
                          ),
                          autovalidateMode:
                              AutovalidateMode.onUserInteraction,
                          validator: (v) {
                            if (v == null || v.isEmpty) return null;
                            final n = double.tryParse(v);
                            if (n == null) return 'رقم غير صحيح';
                            if (n < 0) return 'لا يمكن أن تكون سالبة';
                            if (n > 40) return 'الحد الأقصى 40 درجة';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildStage6ApprovalCard() {
    return _buildCard(
      title: 'حفظ واعتماد',
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _controller.isSaving
              ? null
              : () async {
                  // تحقق أن لا توجد درجة تتجاوز 40
                  final invalid = _s6GradesCtrls.entries.where((e) {
                    final v = double.tryParse(e.value.text);
                    return v != null && v > 40;
                  }).toList();

                  if (invalid.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'بعض الدرجات تتجاوز الحد الأقصى (40 درجة). يرجى تصحيحها أولاً.'),
                        backgroundColor: Color(0xFFDC2626),
                      ),
                    );
                    return;
                  }

                  final grades = <int, double?>{};
                  for (final entry in _s6GradesCtrls.entries) {
                    final val = double.tryParse(entry.value.text);
                    grades[entry.key] = val;
                  }
                  await _handle(
                    () => _controller.saveStage6(
                      approval: true,
                      date: _s6Date,
                      studentGrades: grades,
                    ),
                    'تم حفظ المرحلة السادسة بنجاح',
                  );
                },
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          label: const Text('اعتماد المناقشة الثلاثية وحفظ',
              style: TextStyle(color: Colors.white, fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }

  // ===================== مكوّنات مشتركة =====================
  void _showNeedsEditDialog(BuildContext context, String requirementTitle) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.edit_note, color: Color(0xFFF59E0B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'إرسال ملاحظة لتعديل ($requirementTitle)',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الملاحظة:',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B5563))),
                  const SizedBox(height: 8),
                  TextField(
                    controller: textController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'اكتب الملاحظة أو التعديلات المطلوبة هنا...',
                      hintStyle:
                          const TextStyle(fontSize: 14, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFF59E0B)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('إلغاء',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final note = textController.text.trim();
                  if (note.isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('الرجاء إدخال الملاحظة أولاً'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  Navigator.pop(dialogContext);
                  await _handle(
                    () =>
                        _controller.addStage2TitleNote(requirementTitle, note),
                    'تم إرسال الملاحظة بنجاح',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('إرسال الملاحظة',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String label, bool positive) {
    final color = positive ? const Color(0xFF10B981) : const Color(0xFFDC2626);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(positive ? Icons.check_circle : Icons.cancel,
              color: color, size: 18),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCard(
      {required String title,
      required Widget child,
      IconData? icon,
      Color? titleIconColor}) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon,
                    color: titleIconColor ?? const Color(0xFF4B5563),
                    size: isMobile ? 22 : 24),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: isMobile ? 17 : 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}
