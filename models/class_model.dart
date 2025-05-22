class ClassModel {
  final int? id;
  final String name;
  final int teacherId;

  ClassModel({this.id, required this.name, required this.teacherId});

  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
      id: map['id'],
      name: map['name'],
      teacherId: map['teacherId'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'teacherId': teacherId,
    };
  }
}