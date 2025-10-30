import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class ConfigScreen extends StatefulWidget {
  final int categoryId;

  const ConfigScreen({super.key, required this.categoryId});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  int amount = 10;
  String difficulty = 'medium';
  String type = 'multiple';
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: amount.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Card(
                elevation: 20,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Quiz Settings',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 32),
                      Text('Number of Questions', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          hintText: 'Enter number (1-50)',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() => amount = int.tryParse(value) ?? 10);
                        },
                        controller: _controller,
                      ),
                      SizedBox(height: 24),
                      Text('Difficulty', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: difficulty,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: ['easy', 'medium', 'hard']
                            .map((d) => DropdownMenuItem(value: d, child: Text(d.toUpperCase())))
                            .toList(),
                        onChanged: (value) => setState(() => difficulty = value!),
                      ),
                      SizedBox(height: 24),
                      Text('Question Type', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: type,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: [
                          DropdownMenuItem(value: 'multiple', child: Text('Multiple Choice')),
                          DropdownMenuItem(value: 'boolean', child: Text('True/False')),
                        ],
                        onChanged: (value) => setState(() => type = value!),
                      ),
                      SizedBox(height: 32),
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
                            padding: EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 8,
                          ),
                          child: Text('Start Quiz', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
