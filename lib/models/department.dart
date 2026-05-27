class Department {
  final int? id;
  final String name;

  Department({this.id, required this.name});

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json["dep_id"],
      name: json["dep_name"],
    );
  }
}
