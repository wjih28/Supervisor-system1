import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/supabase_service.dart';

class SettingsScreen extends StatefulWidget {
  final Supervisor supervisor;
  final bool isGuest;

  const SettingsScreen({
    super.key,
    required this.supervisor,
    this.isGuest = false,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true;
  SupervisorSettings? _settings;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _programController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      if (widget.isGuest) {
        _settings = SupervisorSettings(
          supervisorId: widget.supervisor.id!,
          phoneNumber: '+968 1234 5678',
          employeeId: 'GUEST-001',
          language: 'العربية',
          timezone: 'توقيت عدن (GMT+3)',
          emailNotifications: true,
          pushNotifications: true,
          weeklyReports: false,
        );

        _nameController.text = widget.supervisor.name;
        _emailController.text = widget.supervisor.email ?? 'guest@example.com';
        _phoneController.text = _settings?.phoneNumber ?? '';
        _employeeIdController.text = _settings?.employeeId ?? '';
        _departmentController.text = 'إدارة الأعمال';
        _programController.text = 'إدارة أعمال دولية';
      } else {
        _settings =
            await SupabaseService.getSupervisorSettings(widget.supervisor.id!);
        if (_settings == null) {
          _settings = SupervisorSettings(supervisorId: widget.supervisor.id!);
        }

        _nameController.text = widget.supervisor.name;
        _emailController.text = widget.supervisor.email ?? '';
        _phoneController.text = _settings?.phoneNumber ?? '';
        _employeeIdController.text = _settings?.employeeId ?? '';

        // جلب بيانات القسم والبرنامج
        if (widget.supervisor.programId != null) {
          final program = await SupabaseService.getProgramById(
              widget.supervisor.programId!);
          if (program != null) {
            _programController.text = program.name;
            final department = await SupabaseService.getDepartmentById(
                program.departmentId ?? 0);
            _departmentController.text = department?.name ?? '';
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (_settings == null) return;

    setState(() => _isLoading = true);
    try {
      if (widget.isGuest) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('عرض الضيف: البيانات لا تُحفظ فعلياً')),
          );
        }
        return;
      }

      final updatedSettings = _settings!.copyWith(
        phoneNumber: _phoneController.text,
        employeeId: _employeeIdController.text,
      );

      final success =
          await SupabaseService.updateSupervisorSettings(updatedSettings);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الإعدادات بنجاح')),
        );
      }
    } catch (e) {
      debugPrint('Error saving settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمات المرور غير متطابقة')),
      );
      return;
    }

    if (widget.isGuest) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('عرض الضيف: تغيير كلمة المرور غير متاح')),
        );
      }
      return;
    }

    if (_currentPasswordController.text != widget.supervisor.password) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمة المرور الحالية غير صحيحة')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await SupabaseService.updateSupervisorPassword(
        widget.supervisor.id!,
        _newPasswordController.text,
      );
      if (success && mounted) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث كلمة المرور بنجاح')),
        );
      }
    } catch (e) {
      debugPrint('Error updating password: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'نظام إدارة ومتابعة أبحاث التخرج',
          style: TextStyle(
              color: Color(0xFF2D62ED),
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D62ED)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.grey),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFE0E0E0),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _saveSettings,
                        icon: const Icon(Icons.save_outlined, size: 18),
                        label: const Text('حفظ التغييرات'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D62ED),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'الإعدادات',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748)),
                          ),
                          Text(
                            'إدارة حسابك وتفضيلات النظام',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader(
                      Icons.person_outline, 'المعلومات الشخصية'),
                  const SizedBox(height: 24),
                  _buildPersonalInfoSection(),
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
                  _buildSystemInfoSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748)),
        ),
        const SizedBox(width: 12),
        Icon(icon, color: const Color(0xFF2D62ED)),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('تغيير الصورة',
                        style: TextStyle(color: Color(0xFF2D62ED))),
                  ),
                  const Text('JPG, PNG أو GIF (الحد الأقصى 2 ميجابايت)',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const SizedBox(width: 24),
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFFF0F4FF),
                child: Icon(Icons.person, size: 40, color: Color(0xFF2D62ED)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                  child: _buildTextField('البريد الإلكتروني', _emailController,
                      enabled: false)),
              const SizedBox(width: 20),
              Expanded(
                  child: _buildTextField('الاسم الكامل', _nameController,
                      enabled: false)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: _buildTextField('القسم', _departmentController,
                      enabled: false)),
              const SizedBox(width: 20),
              Expanded(child: _buildTextField('رقم الهاتف', _phoneController)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child:
                      _buildTextField('الرقم الوظيفي', _employeeIdController)),
              const SizedBox(width: 20),
              Expanded(
                  child: _buildTextField('البرنامج', _programController,
                      enabled: false)),
            ],
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            'إشعارات البريد الإلكتروني',
            'استلام إشعارات عبر البريد الإلكتروني',
            _settings?.emailNotifications ?? true,
            (val) => setState(
                () => _settings = _settings?.copyWith(emailNotifications: val)),
          ),
          const Divider(height: 32),
          _buildSwitchTile(
            'الإشعارات الفورية',
            'استلام إشعارات فورية على الجهاز',
            _settings?.pushNotifications ?? true,
            (val) => setState(
                () => _settings = _settings?.copyWith(pushNotifications: val)),
          ),
          const Divider(height: 32),
          _buildSwitchTile(
            'التقارير الأسبوعية',
            'استلام ملخص أسبوعي لحالة الأبحاث',
            _settings?.weeklyReports ?? false,
            (val) => setState(
                () => _settings = _settings?.copyWith(weeklyReports: val)),
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildTextField('كلمة المرور الحالية', _currentPasswordController,
              isPassword: true),
          const SizedBox(height: 20),
          _buildTextField('كلمة المرور الجديدة', _newPasswordController,
              isPassword: true),
          const SizedBox(height: 20),
          _buildTextField(
              'تأكيد كلمة المرور الجديدة', _confirmPasswordController,
              isPassword: true),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: _updatePassword,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2D62ED)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('تحديث كلمة المرور',
                style: TextStyle(color: Color(0xFF2D62ED))),
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          _buildDropdownTile(
              'اللغة', ['العربية', 'English'], _settings?.language ?? 'العربية',
              (val) {
            if (val != null)
              setState(() => _settings = _settings?.copyWith(language: val));
          }),
          const Divider(height: 32),
          _buildDropdownTile(
              'المنطقة الزمنية',
              ['توقيت عدن (GMT+3)', 'توقيت مكة (GMT+3)', 'توقيت دبي (GMT+4)'],
              _settings?.timezone ?? 'توقيت عدن (GMT+3)', (val) {
            if (val != null)
              setState(() => _settings = _settings?.copyWith(timezone: val));
          }),
        ],
      ),
    );
  }

  Widget _buildSystemInfoSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('2025-01-15', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('تاريخ آخر تحديث:', style: TextStyle(color: Colors.grey)),
              Text('1.0.0', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('إصدار النظام:', style: TextStyle(color: Colors.grey)),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('كلية العلوم الإدارية والإنسانية',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('الكلية:', style: TextStyle(color: Colors.grey)),
              Text('جامعة العلوم والتكنولوجيا',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('المؤسسة:', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4A5568),
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: isPassword,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            filled: !enabled,
            fillColor: const Color(0xFFF7FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2D62ED)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownTile(String title, List<String> options, String value,
      Function(String?) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: value,
            items: options
                .map((String val) =>
                    DropdownMenuItem<String>(value: val, child: Text(val)))
                .toList(),
            onChanged: onChanged,
            underline: const SizedBox(),
          ),
        ),
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
