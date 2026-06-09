class ResearchGroup {
  final int? id;
  final String name;
  final int? supervisorId;
  final int? stateId;
  final int? leaderId;

  /// اسم قائد الفريق المشتق من جدول student عبر group_led_id
  final String? leaderName;
  final String? description;
  double? progress;

  /// اسم الحالة المشتق من جدول GroupState (states_name)
  String? status;

  /// اسم المرحلة الحالية المشتق من جدول stages (stage_name)
  String? currentStage;

  /// معرّف المرحلة الحالية (العمود current_stage في جدول groups، مفتاح خارجي إلى stages)
  int? currentStageId;

  final DateTime? createdAt;

  ResearchGroup({
    this.id,
    required this.name,
    this.supervisorId,
    this.stateId,
    this.leaderId,
    this.leaderName,
    this.description,
    this.progress,
    this.status,
    this.currentStage,
    this.currentStageId,
    this.createdAt,
  });

  factory ResearchGroup.fromJson(Map<String, dynamic> json) {
    // العلاقات المضمّنة (Embedded joins) قد تأتي كـ Map أو List أو null
    final stateRel = json["GroupState"];
    final stageRel = json["stages"];
    final leaderRel = json["student"];
    final firstStageRel = json["first stage"];

    String? description;
    if (firstStageRel is List && firstStageRel.isNotEmpty) {
      description = firstStageRel.first["research_description"];
    } else if (firstStageRel is Map) {
      description = firstStageRel["research_description"];
    }

    return ResearchGroup(
      id: json["group_id"],
      name: json["group_name"] ?? "",
      supervisorId: json["id_sprvsr"],
      stateId: json["id_group_state"],
      leaderId: json["group_led_id"],
      leaderName: leaderRel is Map ? leaderRel["stud_name"] : null,
      description: description,
      // group_progress مخزّن ككسر (0.0 - 1.0) بينما تستخدم الواجهة مقياس (0 - 100)
      progress: (json["group_progress"] as num?) != null
          ? (json["group_progress"] as num).toDouble() * 100
          : null,
      status: stateRel is Map ? stateRel["states_name"] : null,
      currentStage: stageRel is Map ? stageRel["stage_name"] : null,
      currentStageId: json["current_stage"],
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : null,
    );
  }

  ResearchGroup copyWith({
    int? id,
    String? name,
    int? supervisorId,
    int? stateId,
    int? leaderId,
    String? leaderName,
    String? description,
    double? progress,
    String? status,
    String? currentStage,
    int? currentStageId,
    DateTime? createdAt,
  }) {
    return ResearchGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      supervisorId: supervisorId ?? this.supervisorId,
      stateId: stateId ?? this.stateId,
      leaderId: leaderId ?? this.leaderId,
      leaderName: leaderName ?? this.leaderName,
      description: description ?? this.description,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      currentStage: currentStage ?? this.currentStage,
      currentStageId: currentStageId ?? this.currentStageId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// لا يحتوي إلا على الأعمدة الفعلية في جدول groups
  Map<String, dynamic> toJson() {
    return {
      "group_name": name,
      "id_sprvsr": supervisorId,
      "id_group_state": stateId,
      "group_led_id": leaderId,
      // إعادة التحويل إلى كسر (0.0 - 1.0) عند الكتابة لقاعدة البيانات
      "group_progress": progress != null ? progress! / 100 : null,
      "current_stage": currentStageId,
    };
  }
}
