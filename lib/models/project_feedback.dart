import 'review_comment.dart';

class ProjectFeedback extends ReviewComment {
  ProjectFeedback({
    super.id,
    super.groupId,
    super.supervisorId,
    required super.comment,
    super.commentType,
    super.rating,
    super.createdAt,
    super.updatedAt,
    super.isResolved,
    super.stage,
  });

  factory ProjectFeedback.fromJson(Map<String, dynamic> json) {
    return ProjectFeedback(
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
}
