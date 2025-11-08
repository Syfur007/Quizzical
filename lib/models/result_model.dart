import 'package:cloud_firestore/cloud_firestore.dart';

class AnswerDetail {
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;

  AnswerDetail({
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
    };
  }

  factory AnswerDetail.fromMap(Map<String, dynamic> map) {
    return AnswerDetail(
      question: map['question'] ?? '',
      userAnswer: map['userAnswer'] ?? '',
      correctAnswer: map['correctAnswer'] ?? '',
      isCorrect: map['isCorrect'] ?? false,
    );
  }
}

class ResultModel {
  final String id;
  final String userId;
  final String category;
  final String type;
  final int score;
  final int totalQuestions;
  final double accuracy;
  final DateTime timestamp;
  final List<AnswerDetail> answers;

  ResultModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.type,
    required this.score,
    required this.totalQuestions,
    required this.accuracy,
    required this.timestamp,
    required this.answers,
  });

  factory ResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ResultModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      category: data['category'] ?? '',
      type: data['type'] ?? '',
      score: data['score'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      accuracy: (data['accuracy'] ?? 0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      answers: (data['answers'] as List?)
          ?.map((a) => AnswerDetail.fromMap(a as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'category': category,
      'type': type,
      'score': score,
      'totalQuestions': totalQuestions,
      'accuracy': accuracy,
      'timestamp': Timestamp.fromDate(timestamp),
      'answers': answers.map((a) => a.toMap()).toList(),
    };
  }
}


