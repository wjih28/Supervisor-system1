import 'package:flutter/material.dart';
import '../../controllers/supervisor/settings_controller.dart';
import '../../models/models.dart';
import '../widgets/desktop_layout.dart';

class SettingsView extends StatefulWidget {
  final Supervisor supervisor;
  final bool isGuest;

  const SettingsView({
    super.key,
    required this.supervisor,
    this.isGuest = false,
  });

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final SettingsController _controller = SettingsController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _programController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller.loadSettings(
      supervisor: widget.supervisor,
      isGuest: widget.isGuest,
      nameController: _nameController,
      emailController: _emailController,
      phoneController: _phoneController,
      employeeIdController: _employeeIdController,
      departmentController: _departmentController,
      programController: _programController,
    );
  }

  Future<void> _saveSettings() async {
    if (widget.isGuest) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('عرض الضيف: البيانات لا تُحفظ فعلياً')),
        );
      }
      return;
    }
    final success = await _controller.saveSettings(
      isGuest: widget.isGuest,
      phone: _phoneController.text,
      employeeId: _employeeIdController.text,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الإعدادات بنجاح')),
      );
    }
  }

  Future<void> _updatePassword() async {
    if (widget.isGuest) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('عرض الضيف: تغيير كلمة المرور غير متاح')),
        );
      }
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمات المرور غير متطابقة')),
      );
      return;
    }
    if (_currentPasswordController.text != widget.supervisor.password) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمة المرور الحالية غير صحيحة')),
      );
      return;
    }
    final success = await _controller.updatePassword(
      supervisor: widget.supervisor,
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
      isGuest: widget.isGuest,
    );
    if (success && mounted) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث كلمة المرور بنجاح')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return DesktopLayout(
      selectedIndex: 4,
      supervisorId: widget.supervisor.id,
      supervisorName: widget.supervisor.name,
      supervisor: widget.supervisor,
      isGuest: widget.isGuest,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        body: _controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildPageHeader(isDesktop),
                    const SizedBox(height: 32),
                    _buildSectionHeader(Icons.person_outline, 'المعلومات الشخصية'),
                    const SizedBox(height: 24),
                    _buildPersonalInfoSection(isDesktop),
                    const SizedBox(height: 32),
                    _buildSectionHeader(Icons.notifications_none, 'الإشعارات'),
                    const SizedBox(height: 24),
                    _buildNotificationsSection(),
                    const SizedBox(height: 32),
                    _buildSectionHeader(Icons.lock_outline, 'الأمان'),
                    const SizedBox(height: 24),
                    _buildSecuritySection(),
                    const SizedBox(height: 32),
                    _buildSectionHeader(Icons.language, 'اللغة والمظهر'),
                    const SizedBox(height: 24),
                    _buildAppearanceSection(),
                    const SizedBox(height: 32),
                    _buildSectionHeader(Icons.info_outline, 'معلومات النظام'),
                    const SizedBox(height: 24),
                    _buildSystemInfoSection(isDesktop),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPageHeader(bool isDesktop) {
    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save_outlined, size: 18, color: Colors.white),
            label: const Text('حفظ التغييرات'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D62ED),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('الإعدادات', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
              Text('إدارة حسابك وتفضيلات النظام', style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('الإعدادات', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
          const Text('إدارة حسابك وتفضيلات النظام', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save_outlined, size: 18, color: Colors.white),
              label: const Text('حفظ التغييرات'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D62ED),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
        const SizedBox(width: 12),
        Icon(icon, color: const Color(0xFF2D62ED)),
      ],
    );
  }

  Widget _buildResponsiveRow(Widget child1, Widget child2, bool isDesktop) {
    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: child1),
          const SizedBox(width: 20),
          Expanded(child: child2),
        ],
      );
    } else {
      return Column(
        children: [
          child2,
          const SizedBox(height: 20),
          child1,
        ],
      );
    }
  }

  Widget _buildPersonalInfoSection(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10)],
      ),
      child: Column(
        children: [
          isDesktop
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('تغيير الصورة', style: TextStyle(color: Color(0xFF4A5568))),
                        ),
                        const SizedBox(height: 4),
                        const Text('JPG, PNG أو GIF (الحد الأقصى 2 ميجابايت)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(width: 24),
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFFDBEAFE),
                      child: Icon(Icons.person, size: 40, color: Color(0xFF2D62ED)),
                    ),
                  ],
                )
              : Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFFDBEAFE),
                      child: Icon(Icons.person, size: 40, color: Color(0xFF2D62ED)),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('تغيير الصورة', style: TextStyle(color: Color(0xFF4A5568))),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'JPG, PNG أو GIF (الحد الأقصى 2 ميجابايت)',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
          const SizedBox(height: 32),
          _buildResponsiveRow(
            _buildTextField('البريد الإلكتروني', _emailController, enabled: false),
            _buildTextField('الاسم الكامل', _nameController, enabled: false),
            isDesktop,
          ),
          const SizedBox(height: 20),
          _buildResponsiveRow(
            _buildTextField('القسم', _departmentController, enabled: false),
            _buildTextField('رقم الهاتف', _phoneController),
            isDesktop,
          ),
          const SizedBox(height: 20),
          _buildResponsiveRow(
            _buildTextField('الرقم الوظيفي', _employeeIdController, enabled: false),
            _buildTextField('البرنامج', _programController, enabled: false),
            isDesktop,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            'إشعارات البريد الإلكتروني',
            'استلام إشعارات عبر البريد الإلكتروني',
            _controller.settings?.emailNotifications ?? true,
            (val) => setState(() => _controller.updateSettings(_controller.settings?.copyWith(emailNotifications: val))),
          ),
          const Divider(height: 32),
          _buildSwitchTile(
            'الإشعارات الفورية',
            'استلام إشعارات فورية على الجهاز',
            _controller.settings?.pushNotifications ?? true,
            (val) => setState(() => _controller.updateSettings(_controller.settings?.copyWith(pushNotifications: val))),
          ),
          const Divider(height: 32),
          _buildSwitchTile(
            'التقارير الأسبوعية',
            'استلام ملخص أسبوعي لحالة الأبحاث',
            _controller.settings?.weeklyReports ?? false,
            (val) => setState(() => _controller.updateSettings(_controller.settings?.copyWith(weeklyReports: val))),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildTextField('كلمة المرور الحالية', _currentPasswordController, isPassword: true, hintText: 'أدخل كلمة المرور الحالية'),
          const SizedBox(height: 20),
          _buildTextField('كلمة المرور الجديدة', _newPasswordController, isPassword: true, hintText: 'أدخل كلمة المرور الجديدة'),
          const SizedBox(height: 20),
          _buildTextField('تأكيد كلمة المرور الجديدة', _confirmPasswordController, isPassword: true, hintText: 'أعد إدخال كلمة المرور الجديدة'),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: _updatePassword,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2D62ED)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('تحديث كلمة المرور', style: TextStyle(color: Color(0xFF2D62ED))),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildDropdownField('اللغة', ['العربية', 'English'], _controller.settings?.language ?? 'العربية', (val) {
            if (val != null) {
              setState(() => _controller.updateSettings(_controller.settings?.copyWith(language: val)));
            }
          }),
          const SizedBox(height: 24),
          _buildDropdownField('المنطقة الزمنية', ['توقيت عدن (GMT+3)', 'توقيت مكة (GMT+3)', 'توقيت دبي (GMT+4)'],
              _controller.settings?.timezone ?? 'توقيت عدن (GMT+3)', (val) {
            if (val != null) {
              setState(() => _controller.updateSettings(_controller.settings?.copyWith(timezone: val)));
            }
          }),
        ],
      ),
    );
  }

  Widget _buildSystemInfoSection(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildResponsiveRow(
            _buildInfoRow('تاريخ آخر تحديث:', '2025-01-15'),
            _buildInfoRow('إصدار النظام:', '1.0.0'),
            isDesktop,
          ),
          const SizedBox(height: 24),
          _buildResponsiveRow(
            _buildInfoRow('الكلية:', 'كلية العلوم الإدارية والإنسانية'),
            _buildInfoRow('المؤسسة:', 'جامعة العلوم والتكنولوجيا'),
            isDesktop,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A5568))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool enabled = true, bool isPassword = false, String? hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF4A5568), fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: isPassword,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: !enabled || true,
            fillColor: enabled ? Colors.white : const Color(0xFFF7FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2D62ED))),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade100)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> options, String value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF4A5568), fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              value: value,
              items: options.map((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val, style: const TextStyle(color: Color(0xFF4A5568))),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: const Color(0xFF1E1E1E), // Dark color like in screenshot
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade300,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _programController.dispose();
    _employeeIdController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _controller.dispose();
    super.dispose();
  }
}
