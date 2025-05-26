class Student {
  final int? id;
  final String name;
  final String email;
  final String password;

  Student({this.id, required this.name, required this.email, required this.password});

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
  };

  factory Student.fromMap(Map<String, dynamic> map) => Student(
    id: map['id'],
    name: map['name'],
    email: map['email'],
    password: map['password'],
  );
}
