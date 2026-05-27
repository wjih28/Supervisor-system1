class ResearchFile {
  final int? id;
  final int? groupId;
  final String fileName;
  final String? fileUrl;
  final String? fileType;
  final int? fileSize;
  final String? uploadedBy;
  final DateTime? uploadedAt;
  final String? supervisorNotes;
  final String? description;
  final String? stage;

  ResearchFile({
    this.id,
    this.groupId,
    required this.fileName,
    this.fileUrl,
    this.fileType,
    this.fileSize,
    this.uploadedBy,
    this.uploadedAt,
    this.supervisorNotes,
    this.description,
    this.stage,
  });

  factory ResearchFile.fromJson(Map<String, dynamic> json) {
    return ResearchFile(
      id: json["file_id"],
      groupId: json["id_group"],
      fileName: json["file_name"] ?? "",
      fileUrl: json["file_url"],
      fileType: json["file_type"],
      fileSize: json["file_size"],
      uploadedBy: json["uploaded_by"],
      uploadedAt: json["uploaded_at"] != null
          ? DateTime.parse(json["uploaded_at"])
          : null,
      supervisorNotes: json["supervisor_notes"],
      description: json["file_description"] ?? json["description"],
      stage: json["stage"] ?? json["file_stage"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id_group": groupId,
      "file_name": fileName,
      "file_url": fileUrl,
      "file_type": fileType,
      "file_size": fileSize,
      "uploaded_by": uploadedBy,
      "uploaded_at": uploadedAt?.toIso8601String(),
      "supervisor_notes": supervisorNotes,
      "file_description": description,
      "file_stage": stage,
    };
  }
}
