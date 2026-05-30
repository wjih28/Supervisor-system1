import 'package:flutter/material.dart';
import '../../controllers/supervisor/grades_controller.dart';
import '../widgets/desktop_layout.dart';

class GradesEntryView extends StatefulWidget {
  final int supervisorId;
  final bool isGuest;
  final String supervisorName;

  const GradesEntryView({
    super.key,
    required this.supervisorId,
    this.isGuest = false,
    required this.supervisorName,
  });

  @override
  State<GradesEntryView> createState() => _GradesEntryViewState();
}

class _GradesEntryViewState extends State<GradesEntryView> {
  final GradesController _controller = GradesController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller.loadStudents(
        supervisorId: widget.supervisorId, isGuest: widget.isGuest);
  }

  Future<void> _saveGrades() async {
    if (widget.isGuest) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'عرض الضيف: الدرجات لن تُحفظ.')),
        );
      }
      return;
    }
    final success = await _controller.saveGrades(isGuest: widget.isGuest);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الدرجات بنجاح')),
      );
    }
  }

  bool get _isMobile => MediaQuery.of(context).size.width < 800;

  @override
  Widget build(BuildContext context) {
    return DesktopLayout(
      selectedIndex: 3,
      supervisorId: widget.supervisorId,
      supervisorName: widget.supervisorName,
      isGuest: widget.isGuest,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: _controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(_isMobile ? 16.0 : 24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildStatsCards(),
                      const SizedBox(height: 24),
                      _buildStudentsTable(),
                      const SizedBox(height: 24),
                      _buildGradingKey(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    if (_isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إدخال الدرجات النهائية',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'إدخال ومتابعة درجات الطلاب في أبحاث التخرج',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveGrades,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('حفظ الدرجات'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'إدخال الدرجات النهائية',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'إدخال ومتابعة درجات الطلاب في أبحاث التخرج',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _saveGrades,
          icon: const Icon(Icons.save, color: Colors.white),
          label: const Text('حفظ الدرجات'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    if (_isMobile) {
      // 2x2 grid on mobile
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
        children: [
          _buildStatCard('إجمالي الطلاب', _controller.totalStudents.toString(),
              const Color(0xFF2D62ED)),
          _buildStatCard('تم إدخال الدرجات', _controller.gradedStudents.toString(),
              const Color(0xFF10B981)),
          _buildStatCard('في انتظار الإدخال', _controller.ungradedStudents.toString(),
              const Color(0xFFEA580C)),
          _buildStatCard('المعدل العام', _controller.overallAverage.toStringAsFixed(1),
              const Color(0xFF8B5CF6)),
        ],
      );
    }

    return Row(
      children: [
        _buildStatCardExpanded('إجمالي الطلاب', _controller.totalStudents.toString(),
            const Color(0xFF2D62ED)),
        const SizedBox(width: 16),
        _buildStatCardExpanded('تم إدخال الدرجات', _controller.gradedStudents.toString(),
            const Color(0xFF10B981)),
        const SizedBox(width: 16),
        _buildStatCardExpanded('في انتظار الإدخال', _controller.ungradedStudents.toString(),
            const Color(0xFFEA580C)),
        const SizedBox(width: 16),
        _buildStatCardExpanded('المعدل العام', _controller.overallAverage.toStringAsFixed(1),
            const Color(0xFF8B5CF6)),
      ],
    );
  }

  Widget _buildStatCardExpanded(String title, String value, Color color) {
    return Expanded(child: _buildStatCard(title, value, color));
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
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTable() {
    if (_controller.students.isEmpty) {
      return const Center(child: Text('لا يوجد طلاب مضافين للمشاريع'));
    }

    if (_isMobile) {
      return _buildMobileStudentsList();
    }

    return _buildDesktopTable();
  }

  // --- Mobile: Card-based list instead of table ---
  Widget _buildMobileStudentsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _controller.students.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
        itemBuilder: (context, index) {
          final item = _controller.students[index];
          final grade = _controller.grades[item.student.id];
          final rating = _controller.getRating(grade);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: # and student name
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.student.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.student.role == 'قائد الفريق')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D62ED),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.student.role!,
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Row 2: project name
                Text(
                  item.projectName,
                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                // Row 3: grade input + rating
                Row(
                  children: [
                    const Text('الدرجة: ', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        initialValue: grade != null ? grade.toInt().toString() : '',
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: '0-100',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          final numValue = double.tryParse(value);
                          if (numValue != null && numValue >= 0 && numValue <= 100) {
                            _controller.updateGrade(item.student.id!, numValue);
                          } else if (value.isEmpty) {
                            _controller.updateGrade(item.student.id!, null);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text('التقدير: ', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                    Text(
                      rating['text'],
                      style: TextStyle(color: rating['color'], fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Desktop: Traditional table ---
  Widget _buildDesktopTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: const Row(
              children: [
                SizedBox(width: 40, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 2, child: Text('اسم الطالب', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 3, child: Text('عنوان البحث', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 1, child: Text('الدور', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 1, child: Text('الدرجة (من 100)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Expanded(flex: 1, child: Text('التقدير', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
              ],
            ),
          ),
          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _controller.students.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (context, index) {
              final item = _controller.students[index];
                final grade = _controller.grades[item.student.id];
                final rating = _controller.getRating(grade);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(width: 40, child: Text('${index + 1}', style: const TextStyle(color: Colors.grey))),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.student.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.projectName,
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: item.student.role == 'قائد الفريق'
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2D62ED),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item.student.role!,
                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : Text(item.student.role ?? 'عضو', style: const TextStyle(color: Colors.grey)),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.only(left: 32),
                          child: TextFormField(
                            initialValue: grade != null ? grade.toInt().toString() : '',
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'أدخل الدرجة',
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (value) {
                              final numValue = double.tryParse(value);
                              if (numValue != null && numValue >= 0 && numValue <= 100) {
                                _controller.updateGrade(item.student.id!, numValue);
                              } else if (value.isEmpty) {
                                _controller.updateGrade(item.student.id!, null);
                              }
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            rating['text'],
                            style: TextStyle(color: rating['color'], fontWeight: FontWeight.bold),
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

  Widget _buildGradingKey() {
    if (_isMobile) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'مفتاح التقديرات',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildKeyItem('ممتاز: 90-100', const Color(0xFF10B981)),
                _buildKeyItem('جيد جداً: 80-89', const Color(0xFF2D62ED)),
                _buildKeyItem('جيد: 70-79', const Color(0xFFD97706)),
                _buildKeyItem('مقبول: 60-69', const Color(0xFFEA580C)),
                _buildKeyItem('ضعيف: أقل من 60', const Color(0xFFEF4444)),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مفتاح التقديرات',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildKeyItem('ممتاز: 90-100', const Color(0xFF10B981)),
              _buildKeyItem('جيد جداً: 80-89', const Color(0xFF2D62ED)),
              _buildKeyItem('جيد: 70-79', const Color(0xFFD97706)),
              _buildKeyItem('مقبول: 60-69', const Color(0xFFEA580C)),
              _buildKeyItem('ضعيف: أقل من 60', const Color(0xFFEF4444)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
