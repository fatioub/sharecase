class ModTip {
  final int id;
  final String title;
  final String description;
  final String category;
  final String difficulty;

  ModTip({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
  });

  factory ModTip.fromJson(Map<String, dynamic> json) {
    return ModTip(
      id: json['id'],
      title: 'Mod Tip #${json['id']}',
      description: json['body'],
      category: _getRandomCategory(),
      difficulty: _getRandomDifficulty(),
    );
  }

  static String _getRandomCategory() {
    final categories = ['Gaming', 'Productivity', 'Social', 'Entertainment', 'Tools'];
    return categories[DateTime.now().millisecond % categories.length];
  }

  static String _getRandomDifficulty() {
    final difficulties = ['Easy', 'Medium', 'Hard'];
    return difficulties[DateTime.now().microsecond % difficulties.length];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'difficulty': difficulty,
    };
  }
}
