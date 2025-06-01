import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mental_health_app/constants/app_colors.dart';
import 'package:mental_health_app/model/exercise_model.dart';

class ExercisePlayerScreen extends StatefulWidget {
  final Exercise exercise;

  const ExercisePlayerScreen({Key? key, required this.exercise})
      : super(key: key);

  @override
  State<ExercisePlayerScreen> createState() => _ExercisePlayerScreenState();
}

class _ExercisePlayerScreenState extends State<ExercisePlayerScreen> {
  bool _isPlaying = false;
  bool _isPaused = false;
  int _currentStep = 0;
  int _secondsRemaining = 0;
  Timer? _timer;
  late int _totalSeconds;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.exercise.durationMinutes * 60;
    _secondsRemaining = _totalSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startExercise() {
    setState(() {
      _isPlaying = true;
      _isPaused = false;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _completeExercise();
        }
      });
    });
  }

  void _pauseExercise() {
    setState(() {
      _isPaused = true;
    });
    _timer?.cancel();
  }

  void _resumeExercise() {
    setState(() {
      _isPaused = false;
    });
    _startExercise();
  }

  void _stopExercise() {
    setState(() {
      _isPlaying = false;
      _isPaused = false;
      _secondsRemaining = _totalSeconds;
      _currentStep = 0;
    });
    _timer?.cancel();
  }

  void _completeExercise() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
    });

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Row(
              children: [
                Icon(Icons.celebration, color: Colors.green),
                SizedBox(width: 12),
                Text('Great Job!'),
              ],
            ),
            content: Text(
              'You completed the ${widget.exercise
                  .title} exercise! How do you feel?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('Done'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetExercise();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purpleColor,
                ),
                child: Text('Do Again', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  void _resetExercise() {
    setState(() {
      _secondsRemaining = _totalSeconds;
      _currentStep = 0;
      _isPlaying = false;
      _isPaused = false;
    });
    _timer?.cancel();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds
        .toString()
        .padLeft(2, '0')}';
  }

  double get _progress {
    return (_totalSeconds - _secondsRemaining) / _totalSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.exercise.title,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Exercise Info Card
            Container(
              width: double.infinity,
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
                children: [
                  Image.asset(
                    widget.exercise.iconAsset,
                    height: 80,
                    width: 80,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.spa,
                        size: 80,
                        color: AppColors.purpleColor,
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.exercise.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.exercise.subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  Text(
                    widget.exercise.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Timer and Progress
            Container(
              width: double.infinity,
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
                children: [
                  // Circular Progress
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                            value: _progress,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.purpleColor,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatTime(_secondsRemaining),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppColors.purpleColor,
                              ),
                            ),
                            Text(
                              'remaining',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // Control Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Stop Button
                      IconButton(
                        onPressed: _isPlaying ? _stopExercise : null,
                        icon: Icon(Icons.stop),
                        iconSize: 40,
                        color: _isPlaying ? Colors.red : Colors.grey,
                      ),

                      // Play/Pause Button
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.purpleColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (!_isPlaying && !_isPaused) {
                              _startExercise();
                            } else if (_isPlaying && !_isPaused) {
                              _pauseExercise();
                            } else if (_isPaused) {
                              _resumeExercise();
                            }
                          },
                          icon: Icon(
                            _isPlaying && !_isPaused
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          iconSize: 50,
                          color: Colors.white,
                        ),
                      ),

                      // Reset Button
                      IconButton(
                        onPressed: _resetExercise,
                        icon: Icon(Icons.refresh),
                        iconSize: 40,
                        color: AppColors.purpleColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Instructions
            Container(
              width: double.infinity,
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
                  Row(
                    children: [
                      Icon(Icons.list_alt, color: AppColors.purpleColor),
                      SizedBox(width: 12),
                      Text(
                        'Instructions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ...widget.exercise.instructions
                      .asMap()
                      .entries
                      .map((entry) {
                    int index = entry.key;
                    String instruction = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.purpleColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.purpleColor,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              instruction,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}