import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'categories_screen.dart';

class ResultsScreen extends StatelessWidget {
  final int score;
  final int total;

  const ResultsScreen({super.key, required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    final percentage = ((score / total) * 100).round();

    // Determine icon and color based on percentage
    IconData heroIcon;
    Color heroColor;
    String resultMessage;
    String scoreQuote;
    Color resultColor;
    Color resultBgColor;

    if (percentage >= 80) {
      heroIcon = Icons.emoji_events;
      heroColor = Colors.amber.shade600;
      resultMessage = 'Excellent!';
      scoreQuote = "You're crushing it! Try another round to beat your own score and make this streak official.";
      resultColor = Colors.grey.shade100;
      resultBgColor = Colors.green.shade600;
    } else if (percentage >= 60) {
      heroIcon = Icons.thumb_up;
      heroColor = Colors.green.shade600;
      resultMessage = 'Good Job!';
      scoreQuote = "You're on the right track! Take another quiz to sharpen your skills and see how much further you can go.";
      resultColor = Colors.amber.shade800;
      resultBgColor = Colors.green.shade600;

    } else if (percentage >= 40) {
      heroIcon = Icons.sentiment_satisfied;
      heroColor = Colors.blue.shade600;
      resultMessage = 'Not Bad!';
      scoreQuote = "Every attempt gets you better. Play again now and turn today's progress into tomorrow's victory!";
      resultColor = Colors.grey.shade800;
      resultBgColor = Colors.orange.shade600;
    } else {
      heroIcon = Icons.sentiment_dissatisfied;
      heroColor = Colors.orange.shade600;
      resultMessage = 'Keep Trying!';
      scoreQuote = "Don't give up! Progress comes from trying, learn from this one, and come back stronger!";
      resultColor = Colors.grey.shade100;
      resultBgColor = Colors.red.shade600;
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 8),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: BoxBorder.all(
                            color: heroColor,
                            width: 4,
                          ),
                        ),
                        child: Icon(heroIcon, size: 80, color: heroColor),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Result message
                    Text(
                      resultMessage,
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.grey.shade900),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Score display
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: resultBgColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: resultBgColor.withValues(alpha: 0.50),
                            spreadRadius: 4,
                            blurRadius: 4,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: resultColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 44),
                    // Small quote under the score
                    Text(
                      scoreQuote,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade800,
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // Play Again and Back to Home buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const CategoriesScreen()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh),
                          SizedBox(width: 8),
                          Text('Play Again', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Colors.grey.shade300, width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home, color: Colors.grey.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Back to Home',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
