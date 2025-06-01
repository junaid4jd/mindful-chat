import 'package:flutter/material.dart';
import 'dart:math';
import 'package:mental_health_app/constants/app_lists.dart';
import 'package:mental_health_app/model/exercise_model.dart';
import 'package:mental_health_app/providers/settings_provider.dart';
import 'package:mental_health_app/screens/dashboard/pages/home/exercise_player_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String name = '';
  List<Exercise> todaysExercises = [];
  late String dailyQuote;
  late String quoteAuthor;

  // Daily quotes for variety
  final List<Map<String, String>> quotes = [
    {
      "quote": "Peace comes from within. Do not seek it without.",
      "author": "Buddha"
    },
    {
      "quote": "The present moment is the only time over which we have dominion.",
      "author": "Thich Nhat Hanh"
    },
    {
      "quote": "Yesterday is history, tomorrow is a mystery, today is a gift.",
      "author": "Eleanor Roosevelt"
    },
    {
      "quote": "The mind is everything. What you think you become.",
      "author": "Buddha"
    },
    {
      "quote": "Be yourself; everyone else is already taken.",
      "author": "Oscar Wilde"
    },
    {
      "quote": "In the midst of winter, I found there was, within me, an invincible summer.",
      "author": "Albert Camus"
    },
    {
      "quote": "The only way out is through.",
      "author": "Robert Frost"
    },
    {
      "quote": "What lies behind us and what lies before us are tiny matters compared to what lies within us.",
      "author": "Ralph Waldo Emerson"
    },
  ];

  @override
  void initState() {
    super.initState();
    getName();
    _generateDailyContent();
  }

  getName() async {
    final settingProvider = Provider.of<SettingsProvider>(
        context, listen: false);
    final nameData = await settingProvider.init();
    setState(() {
      name = nameData;
    });
  }

  void _generateDailyContent() {
    // Create a seed based on current date for consistent daily content
    final now = DateTime.now();
    final dayOfYear = now
        .difference(DateTime(now.year, 1, 1))
        .inDays;
    final random = Random(dayOfYear);

    // Select 3 random exercises for today
    final shuffledExercises = List<Exercise>.from(mentalHealthExercises)
      ..shuffle(random);
    todaysExercises = shuffledExercises.take(3).toList();

    // Select daily quote
    final quoteIndex = random.nextInt(quotes.length);
    dailyQuote = quotes[quoteIndex]["quote"]!;
    quoteAuthor = quotes[quoteIndex]["author"]!;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hi, $name", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("How are you feeling today?", style: TextStyle(fontSize: 18, color: Colors.grey[700])),
            SizedBox(height: 20),

            // Mood Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _moodIcon("Happy", "assets/images/happy.png"),
                _moodIcon("Calm", "assets/images/calm.png"),
                _moodIcon("Anxious", "assets/images/ansious.png"),
                _moodIcon("Stressed", "assets/images/stressed.png"),
              ],
            ),
            SizedBox(height: 30),

            // Daily Quote
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote, color: Colors.blue),
                  SizedBox(height: 10),
                  Text(
                    '"$dailyQuote"',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  Text("- $quoteAuthor",
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Today's Exercises Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Today's Exercises", style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "NEW",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),

            // Today's Exercises List
            ...todaysExercises.map((exercise) =>
                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: _buildExerciseTile(exercise),
                )).toList(),

            SizedBox(height: 20),

            // Exercise Categories
            Text("Browse by Category",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 15),
            _buildCategoryGrid(),
          ],
        ),
      ),
    );
  }

  Widget _moodIcon(String label, String assetPath) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You\'re feeling $label today'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Column(
        children: [
          Image.asset(
            assetPath,
            height: 50,
            width: 50,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.mood, size: 50, color: Colors.grey);
            },
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildExerciseTile(Exercise exercise) {
    Color categoryColor = _getCategoryColor(exercise.category);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExercisePlayerScreen(exercise: exercise),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            // Exercise Icon
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                exercise.iconAsset,
                height: 32,
                width: 32,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.spa,
                    size: 32,
                    color: categoryColor,
                  );
                },
              ),
            ),
            SizedBox(width: 16),

            // Exercise Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    exercise.subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      exercise.category,
                      style: TextStyle(
                        color: categoryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Play Button
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: categoryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = mentalHealthExercises
        .map((e) => e.category)
        .toSet()
        .toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final categoryColor = _getCategoryColor(category);
        final exerciseCount = mentalHealthExercises
            .where((e) => e.category == category)
            .length;

        return GestureDetector(
          onTap: () => _showCategoryExercises(category),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: categoryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: categoryColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '$exerciseCount exercises',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Breathing':
        return Colors.blue;
      case 'Meditation':
        return Colors.purple;
      case 'Mindfulness':
        return Colors.green;
      case 'Relaxation':
        return Colors.orange;
      case 'Visualization':
        return Colors.teal;
      case 'Self-Soothing':
        return Colors.pink;
      case 'Quick Relief':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showCategoryExercises(String category) {
    final categoryExercises = mentalHealthExercises
        .where((e) => e.category == category)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          Container(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.spa,
                          color: _getCategoryColor(category),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '$category Exercises',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: categoryExercises.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: _buildExerciseTile(categoryExercises[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
