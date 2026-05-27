class Program {
  final int? id;
  final String name;
  final int? departmentId;

  Program({this.id, required this.name, this.departmentId});

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json["program_id"],
      name: json["program_name"],
      departmentId: json["id_dep"],
    );
  }
}
