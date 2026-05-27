/// إشعار التطبيق - تم تسميته AppNotification لتجنب التعارض مع Notification من Flutter
class AppNotification {
  final int? id;
  final int? supervisorId;
  final String title;
  final String message;
  final DateTime? createdAt;
  final bool? isRead;

  AppNotification({
    this.id,
    this.supervisorId,
    required this.title,
    required this.message,
    this.createdAt,
    this.isRead,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
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
