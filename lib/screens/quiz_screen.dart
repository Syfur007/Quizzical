import 'package:flutter/material.dart';
import 'results_screen.dart';
import '../utils/api.dart';
import '../utils/html_decode.dart';

class QuizScreen extends StatefulWidget {
  final int categoryId;
  final int amount;
  final String difficulty;
  final String type;

  const QuizScreen({
    super.key,
    required this.categoryId,
    required this.amount,
    required this.difficulty,
    required this.type,
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
        final incorrect = (q['incorrect_answers'] as List).map((e) => decodeHTML(e as String)).toList();
        return {
          'question': decodeHTML(q['question'] as String),
          'correct_answer': decodeHTML(q['correct_answer'] as String),
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

  void _nextQuestion() {
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
      return Border.all(color: Colors.grey.shade300, width: 2);
    }

    String correctAnswer = questions[currentQuestionIndex]['correct_answer'];

    if (option == correctAnswer) {
      return Border.all(color: Colors.green, width: 3);
    } else if (option == selectedAnswer && option != correctAnswer) {
      return Border.all(color: Colors.red, width: 3);
    }

    return Border.all(color: Colors.grey.shade300, width: 2);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading Quiz...'),
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (loadError || questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
          backgroundColor: Theme.of(context).primaryColor,
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
        title: Text(
          'Question ${currentQuestionIndex + 1}/${questions.length}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Question Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.08),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      question['question'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Score: $score',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

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
                        borderRadius: BorderRadius.circular(12),
                        border: _getOptionBorder(option),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        option,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 16),

              // Next/Finish Button (always visible)
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
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
      ),
    );
  }
}
