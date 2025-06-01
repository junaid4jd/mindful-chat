import 'package:flutter/material.dart';
import 'package:mental_health_app/model/counselor_model.dart';
import 'package:mental_health_app/model/exercise_model.dart';
import 'package:mental_health_app/screens/dashboard/pages/chatbot/chat_screen.dart';
import 'package:mental_health_app/screens/dashboard/pages/councelor/councelor_screen.dart';
import 'package:mental_health_app/screens/dashboard/pages/home/home_screen.dart';
import 'package:mental_health_app/screens/dashboard/pages/profile/profile_screen.dart';



final List<Widget> pages =  [
  HomeScreen(),
  SimpleChat(),
  CounselorScreen(),
  ProfileScreen()
];

// Mental Health Exercises Database
final List<Exercise> mentalHealthExercises = [
  // Breathing Exercises
  Exercise(
    title: "Deep Breathing",
    subtitle: "5 minutes • Beginner",
    description: "A simple breathing technique to reduce stress and anxiety",
    durationMinutes: 5,
    difficulty: "Beginner",
    iconAsset: "assets/images/lungs.png",
    category: "Breathing",
    instructions: [
      "Find a comfortable seated position",
      "Place one hand on your chest, one on your belly",
      "Breathe in slowly through your nose for 4 counts",
      "Hold your breath for 4 counts",
      "Exhale slowly through your mouth for 6 counts",
      "Repeat for 5 minutes"
    ],
  ),
  Exercise(
    title: "Box Breathing",
    subtitle: "3 minutes • Beginner",
    description: "A structured breathing pattern used by Navy SEALs for stress relief",
    durationMinutes: 3,
    difficulty: "Beginner",
    iconAsset: "assets/images/lungs.png",
    category: "Breathing",
    instructions: [
      "Sit up straight and exhale completely",
      "Inhale through nose for 4 counts",
      "Hold breath for 4 counts",
      "Exhale through mouth for 4 counts",
      "Hold empty lungs for 4 counts",
      "Repeat this box pattern for 3 minutes"
    ],
  ),
  Exercise(
    title: "4-7-8 Breathing",
    subtitle: "4 minutes • Intermediate",
    description: "A breathing technique to promote relaxation and better sleep",
    durationMinutes: 4,
    difficulty: "Intermediate",
    iconAsset: "assets/images/lungs.png",
    category: "Breathing",
    instructions: [
      "Exhale completely through your mouth",
      "Close mouth and inhale through nose for 4 counts",
      "Hold breath for 7 counts",
      "Exhale through mouth for 8 counts",
      "Repeat cycle 4 times",
      "Practice twice daily"
    ],
  ),

  // Meditation Exercises
  Exercise(
    title: "Mindful Meditation",
    subtitle: "10 minutes • Intermediate",
    description: "Focus on the present moment to reduce stress and improve awareness",
    durationMinutes: 10,
    difficulty: "Intermediate",
    iconAsset: "assets/images/brain.png",
    category: "Meditation",
    instructions: [
      "Sit comfortably with eyes closed",
      "Focus on your natural breathing",
      "When thoughts arise, acknowledge them without judgment",
      "Gently return focus to your breath",
      "Continue for 10 minutes",
      "End by slowly opening your eyes"
    ],
  ),
  Exercise(
    title: "Body Scan Meditation",
    subtitle: "15 minutes • Advanced",
    description: "Systematically focus on different parts of your body to release tension",
    durationMinutes: 15,
    difficulty: "Advanced",
    iconAsset: "assets/images/brain.png",
    category: "Meditation",
    instructions: [
      "Lie down comfortably on your back",
      "Close eyes and take three deep breaths",
      "Start with your toes, notice any sensations",
      "Slowly move attention up through each body part",
      "Spend 30 seconds on each area",
      "End at the top of your head"
    ],
  ),
  Exercise(
    title: "Loving-Kindness Meditation",
    subtitle: "8 minutes • Beginner",
    description: "Develop feelings of compassion and love towards yourself and others",
    durationMinutes: 8,
    difficulty: "Beginner",
    iconAsset: "assets/images/brain.png",
    category: "Meditation",
    instructions: [
      "Sit comfortably and close your eyes",
      "Begin with yourself: 'May I be happy and healthy'",
      "Extend to loved ones: 'May you be happy and healthy'",
      "Include neutral people in your thoughts",
      "Even include difficult people in your practice",
      "End by including all living beings"
    ],
  ),

  // Mindfulness Exercises
  Exercise(
    title: "5-4-3-2-1 Grounding",
    subtitle: "3 minutes • Beginner",
    description: "Use your senses to ground yourself in the present moment",
    durationMinutes: 3,
    difficulty: "Beginner",
    iconAsset: "assets/images/brain.png",
    category: "Mindfulness",
    instructions: [
      "Name 5 things you can see",
      "Name 4 things you can touch",
      "Name 3 things you can hear",
      "Name 2 things you can smell",
      "Name 1 thing you can taste",
      "Take a deep breath and relax"
    ],
  ),
  Exercise(
    title: "Mindful Walking",
    subtitle: "10 minutes • Beginner",
    description: "Practice mindfulness while walking slowly and deliberately",
    durationMinutes: 10,
    difficulty: "Beginner",
    iconAsset: "assets/images/brain.png",
    category: "Mindfulness",
    instructions: [
      "Find a quiet path 10-20 steps long",
      "Walk very slowly, focusing on each step",
      "Feel your feet touching the ground",
      "Notice the lifting and placing of each foot",
      "When you reach the end, turn around mindfully",
      "Continue for 10 minutes"
    ],
  ),

  // Progressive Muscle Relaxation
  Exercise(
    title: "Progressive Muscle Relaxation",
    subtitle: "12 minutes • Intermediate",
    description: "Tense and relax different muscle groups to reduce physical tension",
    durationMinutes: 12,
    difficulty: "Intermediate",
    iconAsset: "assets/images/lungs.png",
    category: "Relaxation",
    instructions: [
      "Lie down in a comfortable position",
      "Start with your toes - tense for 5 seconds",
      "Release and feel the relaxation",
      "Move up to calves, thighs, abdomen",
      "Continue through arms, shoulders, face",
      "End by relaxing your entire body"
    ],
  ),

  // Visualization Exercises
  Exercise(
    title: "Safe Place Visualization",
    subtitle: "7 minutes • Beginner",
    description: "Create a mental sanctuary for peace and relaxation",
    durationMinutes: 7,
    difficulty: "Beginner",
    iconAsset: "assets/images/brain.png",
    category: "Visualization",
    instructions: [
      "Close eyes and take deep breaths",
      "Imagine a place where you feel completely safe",
      "It could be real or imaginary",
      "Notice the colors, sounds, and textures",
      "Feel the peace and security of this place",
      "Know you can return here anytime"
    ],
  ),
  Exercise(
    title: "Mountain Meditation",
    subtitle: "9 minutes • Intermediate",
    description: "Visualize yourself as a strong, unmovable mountain",
    durationMinutes: 9,
    difficulty: "Intermediate",
    iconAsset: "assets/images/brain.png",
    category: "Visualization",
    instructions: [
      "Sit with straight spine like a mountain",
      "Visualize yourself as a majestic mountain",
      "Weather changes around you but you remain steady",
      "Feel your strength and stability",
      "Let thoughts pass like clouds over your peak",
      "Remain grounded and unmovable"
    ],
  ),

  // Quick Relief Exercises
  Exercise(
    title: "Butterfly Hug",
    subtitle: "2 minutes • Beginner",
    description: "A self-soothing technique for immediate comfort",
    durationMinutes: 2,
    difficulty: "Beginner",
    iconAsset: "assets/images/brain.png",
    category: "Self-Soothing",
    instructions: [
      "Cross your arms over your chest",
      "Place hands on opposite shoulders",
      "Gently tap alternating hands on shoulders",
      "Create a slow, rhythmic pattern",
      "Focus on the soothing sensation",
      "Continue for 2 minutes or until calm"
    ],
  ),
  Exercise(
    title: "Stress Relief Squeeze",
    subtitle: "1 minute • Beginner",
    description: "Quick tension release for stressful moments",
    durationMinutes: 1,
    difficulty: "Beginner",
    iconAsset: "assets/images/lungs.png",
    category: "Quick Relief",
    instructions: [
      "Make tight fists with both hands",
      "Tense all muscles in your arms",
      "Hold for 10 seconds",
      "Release suddenly and shake arms",
      "Feel the tension melting away",
      "Repeat 3-5 times as needed"
    ],
  ),
];

final List<Counselor> onlineCounselors = [
  Counselor(
    name: 'Dr. Sara',
    specialization: 'Clinical Psychologist',
    imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
    isOnline: true,
  ),
  Counselor(
    name: 'Dr. Ahmed',
    specialization: 'Relationship Counselor',
    imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    isOnline: true,
  ),
];

final List<Counselor> offlineCounselors = [
  Counselor(
    name: 'Dr. Zainab Ali',
    specialization: 'Family Therapist',
    imageUrl: 'https://randomuser.me/api/portraits/women/68.jpg',
    isOnline: false,
  ),
  Counselor(
    name: 'Dr. Hassan M.',
    specialization: 'Behavioral Therapist',
    imageUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
    isOnline: false,
  ),
];
