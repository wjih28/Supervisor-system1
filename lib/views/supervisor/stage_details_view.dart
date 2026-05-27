import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../widgets/desktop_layout.dart';
import 'project_details_view.dart';

class StageDetailsView extends StatefulWidget {
  final ProjectStage stage;
  final int projectId;
  final int supervisorId;
  final String supervisorName;
  final bool isGuest;
  final int stageIndex; // 1 for Stage 1, 2 for Stage 2, etc.

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
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    Widget content = SingleChildScrollView(
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
          if (widget.stageIndex == 1) _buildStage1Content(),
          if (widget.stageIndex == 2) _buildStage2Content(),
          if (widget.stageIndex == 3) _buildStage3Content(),
          if (widget.stageIndex == 4) _buildStage4Content(),
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
      ],
    );
  }

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

  // --- Stage 1 Widgets ---
  Widget _buildTeamMembersCard() {
    // Hardcoded for UI match
    final students = [
      {'name': 'أحمد محمد علي', 'role': 'قائد الفريق'},
      {'name': 'فاطمة سعيد حسن', 'role': 'عضو'},
      {'name': 'خالد عبدالله محمد', 'role': 'عضو'},
      {'name': 'نورا إبراهيم أحمد', 'role': 'عضو'},
    ];

    return _buildCard(
      title: 'أعضاء الفريق',
      icon: Icons.people_outline,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width < 600 ? 1 : 2,
          childAspectRatio: MediaQuery.of(context).size.width < 600 ? 8 : 6,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final s = students[index];
          final isLeader = s['role'] == 'قائد الفريق';
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
                    s['name']!,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4B5563)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (isLeader)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF2D62ED), borderRadius: BorderRadius.circular(16)),
                    child: const Text('قائد الفريق', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResearchDetailsCard() {
    return _buildCard(
      title: 'تفاصيل البحث',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('عنوان البحث', style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: 'تأثير التسويق الرقمي على سلوك المستهلك',
            readOnly: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          const Text('وصف البحث', style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: 'يهدف هذا البحث إلى دراسة تأثير استراتيجيات التسويق الرقمي على سلوك المستهلك في السوق اليمني، من خلال تحليل أنماط الشراء الإلكتروني والعوامل المؤثرة في قرارات الشراء عبر المنصات الرقمية. سيتم استخدام منهج البحث الوصفي التحليلي لجمع البيانات من عينة عشوائية من المستهلكين.',
            readOnly: true,
            maxLines: 4,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalCard() {
    return _buildCard(
      title: 'اعتماد البحث',
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.cancel_outlined, color: Colors.white),
              label: const Text('رفض البحث', style: TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              label: const Text('اعتماد البحث', style: TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Stage 2 Widgets ---
  Widget _buildStageSummaryCard() {
    return _buildCard(
      title: 'ملخص اعتماد المرحلة',
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text('9/17', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
          const Text('عناصر معتمدة', style: TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.53,
              backgroundColor: Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 8),
          const Text('53% مكتمل', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStageFileCard() {
    return _buildCard(
      title: 'ملف المرحلة الثانية',
      icon: Icons.description_outlined,
      titleIconColor: Colors.red,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
          // border: Border.all(color: const Color(0xFFD1D5DB), style: BorderStyle.solid),
        ),
        // Draw dashed border in reality using a package, but we'll use solid for now or custom painter.
        // Actually, simple Container is fine for UI placeholder
      ),
    );
  }

  Widget _buildStageRequirementsCard() {
    final reqs = [
      {'title': 'المقدمة', 'status': 'approved'},
      {'title': 'مشكلة الدراسة', 'status': 'approved'},
      {'title': 'أهمية الدراسة', 'status': 'needs_edit'},
      {'title': 'أهداف الدراسة', 'status': 'approved'},
      {'title': 'فرضيات الدراسة', 'status': 'needs_edit'},
    ];

    return _buildCard(
      title: 'متطلبات المرحلة الثانية',
      child: Column(
        children: reqs.map((r) {
          final isApproved = r['status'] == 'approved';
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isApproved ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
              border: Border.all(color: isApproved ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width < 600 ? double.infinity : 200,
                  child: Text(r['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showNeedsEditDialog(context, r['title']!),
                  icon: Icon(Icons.info_outline, size: 16, color: isApproved ? const Color(0xFFF59E0B) : const Color(0xFFF59E0B)),
                  label: Text('يحتاج تعديل', style: TextStyle(color: isApproved ? const Color(0xFFF59E0B) : const Color(0xFFF59E0B))),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFF59E0B))),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('اعتماد'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isApproved ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
                    foregroundColor: Colors.white,
                  ),
                ),
                Icon(Icons.check_circle_outline, color: isApproved ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- Stage 3 Widgets ---
  Widget _buildDiscussionStatusCard() {
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
                    value: 0.68,
                    strokeWidth: 12,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2D62ED)),
                  ),
                  const Center(
                    child: Text(
                      '68%',
                      style: TextStyle(
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
                const Text('نسبة إنجاز المناقشة', style: TextStyle(color: Color(0xFF6B7280))),
                const SizedBox(height: 16),
                Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      value: 0.68,
                      backgroundColor: Color(0xFFE5E7EB),
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D62ED)),
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
                    const Text('نسبة الإنجاز (%)', style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: '68',
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
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
                    const Text('تاريخ المناقشة', style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: '11/01/2025',
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF9CA3AF), size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('ملاحظة (اختياري)', style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'أدخل أي ملاحظات حول المناقشة',
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                  label: const Text('لم تتم المناقشة', style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: const Text('تمت المناقشة', style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Stage 4 Widgets ---
  Widget _buildStage4Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (MediaQuery.of(context).size.width < 1000)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDefineRequirementsCard(),
              const SizedBox(height: 24),
              _buildStudentDocumentCard(),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildDefineRequirementsCard()),
              const SizedBox(width: 24),
              Expanded(child: _buildStudentDocumentCard()),
            ],
          ),
        const SizedBox(height: 24),
        _buildStageEvaluationCard(),
      ],
    );
  }

  Widget _buildDefineRequirementsCard() {
    return _buildCard(
      title: 'تحديد متطلبات النزول وإرسال الطلب',
      icon: Icons.assignment_add,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('الرجاء تحديد المتطلبات اللازمة لقيام الطالب بالنزول الميداني:', style: TextStyle(color: Color(0xFF4B5563))),
          const SizedBox(height: 16),
          // Mock requirements list
          _buildRequirementInput('1. تحديد منطقة النزول الميداني بدقة.'),
          const SizedBox(height: 12),
          _buildRequirementInput('2. تجهيز الاستبانة واعتمادها.'),
          const SizedBox(height: 12),
          _buildRequirementInput('3. إرفاق خطاب تسهيل المهمة.'),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18),
            label: const Text('إضافة متطلب جديد'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2D62ED),
              side: const BorderSide(color: Color(0xFF2D62ED)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              label: const Text('إرسال الطلب للطالب', style: TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981), // Green color for action
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementInput(String initialValue) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        suffixIcon: const Icon(Icons.delete_outline, color: Colors.red),
      ),
    );
  }

  Widget _buildStudentDocumentCard() {
    return _buildCard(
      title: 'مراجعة المستند المرفق من الطالب',
      icon: Icons.find_in_page_outlined,
      titleIconColor: const Color(0xFF2D62ED),
      child: Column(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'تقرير النزول ...',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'تم الإرسال: 2025/10/25 - الحجم: 2.4 MB',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('تم الاستلام', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showDocumentDetailsDialog(context),
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text('عرض المستند'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2D62ED),
                side: const BorderSide(color: Color(0xFF2D62ED)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildStageEvaluationCard() {
    return _buildCard(
      title: 'وضع النسبة وتقييم المرحلة',
      icon: Icons.percent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 0.60,
                      strokeWidth: 10,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                    ),
                    const Center(
                      child: Text('60%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('نسبة إنجاز المرحلة', style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        value: 0.60,
                        backgroundColor: Color(0xFFE5E7EB),
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                        minHeight: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),
          // Percentage + notes input
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('نسبة الإنجاز (%)', style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: '60',
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
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
                    const Text('تاريخ التقييم', style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: '25/10/2025',
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF9CA3AF), size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('ملاحظات المشرف (اختياري)', style: TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'أدخل ملاحظاتك حول أداء الطالب في النزول الميداني',
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                  label: const Text('رفض المستند', style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: const Text('اعتماد المرحلة', style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showNeedsEditDialog(BuildContext context, String requirementTitle) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.edit_note, color: Color(0xFFF59E0B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'إرسال ملاحظة لتعديل ($requirementTitle)',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  const Text(
                    'الملاحظة:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4B5563)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: textController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'اكتب الملاحظة أو التعديلات المطلوبة هنا...',
                      hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
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
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: () {
                  final note = textController.text.trim();
                  if (note.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('الرجاء إدخال الملاحظة أولاً'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('تم إرسال الملاحظة بنجاح'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('إرسال الملاحظة', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDocumentDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.find_in_page_outlined, color: Color(0xFF2D62ED)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'تفاصيل المستند المرفق',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('اسم الملف:', 'تقرير النزول الميداني.pdf'),
                  const Divider(height: 20),
                  _buildDetailRow('الحجم:', '2.4 MB'),
                  const Divider(height: 20),
                  _buildDetailRow('تاريخ الرفع:', '2025/10/25 12:48 م'),
                  const Divider(height: 20),
                  _buildDetailRow('الحالة:', 'تم الاستلام والدراسة'),
                  const Divider(height: 20),
                  _buildDetailRow('الوصف:', 'تقرير مفصل يحتوي على نتائج الاستبيان الميداني وتحليل استجابات عينة الدراسة الخاص بطلاب المجموعة الثانية في المرحلة الرابعة من المشروع.'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('بدء تحميل الملف... تم تنزيل المستند بنجاح'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                },
                icon: const Icon(Icons.download, color: Colors.white),
                label: const Text('تحميل الملف', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D62ED),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937), height: 1.4),
        ),
      ],
    );
  }

  // Helper Widget
  Widget _buildCard({required String title, required Widget child, IconData? icon, Color? titleIconColor}) {
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
                Icon(icon, color: titleIconColor ?? const Color(0xFF4B5563), size: isMobile ? 22 : 24),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: isMobile ? 17 : 20, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937)),
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
