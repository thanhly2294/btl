class Teacher {
  final int? id;
  final String name;
  final String email;
  final String password;

  Teacher({this.id, required this.name, required this.email, required this.password});

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
  };

  factory Teacher.fromMap(Map<String, dynamic> map) => Teacher(
    id: map['id'],
    name: map['name'],
    email: map['email'],
    password: map['password'],
  );
}
