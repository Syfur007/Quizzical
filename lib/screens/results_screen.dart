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

    if (percentage >= 80) {
      heroIcon = Icons.emoji_events;
      heroColor = Colors.amber.shade600;
      resultMessage = 'Excellent!';
    } else if (percentage >= 60) {
      heroIcon = Icons.thumb_up;
      heroColor = Colors.green.shade600;
      resultMessage = 'Good Job!';
    } else if (percentage >= 40) {
      heroIcon = Icons.sentiment_satisfied;
      heroColor = Colors.blue.shade600;
      resultMessage = 'Not Bad!';
    } else {
      heroIcon = Icons.sentiment_dissatisfied;
      heroColor = Colors.orange.shade600;
      resultMessage = 'Keep Trying!';
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero icon based on percentage
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: heroColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(heroIcon, size: 60, color: Colors.white),
                ),
              ),

              const SizedBox(height: 24),

              // Result message
              Text(
                resultMessage,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.grey.shade900),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Quiz Complete!',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Score display
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: heroColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$score out of $total correct',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

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
