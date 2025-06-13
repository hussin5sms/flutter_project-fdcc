class Company {
  final int id;
  final String name;

  Company({required this.id, required this.name});

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: int.tryParse(json['ID_num']?.toString() ?? '0') ?? 0,
      name: json['name_company']?.toString() ?? '',
    );
  }
}
// ID_num, name_company



// class Company {
//   final int id;
//   final String name;
//
//   Company({required this.id, required this.name});
//
//   factory Company.fromJson(Map<String, dynamic> json) {
//     return Company(
//       id: int.parse(json['ID_num']),
//       name: json['company_name'],
//     );
//   }
// }
