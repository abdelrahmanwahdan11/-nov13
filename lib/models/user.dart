class User {
  User({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.bio,
    required this.stats,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final String bio;
  final Map<String, int> stats;
}
