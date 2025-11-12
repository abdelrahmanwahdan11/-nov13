class AudioItem {
  AudioItem({
    required this.id,
    required this.title,
    required this.creator,
    required this.durationSec,
    required this.mood,
    required this.tags,
    required this.imageUrl,
    required this.waveform,
    required this.likes,
    required this.plays,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String creator;
  final int durationSec;
  final String mood;
  final List<String> tags;
  final String imageUrl;
  final List<double> waveform;
  final int likes;
  final int plays;
  final DateTime createdAt;
}
