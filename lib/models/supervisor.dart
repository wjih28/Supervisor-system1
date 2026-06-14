class Supervisor {
  final int? id;
  final String name;
  final String? email;
  final String? password;
  final String? username;
  final bool? isActive;
  final int? programId;
  final String? supervisPhoto;

  Supervisor({
    this.id,
    required this.name,
    this.email,
    this.password,
    this.username,
    this.isActive,
    this.programId,
    this.supervisPhoto,
  });

  factory Supervisor.fromJson(Map<String, dynamic> json) {
    return Supervisor(
      id: json["sprvsr_id"],
      name: json["sprvsr_name"],
      email: json["sprvsr_email"],
      password: json["sprvsr_password"],
      username: json["sprvsr_username"],
      isActive: json["sprvsr_isactive"],
      programId: json["program_id"],
      supervisPhoto: json["supervis_photo"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sprvsr_name": name,
      "sprvsr_email": email,
      "sprvsr_password": password,
      "sprvsr_username": username,
      "sprvsr_isactive": isActive,
      "program_id": programId,
      if (supervisPhoto != null) "supervis_photo": supervisPhoto,
    };
  }
}
