import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/question_model.dart';

class AdminAddQuestionScreen extends StatefulWidget {
  const AdminAddQuestionScreen({super.key});

  @override
  State<AdminAddQuestionScreen> createState() => _AdminAddQuestionScreenState();
}

class _AdminAddQuestionScreenState extends State<AdminAddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  final _questionController = TextEditingController();
  final _correctAnswerController = TextEditingController();
  final _incorrectAnswer1Controller = TextEditingController();
  final _incorrectAnswer2Controller = TextEditingController();
  final _incorrectAnswer3Controller = TextEditingController();

  String _selectedCategory = '';
  String _selectedType = 'multiple';
  String _selectedDifficulty = 'medium';
  bool _isLoading = false;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _correctAnswerController.dispose();
    _incorrectAnswer1Controller.dispose();
    _incorrectAnswer2Controller.dispose();
    _incorrectAnswer3Controller.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final categories = await _firestoreService.getCategories();
    setState(() {
      _categories = categories.map((c) => c.name).toList();
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first;
      }
    });
  }

  Future<void> _addQuestion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final incorrectAnswers = <String>[
        _incorrectAnswer1Controller.text,
      ];

      if (_selectedType == 'multiple') {
        incorrectAnswers.add(_incorrectAnswer2Controller.text);
        incorrectAnswers.add(_incorrectAnswer3Controller.text);
      }

      final question = QuestionModel(
        id: '',
        category: _selectedCategory,
        type: _selectedType,
        question: _questionController.text,
        correctAnswer: _correctAnswerController.text,
        incorrectAnswers: incorrectAnswers,
        difficulty: _selectedDifficulty,
      );

      await _firestoreService.addQuestion(question);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Question added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        _questionController.clear();
        _correctAnswerController.clear();
        _incorrectAnswer1Controller.clear();
        _incorrectAnswer2Controller.clear();
        _incorrectAnswer3Controller.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Question'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0F1E),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: _categories.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Question Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Category dropdown
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory.isEmpty ? null : _selectedCategory,
                        decoration: _inputDecoration('Category'),
                        dropdownColor: const Color(0xFF1A1A2E),
                        style: const TextStyle(color: Colors.white),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please select a category'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Type dropdown
                      DropdownButtonFormField<String>(
                        initialValue: _selectedType,
                        decoration: _inputDecoration('Type'),
                        dropdownColor: const Color(0xFF1A1A2E),
                        style: const TextStyle(color: Colors.white),
                        items: const [
                          DropdownMenuItem(value: 'multiple', child: Text('Multiple Choice')),
                          DropdownMenuItem(value: 'boolean', child: Text('True/False')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Difficulty dropdown
                      DropdownButtonFormField<String>(
                        initialValue: _selectedDifficulty,
                        decoration: _inputDecoration('Difficulty'),
                        dropdownColor: const Color(0xFF1A1A2E),
                        style: const TextStyle(color: Colors.white),
                        items: const [
                          DropdownMenuItem(value: 'easy', child: Text('Easy')),
                          DropdownMenuItem(value: 'medium', child: Text('Medium')),
                          DropdownMenuItem(value: 'hard', child: Text('Hard')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedDifficulty = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Question
                      TextFormField(
                        controller: _questionController,
                        decoration: _inputDecoration('Question'),
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a question';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Correct answer
                      TextFormField(
                        controller: _correctAnswerController,
                        decoration: _inputDecoration('Correct Answer'),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the correct answer';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Incorrect answer 1
                      TextFormField(
                        controller: _incorrectAnswer1Controller,
                        decoration: _inputDecoration('Incorrect Answer 1'),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an incorrect answer';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Show additional incorrect answers for multiple choice
                      if (_selectedType == 'multiple') ...[
                        TextFormField(
                          controller: _incorrectAnswer2Controller,
                          decoration: _inputDecoration('Incorrect Answer 2'),
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an incorrect answer';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _incorrectAnswer3Controller,
                          decoration: _inputDecoration('Incorrect Answer 3'),
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an incorrect answer';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                      ],

                      const SizedBox(height: 24),

                      // Submit button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _addQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00F5FF),
                          foregroundColor: const Color(0xFF0F0F1E),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Add Question',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00F5FF), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
    );
  }
}

