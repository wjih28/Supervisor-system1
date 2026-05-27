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
