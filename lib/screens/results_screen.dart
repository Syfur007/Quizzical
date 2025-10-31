import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'categories_screen.dart';

class ResultsScreen extends StatelessWidget {
  final int score;
  final int total;
  final int totalTimeSeconds;

  const ResultsScreen({
    super.key,
    required this.score,
    required this.total,
    this.totalTimeSeconds = 0,
  });

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final percentage = ((score / total) * 100).round();

    // Determine icon and color based on percentage
    IconData heroIcon;
    Color heroColor;
    String resultMessage;
    String scoreQuote;

    if (percentage >= 80) {
      heroIcon = Icons.emoji_events_rounded;
      heroColor = const Color(0xFFF59E0B); // Gold
      resultMessage = 'LEGENDARY!';
      scoreQuote = "You're absolutely crushing it! Your skills are next level.";
    } else if (percentage >= 60) {
      heroIcon = Icons.military_tech_rounded;
      heroColor = const Color(0xFF10B981); // Green
      resultMessage = 'GREAT JOB!';
      scoreQuote = "Solid performance! Keep the momentum going.";
    } else if (percentage >= 40) {
      heroIcon = Icons.stars_rounded;
      heroColor = const Color(0xFF3B82F6); // Blue
      resultMessage = 'NICE TRY!';
      scoreQuote = "You're getting there! Practice makes perfect.";
    } else {
      heroIcon = Icons.psychology_rounded;
      heroColor = const Color(0xFFFF006E); // Pink
      resultMessage = 'KEEP GOING!';
      scoreQuote = "Every attempt brings you closer to mastery!";
    }

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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 20),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Trophy/Medal icon with massive glow
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: heroColor.withValues(alpha: 0.5),
                              blurRadius: 80,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                heroColor,
                                heroColor.withValues(alpha: 0.6),
                              ],
                            ),
                            border: Border.all(
                              color: heroColor.withValues(alpha: 0.5),
                              width: 4,
                            ),
                          ),
                          child: Icon(heroIcon, size: 90, color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Result message with gradient
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            heroColor,
                            heroColor.withValues(alpha: 0.8),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          resultMessage,
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Score display with massive neon glow
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              heroColor.withValues(alpha: 0.3),
                              heroColor.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: heroColor.withValues(alpha: 0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: heroColor.withValues(alpha: 0.4),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$percentage%',
                              style: TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.w900,
                                color: heroColor,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    color: heroColor.withValues(alpha: 0.5),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$score / $total CORRECT',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withValues(alpha: 0.7),
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Cumulative time display
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.timer_rounded, color: Colors.white.withValues(alpha: 0.8), size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Total Time: ${_formatTime(totalTimeSeconds)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white.withValues(alpha: 0.9),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Quote
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          scoreQuote,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.7),
                            height: 1.6,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Action buttons
                Column(
                  children: [
                    // Play Again button with glow
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00F5FF).withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const CategoriesScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00F5FF),
                          foregroundColor: const Color(0xFF0F0F1E),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.refresh_rounded, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'PLAY AGAIN',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Home button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                            (route) => false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.home_rounded, color: Colors.white.withValues(alpha: 0.8)),
                            const SizedBox(width: 12),
                            Text(
                              'HOME',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withValues(alpha: 0.8),
                                letterSpacing: 2,
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
      ),
    );
  }
}


