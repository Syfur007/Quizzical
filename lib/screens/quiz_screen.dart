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
    });
  }

  void handleAnswer(String answer, String correctAnswer) {
    if (answer == correctAnswer) {
      setState(() => score++);
    }

    if (currentQuestion < questions.length - 1) {
      setState(() => currentQuestion++);
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple.shade600, Colors.pink.shade500, Colors.red.shade500],
            ),
          ),
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    final question = questions[currentQuestion];
    final allAnswers = [...question['incorrect_answers'], question['correct_answer']]..shuffle();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade600, Colors.pink.shade500, Colors.red.shade500],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Card(
              elevation: 20,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${currentQuestion + 1}/${questions.length}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.purple.shade600, Colors.pink.shade500],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Score: $score',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: (currentQuestion + 1) / questions.length,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade600),
                      minHeight: 8,
                    ),
                    SizedBox(height: 24),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        question['difficulty'].toString().toUpperCase(),
                        style: TextStyle(
                          color: Colors.purple.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      decodeHTML(question['question']),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 32),
                    Expanded(
                      child: ListView.builder(
                        itemCount: allAnswers.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: ElevatedButton(
                              onPressed: () => handleAnswer(allAnswers[index], question['correct_answer']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade50,
                                foregroundColor: Colors.grey.shade800,
                                padding: EdgeInsets.all(20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(color: Colors.grey.shade300, width: 2),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                decodeHTML(allAnswers[index]),
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
