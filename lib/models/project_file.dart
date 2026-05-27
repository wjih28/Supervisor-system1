import 'research_file.dart';

class ProjectFile extends ResearchFile {
  ProjectFile({
    super.id,
    super.groupId,
    required super.fileName,
    super.fileUrl,
    super.fileType,
    super.fileSize,
    super.uploadedBy,
    super.uploadedAt,
    super.supervisorNotes,
    super.description,
    super.stage,
  });

  factory ProjectFile.fromJson(Map<String, dynamic> json) {
    return ProjectFile(
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
}
