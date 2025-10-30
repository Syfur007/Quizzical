import 'package:flutter/material.dart';
import 'results_screen.dart';
import '../utils/api.dart';
import 'package:html_character_entities/html_character_entities.dart';

class QuizScreen extends StatefulWidget {
  final int categoryId;
  final int amount;
  final String difficulty;
  final String type;
  final String? categoryName; // added optional categoryName
  final Color? categoryColor; // added optional categoryColor

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

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
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
      });
    } else {
      // Navigate to results screen with parameters expected by ResultsScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            score: score,
            total: questions.length,
          ),
        ),
      );
    }
  }

  Color _getOptionColor(String option) {
    if (!answered) {
      return Colors.white;
    }

    String correctAnswer = questions[currentQuestionIndex]['correct_answer'];

    if (option == correctAnswer) {
      return Colors.green.shade100;
    } else if (option == selectedAnswer && option != correctAnswer) {
      return Colors.red.shade100;
    }

    return Colors.white;
  }

  Border _getOptionBorder(String option) {
    if (!answered) {
      return Border.all(color: Colors.grey.shade300, width: 1, strokeAlign: BorderSide.strokeAlignCenter);
    }

    String correctAnswer = questions[currentQuestionIndex]['correct_answer'];

    if (option == correctAnswer) {
      return Border.all(color: Colors.green, width: 3, strokeAlign: BorderSide.strokeAlignCenter);
    } else if (option == selectedAnswer && option != correctAnswer) {
      return Border.all(color: Colors.red, width: 3, strokeAlign: BorderSide.strokeAlignCenter);
    }

    return Border.all(color: Colors.grey.shade300, width: 1, strokeAlign: BorderSide.strokeAlignCenter);
  }

  // New helper: returns the circular checkbox icon for an option
  Widget _buildOptionIcon(String option) {
    const double size = 28.0;

    // If questions aren't loaded yet or not answered, show neutral outline
    if (!answered || questions.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
      );
    }

    final String correctAnswer = questions[currentQuestionIndex]['correct_answer'];

    // Correct answer: green filled circle with check
    if (option == correctAnswer) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 18, color: Colors.white),
      );
    }

    // Selected incorrect answer: red filled circle with cross
    if (option == selectedAnswer && option != correctAnswer) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, size: 18, color: Colors.white),
      );
    }

    // Unselected/neutral option after answering
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.categoryColor ?? Theme.of(context).primaryColor;

    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading Quiz...'),
          backgroundColor: accent,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (loadError || questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
          backgroundColor: accent,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  loadError ? 'Failed to load questions.' : 'No questions available.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade800),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        // Replace the previous title with a back button and the category name
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.categoryName ?? 'Category'),
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Progress bar showing current question / total
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Question ${currentQuestionIndex + 1}/${questions.length}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: questions.isNotEmpty ? (currentQuestionIndex + 1) / questions.length : 0.0,
                            minHeight: 12,
                            valueColor: AlwaysStoppedAnimation(accent),
                            backgroundColor: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Question Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.18),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          question['question'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Options
                    ...allOptions.map((option) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: GestureDetector(
                          onTap: () => _selectAnswer(option),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: _getOptionColor(option),
                              borderRadius: BorderRadius.circular(25),
                              border: _getOptionBorder(option),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.02),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Circular checkbox icon (moved to helper)
                                _buildOptionIcon(option),

                                const SizedBox(width: 12),

                                // Option text
                                Expanded(
                                  child: Text(
                                    option,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
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

            // Next/Finish Button (always visible)
            ElevatedButton(
              onPressed: _handleNextPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: Text(
                // If the user has answered the question show Next/Finish, otherwise show Skip
                answered
                    ? (currentQuestionIndex < questions.length - 1 ? 'Next Question' : 'Finish Quiz')
                    : 'Skip',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
