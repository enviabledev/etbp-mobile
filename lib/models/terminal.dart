class Terminal {
  final String id;
  final String name;
  final String code;
  final String city;
  final String state;

  Terminal({required this.id, required this.name, required this.code, required this.city, required this.state});

  factory Terminal.fromJson(Map<String, dynamic> json) => Terminal(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    code: json['code'] ?? '',
    city: json['city'] ?? '',
    state: json['state'] ?? '',
  );
}
