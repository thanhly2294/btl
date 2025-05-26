class Grade {
  final int? id;
  final int studentId;
  final int classId;
  final double processScore;
  final double startupScore;
  final double examScore;
  final double totalScore;

  Grade({
    this.id,
    required this.studentId,
    required this.classId,
    required this.processScore,
    required this.startupScore,
    required this.examScore,
    required this.totalScore,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'studentId': studentId,
    'classId': classId,
    'process_score': processScore,
    'startup_score': startupScore,
    'exam_score': examScore,
    'total_score': totalScore,
  };

  factory Grade.fromMap(Map<String, dynamic> map) => Grade(
    id: map['id'],
    studentId: map['studentId'],
    classId: map['classId'],
    processScore: (map['process_score'] as num?)?.toDouble() ?? 0.0,
    startupScore: (map['startup_score'] as num?)?.toDouble() ?? 0.0,
    examScore: (map['exam_score'] as num?)?.toDouble() ?? 0.0,
    totalScore: (map['total_score'] as num?)?.toDouble() ?? 0.0,
  );
}