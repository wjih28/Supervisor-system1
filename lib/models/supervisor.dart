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
