class Exercise {
  final String title;
  final String subtitle;
  final String description;
  final int durationMinutes;
  final String difficulty;
  final String iconAsset;
  final String category;
  final List<String> instructions;
  final String audioUrl; // For future audio implementation

  Exercise({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.durationMinutes,
    required this.difficulty,
    required this.iconAsset,
    required this.category,
    required this.instructions,
    this.audioUrl = '',
  });
}