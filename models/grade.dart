class Grade {
  final int? id;
  final int studentId;
  final int classId;
  final double score;

  Grade({this.id, required this.studentId, required this.classId, required this.score});

  Map<String, dynamic> toMap() => {
    'id': id,
    'studentId': studentId,
    'classId': classId,
    'score': score,
  };

  factory Grade.fromMap(Map<String, dynamic> map) => Grade(
    id: map['id'],
    studentId: map['studentId'],
    classId: map['classId'],
    score: map['score'],
  );
}