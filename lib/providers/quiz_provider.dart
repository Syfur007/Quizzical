import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../models/question_model.dart';
import '../models/result_model.dart';
import '../services/firestore_service.dart';

class QuizProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<CategoryModel> _categories = [];
  List<QuestionModel> _questions = [];
  List<QuestionModel> _currentQuizQuestions = [];
  List<ResultModel> _userResults = [];
  
  bool _isLoading = false;
  String? _errorMessage;
  
  int _currentQuestionIndex = 0;
  Map<int, String> _userAnswers = {};
  
  // Getters
  List<CategoryModel> get categories => _categories;
  List<QuestionModel> get questions => _questions;
  List<QuestionModel> get currentQuizQuestions => _currentQuizQuestions;
  List<ResultModel> get userResults => _userResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<int, String> get userAnswers => _userAnswers;
  
  QuestionModel? get currentQuestion {
    if (_currentQuestionIndex < _currentQuizQuestions.length) {
      return _currentQuizQuestions[_currentQuestionIndex];
    }
    return null;
  }
  
  bool get isQuizComplete => _currentQuestionIndex >= _currentQuizQuestions.length;
  
  // Load categories
  Future<void> loadCategories() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _categories = await _firestoreService.getCategories();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load categories: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load questions for a quiz
  Future<bool> loadQuizQuestions({
    required String category,
    required String type,
    int limit = 10,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _currentQuizQuestions = await _firestoreService.getQuestions(
        category: category,
        type: type,
        limit: limit,
      );
      
      if (_currentQuizQuestions.isEmpty) {
        _errorMessage = 'No questions available for this category';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Reset quiz state
      _currentQuestionIndex = 0;
      _userAnswers = {};
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to load questions: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Answer a question
  void answerQuestion(String answer) {
    if (_currentQuestionIndex < _currentQuizQuestions.length) {
      _userAnswers[_currentQuestionIndex] = answer;
      notifyListeners();
    }
  }
  
  // Move to next question
  void nextQuestion() {
    if (_currentQuestionIndex < _currentQuizQuestions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }
  
  // Move to previous question
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }
  
  // Go to specific question
  void goToQuestion(int index) {
    if (index >= 0 && index < _currentQuizQuestions.length) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }
  
  // Calculate and save result
  Future<ResultModel?> submitQuiz({
    required String userId,
    required String userName,
    required String category,
    required String type,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Calculate score
      int score = 0;
      List<AnswerDetail> answerDetails = [];
      
      for (int i = 0; i < _currentQuizQuestions.length; i++) {
        final question = _currentQuizQuestions[i];
        final userAnswer = _userAnswers[i] ?? '';
        final isCorrect = userAnswer == question.correctAnswer;
        
        if (isCorrect) score++;
        
        answerDetails.add(AnswerDetail(
          question: question.question,
          userAnswer: userAnswer,
          correctAnswer: question.correctAnswer,
          isCorrect: isCorrect,
        ));
      }
      
      final accuracy = (score / _currentQuizQuestions.length) * 100;
      
      // Create result model
      final result = ResultModel(
        id: '',
        userId: userId,
        category: category,
        type: type,
        score: score,
        totalQuestions: _currentQuizQuestions.length,
        accuracy: accuracy,
        timestamp: DateTime.now(),
        answers: answerDetails,
      );
      
      // Save to Firestore
      await _firestoreService.saveResult(result);
      
      _isLoading = false;
      notifyListeners();
      
      return result;
    } catch (e) {
      _errorMessage = 'Failed to submit quiz: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  // Load user results
  Future<void> loadUserResults(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _userResults = await _firestoreService.getUserResults(userId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load results: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Reset quiz
  void resetQuiz() {
    _currentQuizQuestions = [];
    _currentQuestionIndex = 0;
    _userAnswers = {};
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

