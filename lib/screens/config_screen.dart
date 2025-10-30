import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class ConfigScreen extends StatefulWidget {
  final int categoryId;
  final String? categoryName;

  const ConfigScreen({super.key, required this.categoryId, this.categoryName});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  int amount = 10;
  String difficulty = 'medium';
  String type = 'multiple';

  @override
  Widget build(BuildContext context) {
    final displayName = widget.categoryName ?? 'Category';

    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero image (small) and category name
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Icon(Icons.category, size: 36, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayName,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Number of questions (slider)
              Text('Number of Questions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      min: 1,
                      max: 50,
                      divisions: 49,
                      value: amount.toDouble(),
                      label: amount.toString(),
                      onChanged: (v) => setState(() => amount = v.round()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('$amount'),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Difficulty dropdown
              Text('Difficulty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: difficulty,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: [
                  DropdownMenuItem(value: 'easy', child: Text('Easy')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'hard', child: Text('Hard')),
                ],
                onChanged: (v) => setState(() => difficulty = v ?? 'medium'),
              ),

              const SizedBox(height: 18),

              // Question Type dropdown
              Text('Question Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: type,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: [
                  DropdownMenuItem(value: 'multiple', child: Text('Multiple Choice')),
                  DropdownMenuItem(value: 'boolean', child: Text('True / False')),
                ],
                onChanged: (v) => setState(() => type = v ?? 'multiple'),
              ),

              const SizedBox(height: 28),

              // Start Quiz button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          categoryId: widget.categoryId,
                          amount: amount,
                          difficulty: difficulty,
                          type: type,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 6,
                  ),
                  child: const Text('Start Quiz', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
