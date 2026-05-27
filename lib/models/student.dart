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
