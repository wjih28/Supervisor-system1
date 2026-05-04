// Domain Models - Pure Dart classes representing the business entities

class Student {
  final int? id;
  final String name;
  final String? email;
  final String? username;
  final int? programId;
  final int? groupId;
  final String? role;

  Student({
    this.id,
    required this.name,
    this.email,
    this.username,
    this.programId,
    this.groupId,
    this.role,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json["stud_id"],
      name: json["stud_name"],
      email: json["stud_email"],
      username: json["stud_username"],
      programId: json["id_program"],
      groupId: json["id_group"],
      role: json["role"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "stud_name": name,
      "stud_email": email,
      "stud_username": username,
      "id_program": programId,
      "id_group": groupId,
      "role": role,
    };
  }
}

class Supervisor {
  final int? id;
  final String name;
  final String? email;
  final String? password;
  final String? username;
  final bool? isActive;
  final int? programId;

  Supervisor({
    this.id,
    required this.name,
    this.email,
    this.password,
    this.username,
    this.isActive,
    this.programId,
  });

  factory Supervisor.fromJson(Map<String, dynamic> json) {
    return Supervisor(
      id: json["sprvsr_id"],
      name: json["sprvsr_name"],
      email: json["sprvsr_email"],
      password: json["sprvsr_password"],
      username: json["sprvsr_username"],
      isActive: json["sprvsr_isactive"],
      programId: json["id_program"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sprvsr_name": name,
      "sprvsr_email": email,
      "sprvsr_password": password,
      "sprvsr_username": username,
      "sprvsr_isactive": isActive,
      "id_program": programId,
    };
  }
}

class ResearchGroup {
  final int? id;
  final String name;
  final int? supervisorId;
  final int? stateId;
  final int? leaderId;
  final String? description;
  double? progress;
  String? status;
  String? currentStage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ResearchGroup({
    this.id,
    required this.name,
    this.supervisorId,
    this.stateId,
    this.leaderId,
    this.description,
    this.progress,
    this.status,
    this.currentStage,
    this.createdAt,
    this.updatedAt,
  });

  factory ResearchGroup.fromJson(Map<String, dynamic> json) {
    return ResearchGroup(
      id: json["group_id"],
      name: json["group_name"],
      supervisorId: json["id_sprvsr"],
      stateId: json["id_group_state"],
      leaderId: json["group_led_id"],
      description: json["group_description"],
      progress: (json["group_progress"] as num?)?.toDouble(),
      status: json["group_status"],
      currentStage: json["current_stage"],
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : null,
      updatedAt: json["updated_at"] != null
          ? DateTime.parse(json["updated_at"])
          : null,
    );
  }

  ResearchGroup copyWith({
    int? id,
    String? name,
    int? supervisorId,
    int? stateId,
    int? leaderId,
    String? description,
    double? progress,
    String? status,
    String? currentStage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ResearchGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      supervisorId: supervisorId ?? this.supervisorId,
      stateId: stateId ?? this.stateId,
      leaderId: leaderId ?? this.leaderId,
      description: description ?? this.description,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      currentStage: currentStage ?? this.currentStage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "group_name": name,
      "id_sprvsr": supervisorId,
      "id_group_state": stateId,
      "group_led_id": leaderId,
      "group_description": description,
      "group_progress": progress,
      "group_status": status,
      "current_stage": currentStage,
    };
  }
}

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

class ReviewComment {
  final int? id;
  final int? groupId;
  final int? supervisorId;
  final String comment;
  final String? commentType;
  final int? rating;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isResolved;
  final String? stage;

  ReviewComment({
    this.id,
    this.groupId,
    this.supervisorId,
    required this.comment,
    this.commentType,
    this.rating,
    this.createdAt,
    this.updatedAt,
    this.isResolved,
    this.stage,
  });

  factory ReviewComment.fromJson(Map<String, dynamic> json) {
    return ReviewComment(
      id: json["comment_id"],
      groupId: json["id_group"],
      supervisorId: json["id_sprvsr"],
      comment: json["comment_text"],
      commentType: json["comment_type"],
      rating: json["comment_rating"],
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : null,
      updatedAt: json["updated_at"] != null
          ? DateTime.parse(json["updated_at"])
          : null,
      isResolved: json["is_resolved"],
      stage: json["comment_stage"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id_group": groupId,
      "id_sprvsr": supervisorId,
      "comment_text": comment,
      "comment_type": commentType,
      "comment_rating": rating,
      "is_resolved": isResolved,
      "comment_stage": stage,
    };
  }
}

class Notification {
  final int? id;
  final int? supervisorId;
  final String title;
  final String message;
  final DateTime? createdAt;
  final bool? isRead;

  Notification({
    this.id,
    this.supervisorId,
    required this.title,
    required this.message,
    this.createdAt,
    this.isRead,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json["notif_id"],
      supervisorId: json["id_sprvsr"],
      title: json["notif_title"],
      message: json["notif_message"],
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : null,
      isRead: json["is_read"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id_sprvsr": supervisorId,
      "notif_title": title,
      "notif_message": message,
      "is_read": isRead,
    };
  }
}
