class ProjectStage {
  final int? id;
  final int? groupId;
  final String name;
  final String? description;
  final bool? isCompleted;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? dueDate;
  final double? progress;
  final String? status;

  ProjectStage({
    this.id,
    this.groupId,
    required this.name,
    this.description,
    this.isCompleted,
    this.startDate,
    this.endDate,
    this.dueDate,
    this.progress,
    this.status,
  });

  factory ProjectStage.fromJson(Map<String, dynamic> json) {
    return ProjectStage(
      id: json["stage_id"],
      groupId: json["id_group"],
      name: json["stage_name"],
      description: json["stage_description"],
      isCompleted: json["is_completed"],
      startDate: json["start_date"] != null
          ? DateTime.parse(json["start_date"])
          : null,
      endDate:
          json["end_date"] != null ? DateTime.parse(json["end_date"]) : null,
      dueDate:
          json["due_date"] != null ? DateTime.parse(json["due_date"]) : null,
      progress: (json["completion_percentage"] as num?)?.toDouble(),
      status: json["stage_status"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id_group": groupId,
      "stage_name": name,
      "stage_description": description,
      "is_completed": isCompleted,
      "start_date": startDate?.toIso8601String(),
      "end_date": endDate?.toIso8601String(),
      "due_date": dueDate?.toIso8601String(),
      "completion_percentage": progress,
      "stage_status": status,
    };
  }
}
