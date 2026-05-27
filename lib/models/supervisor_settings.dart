class SupervisorSettings {
  final int? id;
  final int supervisorId;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool weeklyReports;
  final String language;
  final String timezone;
  final String? profileImageUrl;
  final String? phoneNumber;
  final String? employeeId;

  SupervisorSettings({
    this.id,
    required this.supervisorId,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.weeklyReports = false,
    this.language = 'العربية',
    this.timezone = 'توقيت عدن (GMT+3)',
    this.profileImageUrl,
    this.phoneNumber,
    this.employeeId,
  });

  factory SupervisorSettings.fromJson(Map<String, dynamic> json) {
    return SupervisorSettings(
      id: json['settings_id'],
      supervisorId: json['id_sprvsr'],
      emailNotifications: json['email_notifications'] ?? true,
      pushNotifications: json['push_notifications'] ?? true,
      weeklyReports: json['weekly_reports'] ?? false,
      language: json['language'] ?? 'العربية',
      timezone: json['timezone'] ?? 'توقيت عدن (GMT+3)',
      profileImageUrl: json['profile_image_url'],
      phoneNumber: json['phone_number'],
      employeeId: json['employee_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_sprvsr': supervisorId,
      'email_notifications': emailNotifications,
      'push_notifications': pushNotifications,
      'weekly_reports': weeklyReports,
      'language': language,
      'timezone': timezone,
      'profile_image_url': profileImageUrl,
      'phone_number': phoneNumber,
      'employee_id': employeeId,
    };
  }

  SupervisorSettings copyWith({
    int? id,
    int? supervisorId,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? weeklyReports,
    String? language,
    String? timezone,
    String? profileImageUrl,
    String? phoneNumber,
    String? employeeId,
  }) {
    return SupervisorSettings(
      id: id ?? this.id,
      supervisorId: supervisorId ?? this.supervisorId,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      weeklyReports: weeklyReports ?? this.weeklyReports,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      employeeId: employeeId ?? this.employeeId,
    );
  }
}
