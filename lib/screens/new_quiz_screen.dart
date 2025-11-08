import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../models/question_model.dart';
import '../models/result_model.dart';
import 'new_results_screen.dart';

class NewQuizScreen extends StatefulWidget {
  final String category;
  final String type;

  const NewQuizScreen({
    super.key,
    required this.category,
    required this.type,
  });

  @override
  State<NewQuizScreen> createState() => _NewQuizScreenState();
}

class _NewQuizScreenState extends State<NewQuizScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<QuestionModel> _questions = [];
  bool _isLoading = true;
  
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool _answered = false;
  List<AnswerDetail> _answerDetails = [];
  
  Timer? _timer;
  int _secondsRemaining = 15;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final questions = await _firestoreService.getQuestions(
      category: widget.category,
      type: widget.type,
      limit: 10,
    );

    if (questions.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No questions available for this category'),
            backgroundColor: Color(0xFFFF006E),
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    setState(() {
      _questions = questions;
      _isLoading = false;
    });

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsRemaining = 15;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    if (_answered) return;

    _timer?.cancel();

    // Mark as incorrect (timeout)
    final question = _questions[_currentQuestionIndex];
    _answerDetails.add(AnswerDetail(
      question: question.question,
      userAnswer: '(No answer)',
      correctAnswer: question.correctAnswer,
      isCorrect: false,
    ));

    setState(() {
      _answered = true;
    });

    // Auto advance after showing correct answer
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _selectAnswer(String answer) {
    if (_answered) return;

    _timer?.cancel();

    final question = _questions[_currentQuestionIndex];
    final isCorrect = answer == question.correctAnswer;

    _answerDetails.add(AnswerDetail(
      question: question.question,
      userAnswer: answer,
      correctAnswer: question.correctAnswer,
      isCorrect: isCorrect,
    ));

    setState(() {
      _selectedAnswer = answer;
      _answered = true;
    });

    // Auto advance after showing result
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
      _startTimer();
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    _timer?.cancel();

    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid ?? '';

    final score = _answerDetails.where((a) => a.isCorrect).length;
    final accuracy = (score / _questions.length) * 100;

    final result = ResultModel(
      id: '',
      userId: userId,
      category: widget.category,
      type: widget.type,
      score: score,
      totalQuestions: _questions.length,
      accuracy: accuracy,
      timestamp: DateTime.now(),
      answers: _answerDetails,
    );

    // Save result to Firestore
    await _firestoreService.saveResult(result);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NewResultsScreen(result: result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6B21A8),
                Color(0xFF9333EA),
                Color(0xFFA855F7),
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];
    final allAnswers = question.getAllAnswers();
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _showQuitDialog();
          if (shouldPop == true && mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6B21A8),
                Color(0xFF9333EA),
                Color(0xFFA855F7),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header with progress
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              final shouldQuit = await _showQuitDialog();
                              if (shouldQuit == true && mounted) {
                                Navigator.pop(context);
                              }
                            },
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.white.withOpacity(0.3),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Timer
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: _secondsRemaining <= 5
                              ? Colors.red.withOpacity(0.3)
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _secondsRemaining <= 5 ? Colors.red : Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer,
                              color: _secondsRemaining <= 5 ? Colors.red : Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$_secondsRemaining seconds',
                              style: TextStyle(
                                color: _secondsRemaining <= 5 ? Colors.red : Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Question
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            question.question,
                            style: const TextStyle(
                              color: Color(0xFF6B21A8),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Answers
                        ...allAnswers.map((answer) {
                          Color? backgroundColor;
                          Color? borderColor;

                          if (_answered) {
                            if (answer == question.correctAnswer) {
                              backgroundColor = Colors.green;
                              borderColor = Colors.green;
                            } else if (answer == _selectedAnswer) {
                              backgroundColor = Colors.red;
                              borderColor = Colors.red;
                            } else {
                              backgroundColor = Colors.white.withOpacity(0.2);
                              borderColor = Colors.white.withOpacity(0.3);
                            }
                          } else {
                            backgroundColor = Colors.white.withOpacity(0.2);
                            borderColor = Colors.white.withOpacity(0.3);
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () => _selectAnswer(answer),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor, width: 2),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        answer,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (_answered && answer == question.correctAnswer)
                                      const Icon(Icons.check_circle, color: Colors.white),
                                    if (_answered && answer == _selectedAnswer && answer != question.correctAnswer)
                                      const Icon(Icons.cancel, color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
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

  Future<bool?> _showQuitDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF6B21A8),
        title: const Text(
          'Quit Quiz?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Your progress will be lost if you quit now.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

