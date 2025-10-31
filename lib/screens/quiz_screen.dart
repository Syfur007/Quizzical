import 'dart:async';
import 'package:flutter/material.dart';
import 'results_screen.dart';
import '../utils/api.dart';
import 'package:html_character_entities/html_character_entities.dart';

class QuizScreen extends StatefulWidget {
  final int categoryId;
  final int amount;
  final String difficulty;
  final String type;
  final String? categoryName;
  final Color? categoryColor;

  const QuizScreen({
    super.key,
    required this.categoryId,
    required this.amount,
    required this.difficulty,
    required this.type,
    this.categoryName,
    this.categoryColor,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> questions = [];
  bool loading = true;
  bool loadError = false;

  int currentQuestionIndex = 0;
  int score = 0;
  String? selectedAnswer;
  bool answered = false;

  // Store shuffled options for the current question so they don't reshuffle on every build
  List<String> allOptions = [];

  // Timer variables
  Timer? _timer;
  int _currentQuestionSeconds = 0;
  int _totalSeconds = 0;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _currentQuestionSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentQuestionSeconds++;
        _totalSeconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      loading = true;
      loadError = false;
    });

    try {
      final raw = await Api.fetchQuestions(
        amount: widget.amount,
        categoryId: widget.categoryId,
        difficulty: widget.difficulty,
        type: widget.type,
      );

      // Normalize and decode HTML entities
      questions = raw.map<Map<String, dynamic>>((q) {
        final incorrect = (q['incorrect_answers'] as List).map((e) => HtmlCharacterEntities.decode(e as String)).toList();
        return {
          'question': HtmlCharacterEntities.decode(q['question'] as String),
          'correct_answer': HtmlCharacterEntities.decode(q['correct_answer'] as String),
          'incorrect_answers': incorrect,
        };
      }).toList();

      if (questions.isNotEmpty) {
        _setOptionsForCurrentQuestion();
        _startTimer(); // Start timer when first question loads
      }

      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        loadError = true;
      });
    }
  }

  void _setOptionsForCurrentQuestion() {
    if (questions.isEmpty) {
      allOptions = [];
      return;
    }

    final question = questions[currentQuestionIndex];
    allOptions = [
      question['correct_answer'] as String,
      ...List<String>.from(question['incorrect_answers'] as List<String>)
    ];
    allOptions.shuffle();
  }

  void _selectAnswer(String answer) {
    if (answered) return; // Prevent further clicks after answering

    // Stop the timer when answer is selected
    _stopTimer();

    setState(() {
      selectedAnswer = answer;
      answered = true;

      // Check if the answer is correct
      if (answer == questions[currentQuestionIndex]['correct_answer']) {
        score++;
      }
    });
  }

  void _handleNextPressed() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
        answered = false;
        _setOptionsForCurrentQuestion();
        _startTimer(); // Restart timer for next question
      });
    } else {
      // Stop timer and navigate to results screen
      _stopTimer();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            score: score,
            total: questions.length,
            totalTimeSeconds: _totalSeconds,
          ),
        ),
      );
    }
  }

  Future<bool> _showQuitConfirmation() async {

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final accent = widget.categoryColor ?? const Color(0xFF00F5FF);

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: accent,
                  size: 64,
                ),
                const SizedBox(height: 20),
                Text(
                  'QUIT QUIZ?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: accent,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Are you sure you want to quit?\nYour progress will be lost.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: const Text(
                          'CONTINUE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF006E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'QUIT',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );


    return result ?? false;
  }

  // Helper: returns the circular checkbox icon for an option
  Widget _buildOptionIcon(String option) {
    const double size = 28.0;

    // If questions aren't loaded yet or not answered, show neutral outline
    if (!answered || questions.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
        ),
      );
    }

    final String correctAnswer = questions[currentQuestionIndex]['correct_answer'];

    // Correct answer: green filled circle with check
    if (option == correctAnswer) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF10B981),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.5),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
      );
    }

    // Selected incorrect answer: red filled circle with cross
    if (option == selectedAnswer && option != correctAnswer) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFFF006E),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF006E).withValues(alpha: 0.5),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
      );
    }

    // Unselected/neutral option after answering
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.categoryColor ?? const Color(0xFF00F5FF);

    if (loading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0F0F1E),
                const Color(0xFF1A1A2E),
                const Color(0xFF16213E),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: accent,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 24),
                Text(
                  'LOADING QUIZ...',
                  style: TextStyle(
                    color: accent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (loadError || questions.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0F0F1E),
                const Color(0xFF1A1A2E),
                const Color(0xFF16213E),
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 80, color: accent),
                  const SizedBox(height: 24),
                  Text(
                    loadError ? 'FAILED TO LOAD' : 'NO QUESTIONS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('GO BACK'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final question = questions[currentQuestionIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final shouldQuit = await _showQuitConfirmation();
        if (shouldQuit && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () async {
                final shouldQuit = await _showQuitConfirmation();
                if (shouldQuit && context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          title: Text(
            widget.categoryName?.toUpperCase() ?? 'QUIZ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent, accent.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  _formatTime(_currentQuestionSeconds),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
        body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F0F1E),
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress indicator
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'QUESTION ${currentQuestionIndex + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: accent,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          '${currentQuestionIndex + 1}/${questions.length}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.6),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: questions.isNotEmpty ? (currentQuestionIndex + 1) / questions.length : 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [accent, accent.withValues(alpha: 0.7)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Question card with glassmorphism
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.08),
                                Colors.white.withValues(alpha: 0.03),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.1),
                                blurRadius: 20,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            question['question'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Options with neon effect
                        ...allOptions.map((option) {
                          final isCorrect = answered && option == questions[currentQuestionIndex]['correct_answer'];
                          final isWrong = answered && option == selectedAnswer && option != questions[currentQuestionIndex]['correct_answer'];
                          final isNeutral = answered && option != selectedAnswer && option != questions[currentQuestionIndex]['correct_answer'];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14.0),
                            child: GestureDetector(
                              onTap: () => _selectAnswer(option),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20.0),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: isCorrect
                                        ? [const Color(0xFF10B981).withValues(alpha: 0.3), const Color(0xFF10B981).withValues(alpha: 0.1)]
                                        : isWrong
                                            ? [const Color(0xFFFF006E).withValues(alpha: 0.3), const Color(0xFFFF006E).withValues(alpha: 0.1)]
                                            : [Colors.white.withValues(alpha: 0.08), Colors.white.withValues(alpha: 0.03)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isCorrect
                                        ? const Color(0xFF10B981)
                                        : isWrong
                                            ? const Color(0xFFFF006E)
                                            : Colors.white.withValues(alpha: 0.2),
                                    width: isCorrect || isWrong ? 2 : 1.5,
                                  ),
                                  boxShadow: [
                                    if (isCorrect || isWrong)
                                      BoxShadow(
                                        color: (isCorrect ? const Color(0xFF10B981) : const Color(0xFFFF006E)).withValues(alpha: 0.3),
                                        blurRadius: 15,
                                        spreadRadius: 0,
                                      ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    _buildOptionIcon(option),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isNeutral ? Colors.white.withValues(alpha: 0.5) : Colors.white,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Next/Skip button with glow
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _handleNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          answered
                              ? (currentQuestionIndex < questions.length - 1 ? 'NEXT QUESTION' : 'FINISH QUIZ')
                              : 'SKIP QUESTION',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          answered && currentQuestionIndex >= questions.length - 1
                              ? Icons.check_circle_rounded
                              : Icons.arrow_forward_rounded,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

