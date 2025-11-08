import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../models/question_model.dart';
import '../models/result_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .orderBy('displayOrder')
          .get();
      return snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    await _firestore.collection('categories').add(category.toMap());
  }

  // Questions
  Future<List<QuestionModel>> getQuestions({
    required String category,
    required String type,
    int limit = 10,
  }) async {
    try {
      Query query = _firestore
          .collection('questions')
          .where('category', isEqualTo: category)
          .where('type', isEqualTo: type)
          .limit(limit);

      final snapshot = await query.get();
      final questions = snapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();
      
      // Shuffle to get random questions
      questions.shuffle();
      return questions.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addQuestion(QuestionModel question) async {
    await _firestore.collection('questions').add(question.toMap());
  }

  Future<List<QuestionModel>> getAllQuestions() async {
    try {
      final snapshot = await _firestore.collection('questions').get();
      return snapshot.docs.map((doc) => QuestionModel.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  // Results
  Future<void> saveResult(ResultModel result) async {
    await _firestore.collection('results').add(result.toMap());
  }

  Future<List<ResultModel>> getUserResults(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('results')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((doc) => ResultModel.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ResultModel>> getAllResults() async {
    try {
      final snapshot = await _firestore
          .collection('results')
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((doc) => ResultModel.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get user name by ID
  Future<String> getUserName(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data()?['name'] ?? 'Unknown User';
      }
      return 'Unknown User';
    } catch (e) {
      return 'Unknown User';
    }
  }
}

