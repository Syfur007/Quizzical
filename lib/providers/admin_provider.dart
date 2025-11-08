import 'package:flutter/foundation.dart';
import '../models/question_model.dart';
import '../models/result_model.dart';
import '../models/category_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class AdminProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  List<QuestionModel> _allQuestions = [];
  List<ResultModel> _allResults = [];
  List<CategoryModel> _categories = [];
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<QuestionModel> get allQuestions => _allQuestions;
  List<ResultModel> get allResults => _allResults;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Load all questions
  Future<void> loadAllQuestions() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _allQuestions = await _firestoreService.getAllQuestions();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load questions: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Add a new question
  Future<bool> addQuestion(QuestionModel question) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await _firestoreService.addQuestion(question);
      
      // Reload questions
      await loadAllQuestions();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add question: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Load all results
  Future<void> loadAllResults() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _allResults = await _firestoreService.getAllResults();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load results: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
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
  
  // Add a new category
  Future<bool> addCategory(CategoryModel category) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await _firestoreService.addCategory(category);
      
      // Reload categories
      await loadCategories();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add category: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Create a new user (admin functionality)
  Future<bool> createUser({
    required String email,
    required String password,
    required String name,
    bool isAdmin = false,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await _authService.signUp(
        email: email,
        password: password,
        name: name,
        isAdmin: isAdmin,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create user: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Get user name by ID
  Future<String> getUserName(String userId) async {
    return await _firestoreService.getUserName(userId);
  }
  
  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

