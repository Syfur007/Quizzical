import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String id;
  final String category;
  final String type;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  final String? difficulty;

  QuestionModel({
    required this.id,
    required this.category,
    required this.type,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
    this.difficulty,
  });

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuestionModel(
      id: doc.id,
      category: data['category'] ?? '',
      type: data['type'] ?? 'multiple',
      question: data['question'] ?? '',
      correctAnswer: data['correct_answer'] ?? '',
      incorrectAnswers: List<String>.from(data['incorrect_answers'] ?? []),
      difficulty: data['difficulty'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'type': type,
      'question': question,
      'correct_answer': correctAnswer,
      'incorrect_answers': incorrectAnswers,
      'difficulty': difficulty,
    };
  }

  List<String> getAllAnswers() {
    return [correctAnswer, ...incorrectAnswers]..shuffle();
  }
}

