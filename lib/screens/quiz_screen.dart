import 'package:flutter/material.dart';
import '../utils/api.dart';
import '../utils/html_decode.dart';
import 'results_screen.dart';

class QuizScreen extends StatefulWidget {
  final int categoryId;
  final int amount;
  final String difficulty;
  final String type;

  const QuizScreen({super.key, required this.categoryId, required this.amount, required this.difficulty, required this.type});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<dynamic> questions = [];
  int currentQuestion = 0;
  int score = 0;
  bool isLoading = true;
  String? selectedAnswer;
  bool hasAnswered = false;
  List<String> currentAnswers = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final data = await Api.fetchQuestions(
      amount: widget.amount,
      categoryId: widget.categoryId,
      difficulty: widget.difficulty,
      type: widget.type,
    );
    setState(() {
      questions = data;
      isLoading = false;
      if (questions.isNotEmpty) {
        _shuffleCurrentAnswers();
      }
    });
  }

  void _shuffleCurrentAnswers() {
    final question = questions[currentQuestion];
    currentAnswers = [...question['incorrect_answers'], question['correct_answer']]..shuffle();
  }

  void handleAnswer(String answer) {
    if (hasAnswered) return; // Prevent multiple selections
    
    final correctAnswer = questions[currentQuestion]['correct_answer'];
    setState(() {
      selectedAnswer = answer;
      hasAnswered = true;
      if (answer == correctAnswer) {
        score++;
      }
    });
  }

  void goToNext() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
        hasAnswered = false;
        _shuffleCurrentAnswers();
      });
    } else {
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

  Color _getAnswerColor(String answer) {
    if (!hasAnswered) return Colors.grey.shade50;
    
    final correctAnswer = questions[currentQuestion]['correct_answer'];
    if (answer == correctAnswer) {
      return Colors.green.shade100;
    } else if (answer == selectedAnswer) {
      return Colors.red.shade100;
    }
    return Colors.grey.shade50;
  }

  Color _getAnswerBorderColor(String answer) {
    if (!hasAnswered) return Colors.grey.shade300;
    
    final correctAnswer = questions[currentQuestion]['correct_answer'];
    if (answer == correctAnswer) {
      return Colors.green.shade600;
    } else if (answer == selectedAnswer) {
      return Colors.red.shade600;
    }
    return Colors.grey.shade300;
  }

  Color _getAnswerTextColor(String answer) {
    if (!hasAnswered) return Colors.grey.shade800;
    
    final correctAnswer = questions[currentQuestion]['correct_answer'];
    if (answer == correctAnswer) {
      return Colors.green.shade900;
    } else if (answer == selectedAnswer) {
      return Colors.red.shade900;
    }
    return Colors.grey.shade800;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor)),
      );
    }

    final question = questions[currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${currentQuestion + 1}/${questions.length}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey.shade700),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Score: $score',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              LinearProgressIndicator(
                value: (currentQuestion + 1) / questions.length,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              
              const SizedBox(height: 24),

              // Question container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        question['difficulty'].toString().toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      decodeHTML(question['question']),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade900),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Options
              Expanded(
                child: ListView.builder(
                  itemCount: currentAnswers.length,
                  itemBuilder: (context, index) {
                    final answer = currentAnswers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => handleAnswer(answer),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _getAnswerColor(answer),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _getAnswerBorderColor(answer), width: 2),
                          ),
                          child: Text(
                            decodeHTML(answer),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _getAnswerTextColor(answer),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Next/Finish button
              if (hasAnswered)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: goToNext,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    child: Text(
                      currentQuestion < questions.length - 1 ? 'Next Question' : 'Finish Quiz',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
